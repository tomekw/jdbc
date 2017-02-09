require "spec_helper"

RSpec.describe JDBC::SqlParser do
  subject(:parser) { described_class.new(sql, bindings) }

  context "when no bindings for a simple SQL query provided" do
    let(:sql) { "SELECT foo FROM things WHERE bar = 1" }
    let(:bindings) { {} }

    let(:parsed_query) { [sql, []] }

    it "returns the query as-is" do
      expect(parser.parse).to eq parsed_query
    end
  end

  context "when number of bindings doesn't match the number of tags" do
    let(:sql) { "SELECT foo FROM things WHERE bar = :bar" }
    let(:bindings) { {} }
    let(:error_message) do
      "SQL query bindings mismatch, given: (none), expected: bar"
    end

    it "raises error" do
      expect do
        parser.parse
      end.to raise_error(ArgumentError, error_message)
    end
  end
end
