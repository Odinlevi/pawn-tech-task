-- Enable Foreign Key constraints
PRAGMA foreign_keys = ON;

-- Create User table
CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY,
    username      TEXT NOT NULL UNIQUE
);

-- Create Greenhouse table
CREATE TABLE IF NOT EXISTS greenhouses (
    id                    INTEGER PRIMARY KEY,
    user_id               INTEGER NOT NULL,
    position_id           INTEGER NOT NULL,
    grow_progress_seconds INTEGER NOT NULL DEFAULT 0,
    is_boosted            INTEGER NOT NULL CHECK (is_boosted IN (0, 1)) DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- Optimization: Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_greenhouses_user_id ON greenhouses(user_id);
