## Containerized Deployment

To run nightingale in a containerized production environment:

Run the following command to configure your environment (this only has to be run once):

```./setup-docker-secrets.sh```

Then run:

```docker-compose up -d --build```

The application should be accessible at [http://localhost:80](http://localhost:80). If you need the application on a different port, you can update the following section in the `docker-compose.yml` file, replacing the section marked by `<NEW PORT>` below.

```yaml
  web:
    build:
      context: .
      dockerfile: Dockerfile-nginx
    ports:
      - "<NEW PORT>:80"
    depends_on:
```

To setup and load your database run:

```docker-compose run app rake db:create db:schema:load```

If desired, run the demo environment setup:

```docker-compose run app rake nightingale:demo:setup```

Whenever you update your version of nightingale, be sure to run:

```docker-compose run app rake db:migrate```

When you are done, to stop the containers run:

```docker-compose down```
