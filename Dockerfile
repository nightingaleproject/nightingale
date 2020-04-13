FROM ruby:2.6.6

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

ENV RAILS_ENV production

RUN mkdir /nightingale
WORKDIR /nightingale
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN git config --global http.sslVerify "false"

RUN gem install bundler -v 2.1.4 && bundle config set without 'development test' && bundle install --retry 5

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
