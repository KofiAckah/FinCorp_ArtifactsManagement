CREATE TABLE IF NOT EXISTS transactions (
  id          SERIAL PRIMARY KEY,
  description VARCHAR(255)   NOT NULL,
  category    VARCHAR(100)   NOT NULL,
  amount      NUMERIC(12, 2) NOT NULL,
  created_at  TIMESTAMP      DEFAULT NOW()
);
