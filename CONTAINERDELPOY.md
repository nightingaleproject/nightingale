## Containerized Deployment

To run nightingale in a containerized production environment:

Run:

```bundle exec rake secret```

Set SECRET_KEY_BASE in `.env.production` to the resulting value.

Then run:

```docker-compose up```

In another terminal or session, run:

```docker-compose run app rake db:create db:migrate```

If desired, run the demo environment setup:

```docker-compose run app rake nightingale:demo:setup```
