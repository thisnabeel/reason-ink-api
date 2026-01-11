# syntax=docker/dockerfile:1
FROM ruby:3.2.0
RUN apt-get update -qq && apt-get install -y \
  postgresql-client \
  build-essential \
  libpq-dev \
  nodejs

WORKDIR /app
COPY Gemfile* .
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["rake", "tmp:pids:clear"]
CMD ["rails", "server", "-b", "0.0.0.0"]
