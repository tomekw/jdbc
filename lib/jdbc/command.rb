module JDBC
  class Command < Action
    private

    def result_set
      @result_set ||=
        begin
          statement.execute_update
          statement.get_generated_keys
        end
    end

    def statement
      @statement ||= PreparedStatementBuilder.for_command(
        connection: connection,
        jdbc_sql: jdbc_sql,
        binding_values: binding_values
      )
    end
  end
end
