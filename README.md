# Dockerize A Django App With Multi-Stage Builds And Poetry

This project shows how to use Docker multi-stage builds to create a docker image used in development and also a production-ready one.

## Run docker containers in development

```sh
make run-dev
```

## Run docker containers in production

```sh
make run-prod
```

## Note

- For the development environment, when `DEBUG` is set to `True`, static files serving will be done automatically by using `django.contrib.staticfiles` and `runserver`. But this method is unsuitable for production.
- For the production, the [whitenoise](https://whitenoise.readthedocs.io/en/latest/) package is used to handle the static files but first we need to run `collectstatic` to get all static files in the location defined in `STATIC_ROOT`.
