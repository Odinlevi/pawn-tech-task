#include <open.mp>

#include "systems/server-tick-system.pwn"
#include "systems/greenhouses-system.pwn"

#include "tests/test-add-gh.pwn"

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
    
    return 1;
}

// Triggered when a player connects to the server
public OnPlayerConnect(playerid)
{
    // Send a message to the chat
    SendClientMessage(playerid, -1, "Welcome to the Greenhouse Test Server!");

    TestAddGreenhouse(playerid);

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


forward ServerTick();
public ServerTick()
{
    ServerTickSystemFireTick();
}
