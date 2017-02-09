# frozen_string_literal: true

module JDBC
  class SqlParser
    def initialize(sql, bindings = {})
      @sql = sql
      @bindings = bindings
    end

    def parse
      fail ArgumentError, sql_binding_mismatch if binding_names != sql_tag_names

      [sql, []]
    end

    private

    attr_reader :sql, :bindings

    SQL_TAGS_REGEXP = /:(\w+)(?:[\s;]|\z)/
    private_constant :SQL_TAGS_REGEXP

    NONE = "(none)"
    private_constant :NONE

    def binding_names
      @binding_names ||= bindings.keys.map(&:to_sym)
    end

    def sql_tag_names
      @sql_tag_names ||= sql.scan(SQL_TAGS_REGEXP).flatten.map(&:to_sym)
    end

    def sql_binding_mismatch
      given = binding_names.join(", ")
      expected = sql_tag_names.join(", ")

      given_msg = given.empty? ? NONE : given
      expected_msg = expected.empty? ? NONE : expected

      "SQL query bindings mismatch, given: #{given_msg}, expected: #{expected_msg}"
    end
  end
end
