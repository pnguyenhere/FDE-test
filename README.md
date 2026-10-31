# Bright Path – Daily Schedule Dashboard

## Database Setup and Seed Data

The application uses SQLite. Follow these steps to create the database and load the provided export as seed data.

Run the commands from the project root directory.

### 1. Create the database

Execute `init.sql` to initialize the database schema:

```bash
python -c "import sqlite3; conn = sqlite3.connect('bright_path.db'); conn.executescript(open('init.sql', encoding='utf-8').read()); conn.close(); print('Database created successfully.')"
```

### 2. Import the seed data

Execute `import.sql` to load the exported data into the database:

```bash
python -c "import sqlite3; conn = sqlite3.connect('bright_path.db'); conn.executescript(open('import.sql', encoding='utf-8').read()); conn.close(); print('Import seed data successfully.')"
```

## Running the Application

### 1. Create a virtual environment

```bash
python -m venv .venv
```

Alternatively, on systems where `py` is available:

```bash
py -m venv .venv
```

### 2. Activate the virtual environment

**GitHub Codespaces (Linux):**

```bash
source .venv/bin/activate
```

**Local environment (Windows):**

```powershell
.venv\Scripts\Activate
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Start the application

**GitHub Codespaces (Linux):**

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

**Local environment (Windows):**

```bash
uvicorn app.main:app --reload
```

### 5. Access the dashboard

Once the application has started, open the following URL:

- **Local:** http://127.0.0.1:8000/
- **GitHub Codespaces:** Open port `8000` using the Codespaces Ports tab and follow the forwarded URL.

The dashboard defaults to March 04, 2026. Use the date picker to view the schedule for another date.

## Notes

- Run the database initialization and seed import commands only once when setting up a fresh database.
- If you need to reset the database, remove `bright_path.db` and repeat the database setup steps.
- Run all commands from the project root directory.