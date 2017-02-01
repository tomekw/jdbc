# JDBC

[![Code Climate](https://codeclimate.com/github/tomekw/jdbc/badges/gpa.svg)](https://codeclimate.com/github/tomekw/jdbc) [![Gem Version](https://badge.fury.io/rb/jdbc.svg)](https://badge.fury.io/rb/jdbc) [![CircleCI](https://circleci.com/gh/tomekw/jdbc.svg?style=svg)](https://circleci.com/gh/tomekw/jdbc)

JDBC meets JRuby.

Please note the project support only JRuby (tested with 9.1.7.0+) on Java 8.

The public API is subject to change before version `1.0.0`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "jdbc"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jdbc

## Usage

Install the database driver, for PostgreSQL:

```ruby
gem "jdbc-postgres"
```

Load the the database driver if needed, for PostgreSQL:

```ruby
require "jdbc/postgres"
Jdbc::Postgres.load_driver
```

Configure the connection pool:

```ruby
gem "hucpa"
```

```ruby
require "hucpa"

# Using the adapter option
options = {
  adapter: :postgresql,
  database_name: "jdbc",
  password: "jdbc",
  server_name: "postgres",
  username: "jdbc"
}

# Using the jdbc_url option
options = {
  jdbc_url: "jdbc:postgresql://postgres/jdbc",
  password: "jdbc",
  username: "jdbc"
}

connection_pool = Hucpa::ConnectionPool.new(options)
```

Close the connection pool:

```ruby
connection_pool.close
```

## Development

Build the Docker image:

    $ docker-compose build

Create services:

    $ docker-compose create

Run specs:

    $ docker-compose run --rm app rspec spec

Run console:

    $ docker-compose run --rm app irb

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomekw/jdbc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
