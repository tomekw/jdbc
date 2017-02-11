# frozen_string_literal: true

module JDBC
  class SqlParser
    def initialize(sql, bindings = {})
      @sql = sql
      @bindings = bindings
    end

    def parse
      fail ArgumentError, sql_binding_mismatch_msg if sql_binding_mismatch?

      [parsed_sql, binding_values]
    end

    private

    attr_reader :sql, :bindings

    REPLACE_SQL_TAGS_REGEXP = /:\w+/
    private_constant :REPLACE_SQL_TAGS_REGEXP

    SQL_TAGS_REGEXP = /:(\w+)(?:[\s;]|\z)/
    private_constant :SQL_TAGS_REGEXP

    NONE = "(none)"
    private_constant :NONE

    QUESTION_MARK = "?"
    private_constant :QUESTION_MARK

    def binding_names
      @binding_names ||= bindings.keys.map(&:to_sym)
    end

    def binding_values
      sql_tag_names
        .each_with_object([]) { |b, values| values << bindings.fetch(b) }
        .flatten
    end

    def sql_tag_names
      @sql_tag_names ||= sql.scan(SQL_TAGS_REGEXP).flatten.map(&:to_sym)
    end

    def parsed_sql
      sql.gsub(REPLACE_SQL_TAGS_REGEXP, QUESTION_MARK)
    end

    def sql_binding_mismatch?
      binding_names.sort != sql_tag_names.sort
    end

    def sql_binding_mismatch_msg
      given = binding_names.join(", ")
      expected = sql_tag_names.join(", ")

      given_msg = given.empty? ? NONE : given
      expected_msg = expected.empty? ? NONE : expected

      "SQL query bindings mismatch, given: #{given_msg}, expected: #{expected_msg}"
    end
  end
end
