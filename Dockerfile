FROM bitnami/ruby:2.1.10
MAINTAINER Motion Bank

WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y postgresql-client-9.6 libpq5 libpq-dev
RUN bundle install

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
