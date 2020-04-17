#!/bin/bash

if [ -f .env ]; then
	echo ".env already exists, if you would like to regenerate your secrets, please delete this file and re-run the script."
else
	echo ".env does not exist, creating..."
	(umask 066; touch .env)
fi

if ! grep -qF "POSTGRES_PASSWORD" .env; then
	echo ".env does not contain POSTGRES_PASSWORD, generating secret..."
	echo -e "\nPOSTGRES_PASSWORD=$(openssl rand -hex 33)" >> .env
fi


if [ -f .env.production ]; then
	echo ".env.production already exists, if you would like to regenerate your secrets, please delete this file and re-run the script."
else
	echo ".env.production does not exist, creating..."
	cat >.env.production - << EOF
SECRET_KEY_BASE=$(openssl rand -hex 64)
EOF
fi

echo "Done"
