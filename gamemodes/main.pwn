#include <open.mp>
#include <sscanf2>

// #include "persistence/server-db-context.pwn"
#include "persistence/mysql-server-db-context.pwn"

#include "systems/server-tick-system.pwn"
#include "systems/greenhouses-system.pwn"

#include "commands/on-player-connected-command.pwn"
#include "commands/on-player-disconnected-command.pwn"
#include "commands/on-player-created-gh-command.pwn"
#include "commands/on-player-upgraded-gh-command.pwn"

// This is the entry point for the server, executed once when the server starts.
public OnGameModeInit()
{
    print("Greenhouse Server Started");

    // Sets a "tick" every 20 milliseconds (50 times per second)
    SetTimer("ServerTick", SERVER_TICK_INTERVAL, true);

    // Disable the default GTA SA single-player map objects
    DisableInteriorEnterExits();

    // Add one default character skin (CJ - Skin ID 0) so the server doesn't crash
    // Parameters: SkinID, X, Y, Z, Angle, Weapon1, Ammo1, Weapon2, Ammo2, Weapon3, Ammo3
    AddPlayerClass(0, 0.0, 0.0, 3.0, 0.0, 0, 0, 0, 0, 0, 0);

    InitializeGreenhouseData();

    MySQLServerDBContext_InitializeDatabase();

    return 1;
}


// Triggered when a player connects to the server
public OnPlayerConnect(playerid)
{
    OnPlayerConnectedCommand(playerid);

    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetSpawnInfo(playerid, NO_TEAM, 0, 0.0, 0.0, 3.0, 0.0, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    return 1;
} 

// Triggered the moment the player actually spawns into the world
public OnPlayerSpawn(playerid)
{
    // Teleport the player to the center of the map (Blueberry Farm)
    // Z is 3.0 so they don't fall through the ground
    SetPlayerPos(playerid, 0.0, 0.0, 3.0);
    
    // Set their interior to the outside world (Interior 0)
    SetPlayerInterior(playerid, 0);
    
    // Set their virtual world to their player ID (unique dimension)
    SetPlayerVirtualWorld(playerid, playerid);
    
    // Give them a flat camera angle behind the player
    SetCameraBehindPlayer(playerid);

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    OnPlayerDisconnectedCommand(playerid);
    return 1;
}

public OnGameModeExit()
{
    print("Greenhouse Server Stopped");
    MySQLServerDBContext_CloseDatabase();

    // todo: persist any data in memory that hasn't been persisted yet, such as greenhouses growth progress.
    // it's important since OnPlayerDisconnect won't be triggered if the server is stopped.

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    // --- /create_gh [1-5] ---
    if (!strcmp(cmdtext, "/create_gh", true, 10))
    {
        new gh_pos;
        // cmdtext + 10 skips "/create_gh" (10 chars) to get to the parameters
        if (sscanf(cmdtext[10], "i", gh_pos)) 
            return SendClientMessage(playerid, -1, "Usage: /create_gh [1-5]");

        if (gh_pos < 1 || gh_pos > 5) 
            return SendClientMessage(playerid, -1, "Invalid position. Use 1 to 5.");

        return OnPlayerCreatedGhCommand(playerid, gh_pos);
    }

    // --- /upgrade_gh [1-5] ---
    if (!strcmp(cmdtext, "/upgrade_gh", true, 11))
    {
        new gh_pos;
        // cmdtext + 11 skips "/upgrade_gh" (11 chars)
        if (sscanf(cmdtext[11], "i", gh_pos)) 
            return SendClientMessage(playerid, -1, "Usage: /upgrade_gh [1-5]");

        if (gh_pos < 1 || gh_pos > 5) 
            return SendClientMessage(playerid, -1, "Invalid position. Use 1 to 5.");

        return OnPlayerUpgradedGhCommand(playerid, gh_pos);
    }

    return 0; // Return 0 to allow the command to be processed by other handlers, or 1 to block it.
}

forward ServerTick();
public ServerTick()
{
    ServerTickSystemFireTick();
}
