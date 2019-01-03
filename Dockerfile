# Base image:
FROM ruby:2.4.4

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash \
    && apt-get install nodejs -yq

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true

# Set an environment variable where the Rails app is installed to inside of Docker image:
ENV RAILS_ROOT /var/www/nightingale
RUN mkdir -p $RAILS_ROOT

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

EXPOSE 3000

# The default command that gets ran will be to start the Puma server.
CMD bundle exec puma -C config/puma.rb
