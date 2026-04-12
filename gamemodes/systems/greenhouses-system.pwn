#if defined _greenhouses_system_included
    #endinput
#endif
#define _greenhouses_system_included

#include "domain/greenhouse.pwn"

#define TOTAL_CHUNKS 50
#define GREENHOUSES_PER_CHUNK (MAX_GREENHOUSES / TOTAL_CHUNKS)

new g_GreenhouseData[MAX_GREENHOUSES][E_GREENHOUSE_DATA];

new g_CurrentChunk = 0;

forward InitializeGreenhouseData();
public InitializeGreenhouseData()
{
    for(new i = 0; i < MAX_GREENHOUSES; i++)
    {
        InitializeEmptyGreenhouse(g_GreenhouseData[i]);
    }
}

// Forward declaration for the timer callback
forward ProcessNextGreenhouseChunk();

public ProcessNextGreenhouseChunk()
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
