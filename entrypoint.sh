#!/bin/sh
set -e

python manage.py makemigrations
python manage.py migrate
python manage.py createcachetable

printenv
echo "${DJANGO_SUPERUSER_USERNAME}"

if [ "$DJANGO_SUPERUSER_USERNAME" ]
then
    echo "New supseruser will be created"
    python manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL
    echo "New supseruser was created"
fi

exec "$@"