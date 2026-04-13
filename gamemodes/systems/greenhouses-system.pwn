#if defined _greenhouses_system_included
    #endinput
#endif
#define _greenhouses_system_included

#include <streamer>
#include "domain/greenhouse.pwn"
#include "fabrics/greenhouse-object-fabric.pwn"

#define TOTAL_CHUNKS 50
#define GREENHOUSES_PER_CHUNK (MAX_GREENHOUSES / TOTAL_CHUNKS)
#define GREENHOUSE_PROGRESS_PER_STAGE (GREENHOUSE_MAX_PROGRESS / GREENHOUSE_PROGRESS_STAGES)
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
            // Check if the player is nearby (within GREENHOUSE_DISTANCE_THRESHOLD)
            new Float:distance = GetPlayerDistanceFromPoint(g_GreenhouseData[i][gh_OwnerID],
                                                          g_GreenhouseData[i][gh_Pos][0], 
                                                          g_GreenhouseData[i][gh_Pos][1], 
                                                          g_GreenhouseData[i][gh_Pos][2]);

            printf("Processing Greenhouse ID %d for Player %d, Distance: %.2f", g_GreenhouseData[i][gh_ID], g_GreenhouseData[i][gh_OwnerID], distance);
            

            // this can be optimized futher by caching the distance check result and only updating it every few seconds, but for now we check it every tick
            if (distance <= GREENHOUSE_DISTANCE_THRESHOLD)
            {
                // Player is nearby, update growth progress
                g_GreenhouseData[i][gh_IsPaused] = false; // Unpause growth (rn is redundant, a subject for future optimization)

                // Check if growth is complete
                if (g_GreenhouseData[i][gh_Progress] >= GREENHOUSE_MAX_PROGRESS)
                {
                    g_GreenhouseData[i][gh_Progress] = GREENHOUSE_MAX_PROGRESS; // Cap progress at max
                    continue; // Skip further processing if growth is complete
                }

                new currentStage = g_GreenhouseData[i][gh_Progress] / GREENHOUSE_PROGRESS_PER_STAGE;

                if (!g_GreenhouseData[i][gh_IsUpgraded])
                {
                    g_GreenhouseData[i][gh_Progress] += GREENHOUSE_UPDATE_INTERVAL / 1000; // Increment progress in seconds
                }
                else 
                {
                    g_GreenhouseData[i][gh_Progress] += (GREENHOUSE_UPDATE_INTERVAL / 1000) * GREENHOUSE_UPGRADE_PROGRESS_MULTIPLIER; // Upgraded greenhouses grow twice as fast
                }

                new newStage = g_GreenhouseData[i][gh_Progress] / GREENHOUSE_PROGRESS_PER_STAGE;
                
                if (newStage > currentStage && newStage < GREENHOUSE_PROGRESS_STAGES) // Stage has advanced, but growth is not yet complete
                {
                    new currentStage = g_GreenhouseData[i][gh_Progress] / GREENHOUSE_PROGRESS_PER_STAGE;
                    if (currentStage < GREENHOUSE_PROGRESS_STAGES) // clumped on progress == GREENHOUSE_MAX_PROGRESS. no visual effects on the full growth.
                    {
                        printf("Greenhouse ID %d has advanced to stage %d", g_GreenhouseData[i][gh_ID], currentStage);
                        GhObjFabric_SpawnOnStage(g_GreenhouseData[i][gh_OwnerID], 0, g_GreenhouseData[i], currentStage);
                        printf("Spawned dynamic objects for greenhouse ID %d at stage %d", g_GreenhouseData[i][gh_ID], currentStage);
                    } 
                }
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
            g_GreenhouseData[i][gh_DynamicObjectIDs] = gh_data[gh_DynamicObjectIDs];
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
            outputGreenhouses[count][gh_DynamicObjectIDs] = g_GreenhouseData[i][gh_DynamicObjectIDs];
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
            GreenhouseSystem_DeleteDynamicObjectsForGreenhouse(g_GreenhouseData[i]); // Delete dynamic objects for this greenhouse
            InitializeEmptyGreenhouse(g_GreenhouseData[i]); // Reset the greenhouse slot to empty
        }
    }
}

stock GreenhouseSystem_DeleteDynamicObjectsForGreenhouse(gh_data[E_GREENHOUSE_DATA])
{
    for (new i = 0; i < GREENHOUSE_PROGRESS_STAGES * GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE; i++)
    {
        new objectID = gh_data[gh_DynamicObjectIDs][i];
        if (objectID != -1)
        {
            DestroyDynamicObject(objectID);
            gh_data[gh_DynamicObjectIDs][i] = -1;

            printf("Destroyed dynamic object ID %d for greenhouse ID %d", objectID, gh_data[gh_ID]);
        }
    }
}
