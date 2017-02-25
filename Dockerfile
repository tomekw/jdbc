FROM jruby:9.1.7.0-jre-alpine

RUN apk --update --no-cache add git openssh-client && \
    gem install bundler && \
    mkdir /jdbc

WORKDIR /jdbc

COPY jdbc.gemspec Gemfile Gemfile.lock ./

RUN bundle

COPY . ./
