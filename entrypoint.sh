#!/bin/sh
# https://stackoverflow.com/questions/2870992/automatic-exit-from-bash-shell-script-on-error
set -euxv

python manage.py makemigrations
python manage.py migrate

# If the given user exists, continue running the script
# https://stackoverflow.com/questions/17830326/ignoring-specific-errors-in-a-shell-script
if [ "$DJANGO_SUPERUSER_USERNAME" ]
then
    python manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL \
        || true   
fi

exec "$@"