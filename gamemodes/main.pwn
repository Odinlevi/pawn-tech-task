#include <open.mp>

#include "persistence/server-db-context.pwn"

#include "systems/server-tick-system.pwn"
#include "systems/greenhouses-system.pwn"

#include "commands/on-player-connected-command.pwn"
#include "commands/on-player-disconnected-command.pwn"

// #include "tests/test-add-gh.pwn"
// #include "persistence/repositories/user-repository.pwn"
// #include "domain/dtos/repository-responses/user/find-or-create-user-rep-response.pwn"

// This is the entry point for the server, executed once when the server starts.
public OnGameModeInit()
{
    print("Greenhouse Server Started");

    // Sets a "tick" every 20 milliseconds (50 times per second)
    SetTimer("ServerTick", SERVER_TICK_INTERVAL, true);
    
    // intialize main db
    if (!ServerDBContext_InitializeDatabase("server_realtime_data.db"))
    {
        print("Failed to initialize database!");
        return 0;
    }

    // Disable the default GTA SA single-player map objects
    DisableInteriorEnterExits();

    // Add one default character skin (CJ - Skin ID 0) so the server doesn't crash
    // Parameters: SkinID, X, Y, Z, Angle, Weapon1, Ammo1, Weapon2, Ammo2, Weapon3, Ammo3
    AddPlayerClass(0, 0.0, 0.0, 3.0, 0.0, 0, 0, 0, 0, 0, 0);

    InitializeGreenhouseData();


    // // TEST AREA
    // new dbResponse[E_USER_FIND_OR_CREATE_REP_RESPONSE];
    // dbResponse = UserRepository_FindOrCreateUser("odi");

    // printf("UserRepository_FindOrCreateUser response: ID=%d, Username=%s", dbResponse[u_ID], dbResponse[u_Username]);
    // // END
    
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
    
    // Set their virtual world to 0 (the default dimension)
    SetPlayerVirtualWorld(playerid, 0);
    
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
    ServerDBContext_CloseDatabase();

    // todo: persist any data in memory that hasn't been persisted yet, such as greenhouses growth progress.
    // it's important since OnPlayerDisconnect won't be triggered if the server is stopped.

    return 1;
}

forward ServerTick();
public ServerTick()
{
    ServerTickSystemFireTick();
}
