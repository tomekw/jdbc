CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS things;

CREATE TABLE things (
  some_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  some_text TEXT NOT NULL DEFAULT '',
  some_number INTEGER NOT NULL,
  some_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  some_nullable_string VARCHAR(32)
);
