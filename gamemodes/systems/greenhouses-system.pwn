#if defined _greenhouses_system_included
    #endinput
#endif
#define _greenhouses_system_included

#include "domain/greenhouse.pwn"

#define TOTAL_CHUNKS 50
#define GREENHOUSES_PER_CHUNK (MAX_GREENHOUSES / TOTAL_CHUNKS)

// todo: there is a different way to store this. needs to be optimized before finishing:
// new g_GreenhouseDataPerPlayer[MAX_PLAYERS][MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_DATA];
new g_GreenhouseData[MAX_GREENHOUSES][E_GREENHOUSE_DATA];

// todo: another optimization is to keep track of which greenhouses are active and only iterate over those. 
// need to expose functions to add/remove from that active list when creating greenhouses, and also when players connect/disconnect.
// might be a good idea to move cached logic to the dedicated cached domain so repositories could interact with it without needing
// to include greenhouses systems.

new g_CurrentChunk = 0;

stock InitializeGreenhouseData()
{
    for(new i = 0; i < MAX_GREENHOUSES; i++)
    {
        InitializeEmptyGreenhouse(g_GreenhouseData[i]);
    }
}

stock ProcessNextGreenhouseChunk()
{
    // Calculate the boundaries for this specific chunk
    new startIdx = g_CurrentChunk * GREENHOUSES_PER_CHUNK;
    new endIdx = startIdx + GREENHOUSES_PER_CHUNK;

    // Iterate ONLY over this chunk
    for(new i = startIdx; i < endIdx; i++)
    {
        if (g_GreenhouseData[i][gh_ID] != -1) // Check if this greenhouse slot is active
        {
            // Check if the player is nearby (within 50 units)
            new Float:distance = GetPlayerDistanceFromPoint(g_GreenhouseData[i][gh_OwnerID],
                                                          g_GreenhouseData[i][gh_Pos][0], 
                                                          g_GreenhouseData[i][gh_Pos][1], 
                                                          g_GreenhouseData[i][gh_Pos][2]);

            

            // this can be optimized futher by caching the distance check result and only updating it every few seconds, but for now we check it every tick
            if (distance <= 50.0)
            {
                // Player is nearby, update growth progress
                g_GreenhouseData[i][gh_IsPaused] = false; // Unpause growth (rn is redundant, a subject for future optimization)

                // Check if growth is complete
                if (g_GreenhouseData[i][gh_Progress] >= GREENHOUSE_MAX_PROGRESS)
                {
                    g_GreenhouseData[i][gh_Progress] = GREENHOUSE_MAX_PROGRESS; // Cap progress at max
                    continue; // Skip further processing if growth is complete
                }

                g_GreenhouseData[i][gh_Progress] += GREENHOUSE_UPDATE_INTERVAL / 1000; // Increment progress in seconds
                
                // todo: Add visual growth stage updates here based on g_GreenhouseData[i][gh_Progress] and GREENHOUSE_PROGRESS_STAGES
                printf("Greenhouse ID %d Progress: %d seconds", g_GreenhouseData[i][gh_ID], g_GreenhouseData[i][gh_Progress]);
            }
            else
            {
                // Player is not nearby, pause growth (rn is redundant, a subject for future optimization)
                g_GreenhouseData[i][gh_IsPaused] = true;
            }
        }
    }

    // Move to the next chunk for the next timer tick
    g_CurrentChunk++;
    
    // Reset if we hit the end
    if(g_CurrentChunk >= TOTAL_CHUNKS)
    {
        g_CurrentChunk = 0; 
    }
}

stock GreenhouseSystem_AddGreenhouse(gh_data[E_GREENHOUSE_DATA]) // might be wise to use a reference, no time for that rn.
{
    for(new i = 0; i < MAX_GREENHOUSES; i++)
    {
        if (g_GreenhouseData[i][gh_ID] == -1) // Find the first empty slot
        {
            // Copy the provided greenhouse data into our main array
            g_GreenhouseData[i][gh_ID] = gh_data[gh_ID];
            g_GreenhouseData[i][gh_OwnerID] = gh_data[gh_OwnerID];
            g_GreenhouseData[i][gh_PositionID] = gh_data[gh_PositionID];
            g_GreenhouseData[i][gh_Pos][0] = gh_data[gh_Pos][0];
            g_GreenhouseData[i][gh_Pos][1] = gh_data[gh_Pos][1];
            g_GreenhouseData[i][gh_Pos][2] = gh_data[gh_Pos][2];
            g_GreenhouseData[i][gh_Progress] = gh_data[gh_Progress];
            g_GreenhouseData[i][gh_IsUpgraded] = gh_data[gh_IsUpgraded];
            g_GreenhouseData[i][gh_IsPaused] = gh_data[gh_IsPaused];
            return true; // Successfully added
        }
    }
    return false; // No space available
}

stock GreenhouseSystem_GetGreenhousesByPlayerID(playerID, outputGreenhouses[MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_DATA])
{
    new count = 0;
    for(new i = 0; i < MAX_GREENHOUSES && count < MAX_GREENHOUSES_PER_PLAYER; i++)
    {
        if (g_GreenhouseData[i][gh_ID] != -1 && g_GreenhouseData[i][gh_OwnerID] == playerID)
        {
            // Copy greenhouse data to output array
            outputGreenhouses[count][gh_ID] = g_GreenhouseData[i][gh_ID];
            outputGreenhouses[count][gh_OwnerID] = g_GreenhouseData[i][gh_OwnerID];
            outputGreenhouses[count][gh_PositionID] = g_GreenhouseData[i][gh_PositionID];
            outputGreenhouses[count][gh_Pos][0] = g_GreenhouseData[i][gh_Pos][0];
            outputGreenhouses[count][gh_Pos][1] = g_GreenhouseData[i][gh_Pos][1];
            outputGreenhouses[count][gh_Pos][2] = g_GreenhouseData[i][gh_Pos][2];
            outputGreenhouses[count][gh_Progress] = g_GreenhouseData[i][gh_Progress];
            outputGreenhouses[count][gh_IsUpgraded] = g_GreenhouseData[i][gh_IsUpgraded];
            outputGreenhouses[count][gh_IsPaused] = g_GreenhouseData[i][gh_IsPaused];
            count++;
        }
    }
    return count; // Return the number of greenhouses found for this player
}

stock GreenhouseSystem_DeleteGreenhousesByPlayerID(playerID)
{
    for(new i = 0; i < MAX_GREENHOUSES; i++)
    {
        if (g_GreenhouseData[i][gh_ID] != -1 && g_GreenhouseData[i][gh_OwnerID] == playerID)
        {
            InitializeEmptyGreenhouse(g_GreenhouseData[i]); // Reset the greenhouse slot to empty
        }
    }
}
