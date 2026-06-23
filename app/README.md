# FinCorp Finance Tracker

A REST API + React frontend for logging and summarising spending by category. Built as the application vehicle for the **FinCorp "Immutable and Indestructible"** DevOps lab.

---

## How the app is structured

```
app/
├── src/            ← BACKEND — Node.js + Express API
│   ├── index.js        entry point, mounts routes, serves the built frontend
│   ├── db.js           PostgreSQL connection pool (reads env vars)
│   ├── transactions.js route handlers: POST/GET /transactions
│   └── schema.sql      CREATE TABLE — run once against the DB
│
├── client/         ← FRONTEND — Vite + React
│   ├── src/
│   │   ├── App.jsx
│   │   ├── index.css
│   │   ├── main.jsx
│   │   └── components/
│   │       ├── TransactionForm.jsx   add a transaction
│   │       ├── TransactionList.jsx   table of recent transactions
│   │       └── SummaryCards.jsx      spend totals with progress bars
│   ├── index.html
│   └── vite.config.js
│
├── tests/          ← TESTS — Jest + Supertest (DB fully mocked)
│   └── transactions.test.js
│
├── Dockerfile      multi-stage: builds React then packages into Express
└── package.json    backend deps: express, pg, dotenv
```

---

## Running the app

### Option A — Docker Compose (recommended)

One command starts the app **and** the database together. The React frontend and Express backend run as a **single container** — Express serves both the API and the built React files.

```bash
# from the FinCorp root (where docker-compose.yml lives)
docker compose up --build
```

Then open **http://localhost:3000** — you get the full React UI.

The database schema is applied automatically on first start (Postgres runs `schema.sql` from `docker-entrypoint-initdb.d`). No `.env` file needed.

To stop and remove everything (including the DB volume):

```bash
docker compose down -v
```

---

### Option B — Local development (hot-reload on both sides)

Use this when you want to edit code and see changes instantly without rebuilding Docker.

**Terminal 1 — Express backend**

```bash
cd app
cp .env.example .env    # fill in your local Postgres credentials
npm install
npm start               # running on http://localhost:3000
```

**Terminal 2 — Vite frontend**

```bash
cd app/client
npm install
npm run dev             # running on http://localhost:5173
```

Open **http://localhost:5173**. Vite automatically proxies `/transactions` and `/health` to Express on port 3000 — no CORS setup needed.

Apply the schema once:

```bash
psql -h localhost -U fincorp_user -d fincorp -f app/src/schema.sql
```

---

## How frontend + backend relate in each mode

| Mode           | Who serves the UI  | Who serves the API | Port to open          |
|----------------|--------------------|--------------------|-----------------------|
| Docker Compose | Express (built)    | Express            | http://localhost:3000 |
| Local dev      | Vite dev server    | Express            | http://localhost:5173 |

In Docker, the Dockerfile Stage 1 runs `vite build` and Stage 2 copies the output into the Express container. They run as one process on one port.

---

## Running tests

```bash
cd app
npm test
```

No database needed — `pg` is mocked. The test suite runs in CI without any infrastructure.

---

## API reference

| Method | Path                    | Description                          |
|--------|-------------------------|--------------------------------------|
| GET    | `/health`               | Health check — returns `{status:ok}` |
| POST   | `/transactions`         | Log a transaction                    |
| GET    | `/transactions`         | List all (newest first)              |
| GET    | `/transactions/summary` | Total spend grouped by category      |

**POST /transactions body**

```json
{ "category": "food", "amount": 25.50 }
```

---

## Environment variables

| Variable      | Default | Description           |
|---------------|---------|-----------------------|
| `DB_HOST`     | —       | PostgreSQL host        |
| `DB_PORT`     | `5432`  | PostgreSQL port        |
| `DB_NAME`     | —       | Database name          |
| `DB_USER`     | —       | Database user          |
| `DB_PASSWORD` | —       | Database password      |
| `PORT`        | `3000`  | Express listen port    |

Docker Compose sets all of these automatically.
