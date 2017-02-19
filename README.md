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

gateway = JDBC::Gateway.new(connection_pool: connection_pool)
```

Query for records:

```ruby
gateway.query("SELECT * FROM things")
=> [
  {
    id: 1,
    name: "Foo",
    created_at: DateTime.new(2017, 2, 1, 10, 20, 45)
  },
  {
    id: 2,
    name: "Bar",
    created_at: DateTime.new(2017, 2, 1, 10, 21, 47)
  }
]
```

Query bindings can be provided:

```ruby
gateway.query("SELECT * FROM things WHERE name = :name", name: "Foo")
=> [
  {
    id: 1,
    name: "Foo",
    created_at: DateTime.new(2017, 2, 1, 10, 20, 45)
  }
]
```

Optionally, bindings can be annotated with a [JDBC type](#jdbc-types).
It is in fact required when value can be `nil`:

```ruby
gateway.query("SELECT * FROM things WHERE name = :name:VARCHAR OR (name IS NULL AND :name:VARCHAR IS NULL)", name: nil)
=> [
  {
    id: 3,
    name: nil,
    created_at: DateTime.new(2017, 2, 2, 10, 20, 45)
  }
]
```

Pass commands:

```ruby
gateway.command("INSERT INTO things (name, created_at) VALUES (:name, NOW())", name: "Foo")
=> [
  {
    id: 4,
    name: "Foo",
    created_at: DateTime.new(2017, 2, 2, 10, 20, 45)
  }
]
```

```ruby
gateway.command("UPDATE things SET name = :name WHERE id < :id", name: "Bar", id: 2)
=> [
  {
    id: 1,
    name: "Bar",
    created_at: DateTime.new(2017, 2, 2, 10, 20, 45)
  }
]
```

```ruby
gateway.command("DELETE FROM things WHERE id = :id", id: 1)
=> [
  {
    id: 1,
    name: "Bar",
    created_at: DateTime.new(2017, 2, 2, 10, 20, 45)
  }
]
```

Close the connection pool:

```ruby
connection_pool.close
```

## (Known) things that won't work (yet)

* passing `UUID`s as bindings parameters
* passing timestamps as bindings parameters
* groupping SQL queries / commands in transactions

## JDBC types

* `ARRAY`
* `BIGINT`
* `BINARY`
* `BIT`
* `BLOB`
* `BOOLEAN`
* `CHAR`
* `CLOB`
* `DATALINK`
* `DATE`
* `DECIMAL`
* `DISTINCT`
* `DOUBLE`
* `FLOAT`
* `INTEGER`
* `JAVA_OBJECT`
* `LONGNVARCHAR`
* `LONGVARBINARY`
* `LONGVARCHAR`
* `NCHAR`
* `NCLOB`
* `NULL`
* `NUMERIC`
* `NVARCHAR`
* `OTHER`
* `REAL`
* `REF`
* `REF_CURSOR`
* `ROWID`
* `SMALLINT`
* `SQLXML`
* `STRUCT`
* `TIME`
* `TIME_WITH_TIMEZONE`
* `TIMESTAMP`
* `TIMESTAMP_WITH_TIMEZONE`
* `TINYINT`
* `VARBINARY`
* `VARCHAR`

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
