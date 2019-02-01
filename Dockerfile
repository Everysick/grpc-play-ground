FROM ruby:2.5

RUN gem update bundler

WORKDIR /app
COPY . /app

RUN bundle install -j4
