-- Create the database (safely) and switch into it
CREATE DATABASE IF NOT EXISTS `tech_task_server`;
USE `tech_task_server`;

-- Create User table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE
);

-- Create Greenhouse table
CREATE TABLE IF NOT EXISTS greenhouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    position_id INT NOT NULL,
    grow_progress_seconds INT NOT NULL DEFAULT 0,
    is_boosted TINYINT(1) NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Optimization: Index for faster lookups
CREATE INDEX idx_greenhouses_user_id ON greenhouses(user_id);
