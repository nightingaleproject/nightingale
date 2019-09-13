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

# Set working directory, where the commands will be ran:
WORKDIR $RAILS_ROOT

# Gems:
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler -v 1.17.3 && bundle install --jobs 20 --retry 5 --without development test

COPY config/puma.rb config/puma.rb

# Copy the main application.
COPY . .

RUN bundle exec rake SECRET_KEY_BASE=dummytoken DATABASE_URL=postgresql:does_not_exist assets:precompile

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

RUN bundle exec rake assets:precompile

# Start the main process.
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
