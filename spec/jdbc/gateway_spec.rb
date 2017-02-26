require "spec_helper"

RSpec.describe JDBC::Gateway, type: :db do
  subject(:gateway) { described_class.new(connection_pool: connection_pool) }

  describe "#ddl" do
    let(:result) { gateway.ddl(sql, bindings) }

    let(:bindings) { {} }

    context "when DDL command provided" do
      let(:sql) { "CREATE INDEX some_text_idx ON things(some_text)" }
      let(:bindings) { {} }

      after do
        gateway.ddl("DROP INDEX IF EXISTS some_text_idx")
      end

      it "adds an index" do
        expect(result).to eq true
      end
    end
  end

  describe "#command" do
    let(:result) { gateway.command(sql, bindings) }

    def things_count
      gateway.query("SELECT COUNT(*) AS count FROM things").first.fetch(:count)
    end

    context "when simple INSERT without bindings" do
      let(:sql) do
        <<-SQL
          INSERT INTO things (
            some_id, some_text, some_number, some_timestamp, some_nullable_string
          ) VALUES (
            'eaabc03b-7cb0-4ecb-a335-d90eacb03513'::uuid, 'Insert', 42, '2017-02-02 10:00:00', 'Me'
          )
        SQL
      end
      let(:bindings) { {} }

      let(:expected_result) do
        [
          {
            some_id: "eaabc03b-7cb0-4ecb-a335-d90eacb03513",
            some_text: "Insert",
            some_number: 42,
            some_timestamp: DateTime.new(2017, 2, 2, 10, 0, 0),
            some_nullable_string: "Me"
          }
        ]
      end

      it "inserts the record" do
        expect(result).to eq expected_result
      end

      it "changes the things count" do
        expect do
          result
        end.to change { things_count }.by(1)
      end
    end

    context "when bindings provided" do
      let(:sql) do
        <<-SQL
          INSERT INTO things (
            some_id, some_text, some_number, some_timestamp, some_nullable_string
          ) VALUES (
            'eaabc03b-7cb0-4ecb-a335-d90eacb03513'::uuid, :some_text, :some_number, '2017-02-02 10:00:00', :some_nullable_string
          )
        SQL
      end
      let(:bindings) do
        {
          some_text: "Insert",
          some_number: 42,
          some_nullable_string: nil
        }
      end

      let(:expected_result) do
        [
          {
            some_id: "eaabc03b-7cb0-4ecb-a335-d90eacb03513",
            some_text: "Insert",
            some_number: 42,
            some_timestamp: DateTime.new(2017, 2, 2, 10, 0, 0),
            some_nullable_string: nil
          }
        ]
      end

      it "inserts the record" do
        expect(result).to eq expected_result
      end

      it "changes the things count" do
        expect do
          result
        end.to change { things_count }.by(1)
      end
    end

    context "when UPDATE requested" do
      let(:sql) { "UPDATE things SET some_nullable_string = :nullable WHERE some_number > :zero" }
      let(:bindings) do
        {
          nullable: "Foo",
          zero: 0
        }
      end

      let(:expected_result) do
        [
          {
            some_id: "a5142003-9453-4fed-ab90-f0bc47db6404",
            some_text: "Hello",
            some_number: 42,
            some_timestamp: DateTime.new(2017, 2, 1, 10, 0, 0),
            some_nullable_string: "Foo"
          },
          {
            some_id: "1f87e249-d90a-44c7-a986-51a77cdb01f4",
            some_text: "Foo",
            some_number: 1,
            some_timestamp: DateTime.new(2017, 2, 10, 14, 0, 0),
            some_nullable_string: "Foo"
          }
        ]
      end

      it "updates the record" do
        expect(result).to eq expected_result
      end

      it "doesn't change the things count" do
        expect do
          result
        end.not_to change { things_count }
      end
    end

    context "when DELETE requested" do
      let(:sql) { "DELETE FROM things WHERE some_text = :text AND some_number > :ten" }
      let(:bindings) do
        {
          text: "Hello",
          ten: 10
        }
      end

      let(:expected_result) do
        [
          {
            some_id: "a5142003-9453-4fed-ab90-f0bc47db6404",
            some_text: "Hello",
            some_number: 42,
            some_timestamp: DateTime.new(2017, 2, 1, 10, 0, 0),
            some_nullable_string: "World"
          }
        ]
      end

      it "deletes the record" do
        expect(result).to eq expected_result
      end

      it "changes the things count" do
        expect do
          result
        end.to change { things_count }.by(-1)
      end
    end
  end

  describe "#query" do
    let(:seeded_records) do
      [
        {
          some_id: "a5142003-9453-4fed-ab90-f0bc47db6404",
          some_text: "Hello",
          some_number: 42,
          some_timestamp: DateTime.new(2017, 2, 1, 10, 0, 0),
          some_nullable_string: "World"
        },
        {
          some_id: "1f87e249-d90a-44c7-a986-51a77cdb01f4",
          some_text: "Foo",
          some_number: 1,
          some_timestamp: DateTime.new(2017, 2, 10, 14, 0, 0),
          some_nullable_string: nil
        }
      ]
    end

    let(:results) { gateway.query(sql, bindings) }

    context "when asking for all seeded records" do
      let(:sql) { "SELECT * FROM things ORDER BY some_timestamp" }
      let(:bindings) { {} }
      let(:expected_results) { seeded_records }

      it "returns them" do
        expect(results).to eq expected_results
      end
    end

    context "when asking for arbitrary values" do
      let(:sql) { "SELECT 1 AS one, TRUE AS true, FALSE AS false" }
      let(:bindings) { {} }
      let(:expected_results) { [{ one: 1, true: true, false: false }] }

      it "returns them" do
        expect(results).to eq expected_results
      end
    end

    context "when asking for a count as a query" do
      let(:sql) { "SELECT COUNT(*) AS count FROM things" }
      let(:bindings) { {} }
      let(:expected_results) { [{ count: 2 }] }

      it "returns count as an array" do
        expect(results).to eq expected_results
      end
    end

    context "when simple where with bindings" do
      let(:sql) { "SELECT * FROM things WHERE some_text = :some_text" }
      let(:bindings) { { some_text: "Hello" } }
      let(:expected_results) { seeded_records.select { |r| r.fetch(:some_text) == "Hello" } }

      it "returns the correct rows" do
        expect(results).to eq expected_results
      end
    end

    context "when simple where with bindings (type annotated)" do
      let(:sql) { "SELECT * FROM things WHERE some_text = :some_text:VARCHAR" }
      let(:bindings) { { some_text: "Hello" } }
      let(:expected_results) { seeded_records.select { |r| r.fetch(:some_text) == "Hello" } }

      it "returns the correct rows" do
        expect(results).to eq expected_results
      end
    end

    context "when number of bindings doesn't match the number of tags" do
      let(:sql) { "SELECT foo FROM things WHERE bar = :bar" }
      let(:bindings) { {} }
      let(:error_message) { "SQL query bindings mismatch, given: (none), expected: bar" }

      it "raises error" do
        expect do
          results
        end.to raise_error(ArgumentError, error_message)
      end
    end

    context "when simple where with NULL bindings" do
      let(:sql) do
        <<-SQL
          SELECT * FROM things WHERE some_nullable_string = :nullable:VARCHAR
          OR (some_nullable_string IS NULL AND :nullable:VARCHAR IS NULL)
        SQL
      end

      let(:bindings) { { nullable: nil } }
      let(:expected_results) { seeded_records.select { |r| r.fetch(:some_nullable_string).nil? } }

      it "returns the correct rows" do
        expect(results).to eq expected_results
      end
    end
  end
end
