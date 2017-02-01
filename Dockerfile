FROM jruby:9.1.7.0-jre-alpine

RUN apk --update --no-cache add git openssh && \
    mkdir /jdbc

WORKDIR /jdbc

COPY jdbc.gemspec Gemfile Gemfile.lock ./

RUN gem install bundler -v 1.13.7 && bundle

COPY . ./
