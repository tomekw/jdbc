require "pry"
require "simplecov"

SimpleCov.start do
  add_group "Library", "lib"
  add_filter "/spec/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "jdbc"

if ENV["CIRCLE_ARTIFACTS"]
  SimpleCov.coverage_dir(File.join(ENV["CIRCLE_ARTIFACTS"], "coverage"))
end

require "jdbc/postgres"
Jdbc::Postgres.load_driver

require "hucpa"

def connection_pool
  @connection_pool ||= Hucpa::ConnectionPool.new(
    adapter: :postgresql,
    database_name: "jdbc",
    password: "jdbc",
    server_name: "postgres",
    username: "jdbc"
  )
end

setup_sql = File.read("spec/support/sql/setup.sql")
seed_sql = File.read("spec/support/sql/seed.sql")

RSpec.configure do |config|
  config.order = :random

  config.before(:all) do
    connection_pool.with_connection do |connection|
      connection.create_statement.execute_update(setup_sql)
      connection.create_statement.execute_update(seed_sql)
    end
  end
end
