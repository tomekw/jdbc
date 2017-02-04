module JDBC
  class Column
    attr_reader :index, :label, :jdbc_type

    def initialize(index:, label:, jdbc_type:)
      @index = index
      @label = label
      @jdbc_type = jdbc_type
    end

    def coerce_proc
      Coercions.public_send(COERCIONS_MAP.fetch(jdbc_type, :identity))
    end

    COERCIONS_MAP = {
      uuid: :to_s,
      timestamp: :to_date_time
    }.freeze
    private_constant :COERCIONS_MAP
  end
end
