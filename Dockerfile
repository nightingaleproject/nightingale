FROM ruby:2.4.4

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash \
    && apt-get install nodejs -yq

ENV RAILS_ENV production

RUN mkdir /nightingale
WORKDIR /nightingale
COPY Gemfile /nightingale/Gemfile
COPY Gemfile.lock /nightingale/Gemfile.lock

RUN bundle install --without development test
COPY . /nightingale

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

RUN bundle exec rake assets:precompile

# Start the main process.
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
