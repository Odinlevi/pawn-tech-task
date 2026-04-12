#include "systems/greenhouses-system.pwn"
#include "domain/greenhouse.pwn"

public TestAddGreenhouse(playerid)
{
    // This is a simple test function to add a greenhouse for the player who called it.

    // Find the first available slot for this player's greenhouse
    new greenhouseIndex = -1;
    for (new i = 0; i < MAX_GREENHOUSES; i++)
    {
        if (g_GreenhouseData[i][gh_ID] == -1) // Check if this slot is empty
        {
            greenhouseIndex = i;
            break;
        }
    }

    if (greenhouseIndex == -1)
    {
        SendClientMessage(playerid, -1, "No available slots for new greenhouses.");
        return 0;
    }

    // Initialize the greenhouse data for this new greenhouse
    g_GreenhouseData[greenhouseIndex][gh_ID] = 50;
    g_GreenhouseData[greenhouseIndex][gh_OwnerID] = playerid;
    g_GreenhouseData[greenhouseIndex][gh_PositionID] = GREENHOUSE_POSITION_1_ID; // For testing, we can just use the first position
    g_GreenhouseData[greenhouseIndex][gh_Pos][0] = GREENHOUSE_POSITION_1[0];
    g_GreenhouseData[greenhouseIndex][gh_Pos][1] = GREENHOUSE_POSITION_1[1];
    g_GreenhouseData[greenhouseIndex][gh_Pos][2] = GREENHOUSE_POSITION_1[2];
    

    SendClientMessage(playerid, -1, "Greenhouse added successfully!");

    return 1;
}
