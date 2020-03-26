## Containerized Deployment

To run nightingale in a containerized production environment:

Run the following command to configure your environment:

```./setup-docker-secrets.sh```

Then run:

```docker-compose up -d```

To setup and migrate your database run:

```docker-compose run app rake db:create db:migrate```

If desired, run the demo environment setup:

```docker-compose run app rake nightingale:demo:setup```

When you are done, to stop the containers run:

```docker-compose down```
