require "spec_helper"

RSpec.describe JDBC::SqlParser do
  subject(:parser) { described_class.new(sql: sql, bindings: bindings) }

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

  context "when simple bindings provided" do
    let(:sql) { "SELECT * FROM things WHERE bar = :bar AND foo = :foo" }
    let(:bindings) { { foo: "foo", bar: 1 } }

    let(:expected_result) do
      [
        "SELECT * FROM things WHERE bar = ? AND foo = ?",
        [1, "foo"]
      ]
    end

    it "returns the parsed query with bindings in the correct order" do
      expect(parser.parse).to eq expected_result
    end
  end

  context "when IN bindings provided" do
    let(:sql) { "SELECT * FROM things WHERE bar IN :bar_ids AND foo = :foo" }
    let(:bindings) { { foo: "foo", bar_ids: [4, 2] } }

    let(:expected_result) do
      [
        "SELECT * FROM things WHERE bar IN (?, ?) AND foo = ?",
        [4, 2, "foo"]
      ]
    end

    it "returns the parsed query with bindings in the correct order" do
      expect(parser.parse).to eq expected_result
    end
  end
end
