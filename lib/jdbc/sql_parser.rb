# frozen_string_literal: true

module JDBC
  class SqlParser
    def initialize(sql:, bindings:)
      @sql = sql
      @bindings = bindings
    end

    def parse
      fail ArgumentError, sql_binding_mismatch_msg if sql_binding_mismatch?

      [jdbc_sql, binding_values]
    end

    private

    attr_reader :sql, :bindings

    JAVA_SQL_TYPES = %w[
      ARRAY
      BIGINT
      BINARY
      BIT
      BLOB
      BOOLEAN
      CHAR
      CLOB
      DATALINK
      DATE
      DECIMAL
      DISTINCT
      DOUBLE
      FLOAT
      INTEGER
      JAVA_OBJECT
      LONGNVARCHAR
      LONGVARBINARY
      LONGVARCHAR
      NCHAR
      NCLOB
      NULL
      NUMERIC
      NVARCHAR
      OTHER
      REAL
      REF
      REF_CURSOR
      ROWID
      SMALLINT
      SQLXML
      STRUCT
      TIME
      TIME_WITH_TIMEZONE
      TIMESTAMP
      TIMESTAMP_WITH_TIMEZONE
      TINYINT
      VARBINARY
      VARCHAR
    ].freeze
    private_constant :JAVA_SQL_TYPES

    COLON = ":"
    private_constant :COLON

    EMPTY_STRING = ""
    private_constant :EMPTY_STRING

    NONE = "(none)"
    private_constant :NONE

    JOIN_COMMA = ", "
    private_constant :JOIN_COMMA

    LEFT_PAREN = "("
    private_constant :LEFT_PAREN

    RIGHT_PAREN = ")"
    private_constant :RIGHT_PAREN

    PIPE = "|"
    private_constant :PIPE

    QUESTION_MARK = "?"
    private_constant :QUESTION_MARK

    SQL_TAGS_REGEX = /\s:(\w+)(?::(#{JAVA_SQL_TYPES.join(PIPE)}))?(?:[\s;]|\z)/
    private_constant :SQL_TAGS_REGEX

    TAG_CLEANUP_REGEX = /#{COLON}(#{JAVA_SQL_TYPES.join(PIPE)})?/
    private_constant :TAG_CLEANUP_REGEX

    def binding_names
      @binding_names ||= bindings.keys.map(&:to_sym)
    end

    def binding_values
      sql_tags.each_with_object([]) do |(tag, type), values|
        values << [bindings.fetch(tag)].flatten.map { |value| [value, type] }
      end.flatten(1)
    end

    def sql_tag_names
      @sql_tag_names ||= sql_tags.map(&:first)
    end

    def sql_tags
      @sql_tags ||= sql.scan(SQL_TAGS_REGEX).map do |(tag, type)|
        [tag.to_sym, type]
      end
    end

    def replace_sql_tags_regex
      @replace_sql_tags_regex ||= /:(#{sql_tags.map { |t| t.compact.join(COLON) }.join(PIPE) })/
    end

    def jdbc_sql
      sql_tags.empty? ? sql : parsed_sql
    end

    def parsed_sql
      sql.gsub(replace_sql_tags_regex) do |tag|
        tag_name = tag.gsub(TAG_CLEANUP_REGEX, EMPTY_STRING).to_sym
        tag_value = bindings.fetch(tag_name)

        if tag_value.is_a?(Array)
          LEFT_PAREN + tag_value.map { QUESTION_MARK }.join(JOIN_COMMA) + RIGHT_PAREN
        else
          QUESTION_MARK
        end
      end
    end

    def sql_binding_mismatch?
      binding_names.sort != sql_tag_names.uniq.sort
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
