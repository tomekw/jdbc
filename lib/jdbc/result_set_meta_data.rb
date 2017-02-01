module JDBC
  class ResultSetMetaData
    def initialize(result_set:)
      @result_set = result_set
    end

    def parse
      columns_range.map do |index|
        Column.new(
          index: index,
          label: meta_data.get_column_label(index).to_sym,
          jdbc_type: meta_data.get_column_type_name(index).to_sym
        )
      end
    end

    private

    attr_reader :result_set

    def meta_data
      @meta_data ||= result_set.meta_data
    end

    def columns_range
      1..meta_data.column_count
    end
  end
end
