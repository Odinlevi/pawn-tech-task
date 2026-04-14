# Technical task for Vibe Games.

## Description: 
A server-side app made with open.mp that controls the behavior of greenhouses managed by players.

## Initialization steps:
1. Add the open.mp server executables from the [open.mp repository](https://github.com/openmultiplayer/open.mp).

1. Initialize the SQLite schema:
`sqlite3 scriptfiles/server_realtime_data.db < sql/init_db.sql`

2. Add the [streamer](https://github.com/samp-incognito/samp-streamer-plugin) and [sscanf](https://github.com/Y-Less/sscanf) plugins.

## Features:
0. By default, the server runs on `127.0.0.1:7777`.

1. Upon player login, the player is initialized in the local database.

2. The player can run `/create_gh [1-5]` to create one of five possible greenhouses with "tomatoes". These are fully grown in 600 seconds (10 minutes).

3. The player can run `/upgrade_gh [1-5]` to upgrade them. This will reduce the growth time by half.

4. Growth will be paused if the player is outside a `50.0`-unit range.

5. The player will be able to witness the growth of the greenhouse by standing near it. The growth will be visible through additional boxes spawning on top of the greenhouse. Each box will represent `20%` of the total growth.

6. Greenhouse changes will be pushed to the database once the player leaves the server.
