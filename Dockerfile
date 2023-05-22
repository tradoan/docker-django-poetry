from python:3.10-slim-buster as python-base

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    APP_DIR=/app \
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    POETRY_HOME='/opt/poetry' \
    # The virtualenv will be created and expected in a folder named .venv 
    # within the root directory of the project.
    # In this case, the project’s root directory is $POETRY_HOME 
    # because pyproject.toml and poetry.lock are copied into $POETRY_HOME later
    # and packages will be installed there.
    POETRY_VIRTUALENVS_IN_PROJECT=true

ENV POETRY_CACHE_DIR="${POETRY_HOME}/.cache" \
    # virtual environment location
    # The virtualenv will be created and expected in a folder named .venv 
    # within the root directory of the project $POETRY_HOME
    PYTHON_VENV="${POETRY_HOME}/.venv"

# prepend poetry and venv to path
# elegant way to activate virtualenv
# https://pythonspeed.com/articles/activate-virtualenv-dockerfile/
ENV PATH="${POETRY_HOME}/bin:${PYTHON_VENV}/bin:${PATH}"

ENV DJANGO_USER=django \
    DJANGO_USER_ID=1001 \
    DJANGO_GROUP=django \
    DJANGO_GROUP_ID=1001

# install tini
# https://github.com/krallin/tini
# Why should tini be used? https://github.com/krallin/tini/issues/8
RUN apt-get update \
    && apt-get install --no-install-recommends -y tini
# create a non-root user to run djang app
RUN groupadd --system --gid "${DJANGO_GROUP_ID}" "${DJANGO_GROUP}" \ 
    && useradd --system --no-create-home --shell=/sbin/nologin --uid "${DJANGO_USER_ID}" --gid "${DJANGO_GROUP_ID}" "${DJANGO_USER}"

FROM python-base as builder-base

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential

# install poetry
ENV POETRY_VERSION=1.2.0
RUN curl -sSL https://install.python-poetry.org | python3 -

WORKDIR "${POETRY_HOME}"
COPY ./pyproject.toml ./poetry.lock .
RUN poetry install --no-dev --no-root

from python-base as dev

COPY --from=builder-base ${POETRY_HOME} ${POETRY_HOME}

WORKDIR "${POETRY_HOME}"
COPY ./pyproject.toml ./poetry.lock .

WORKDIR "${APP_DIR}"

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# COPY --chown="${DJANGO_USER}":"${DJANGO_GROUP}" app/ .
# COPY app/ .
# RUN chown -R "${DJANGO_USER}":"${DJANGO_GROUP}" "${APP_DIR}"

USER "${DJANGO_USER}"
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

from python-base as prod

COPY --from=builder-base ${POETRY_HOME} ${POETRY_HOME}
# COPY --from=builder-base /tini /tini

WORKDIR "${APP_DIR}"

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY app/ .
RUN chown -R "${DJANGO_USER}":"${DJANGO_GROUP}" "${APP_DIR}"

USER "${DJANGO_USER}"
ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
