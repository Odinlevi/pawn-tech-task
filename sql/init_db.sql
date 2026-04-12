-- Enable Foreign Key constraints
PRAGMA foreign_keys = ON;

-- Create Player table
CREATE TABLE IF NOT EXISTS players (
    id            INTEGER PRIMARY KEY,
    player_name   TEXT NOT NULL UNIQUE
);

-- Create Greenhouse table
CREATE TABLE IF NOT EXISTS greenhouses (
    id                    INTEGER PRIMARY KEY,
    player_id             INTEGER NOT NULL,
    position_id           INTEGER NOT NULL,
    grow_progress_seconds INTEGER NOT NULL DEFAULT 0,
    is_boosted            INTEGER NOT NULL CHECK (is_boosted IN (0, 1)) DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
);

-- Optimization: Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_greenhouses_player_id ON greenhouses(player_id);