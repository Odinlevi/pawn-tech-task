#if defined _greenhouse_included
    #endinput
#endif
#define _greenhouse_included

#define MAX_GREENHOUSES 5000
#define MAX_GREENHOUSES_PER_PLAYER 5
#define GREENHOUSE_MAX_PROGRESS 600 // Time in seconds for full growth (10 minutes)
#define GREENHOUSE_UPDATE_INTERVAL 1000 // Time in milliseconds for growth updates (1 second)
#define GREENHOUSE_PROGRESS_STAGES 5 // Number of growth stages (0-4)
#define GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE 10 // Max number of dynamic objects per growth stage
#define GREENHOUSE_DISTANCE_THRESHOLD 50.0
#define GREENHOUSE_UPGRADE_PROGRESS_MULTIPLIER 2 // Upgraded greenhouses grow twice as fast

new Float:GREENHOUSE_POSITION_1[3] = {16.0, 33.0, 0.0}; // for some reason, z is vertical, not y
#define GREENHOUSE_POSITION_1_ID 1

new Float:GREENHOUSE_POSITION_2[3] = {26.0, 33.0, 0.0};
#define GREENHOUSE_POSITION_2_ID 2


new Float:GREENHOUSE_POSITION_3[3] = {26.0, 23.0, 0.0};
#define GREENHOUSE_POSITION_3_ID 3

new Float:GREENHOUSE_POSITION_4[3] = {36.0, 23.0, 0.0};
#define GREENHOUSE_POSITION_4_ID 4

new Float:GREENHOUSE_POSITION_5[3] = {36.0, 13.0, 0.0};
#define GREENHOUSE_POSITION_5_ID 5




enum E_GREENHOUSE_DATA {
    gh_ID,               // Database primary key ID
    gh_OwnerID,          // Player ID of the owner (runtime, not persisted; db id should be fetched separately if needed)
    gh_PositionID,       // Position ID (is persistant)
    Float:gh_Pos[3],     // X, Y, Z coordinates (is cached only)
    gh_Progress,         // Growth Progress in seconds
    bool:gh_IsUpgraded,  // Upgrade Status
    bool:gh_IsPaused,    // Growth Pause Status, when player is not nearby (is cached only)
    gh_DynamicObjectIDs[GREENHOUSE_PROGRESS_STAGES * GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE]
};

stock InitializeEmptyGreenhouse(gh_data[E_GREENHOUSE_DATA])
{
    gh_data[gh_ID] = -1; // -1 indicates an empty slot
    gh_data[gh_OwnerID] = -1;
    gh_data[gh_PositionID] = -1;
    gh_data[gh_Pos][0] = 0.0;
    gh_data[gh_Pos][1] = 0.0;
    gh_data[gh_Pos][2] = 0.0;
    gh_data[gh_Progress] = 0;
    gh_data[gh_IsUpgraded] = false;
    gh_data[gh_IsPaused] = false;

    // Initialize dynamic object IDs to -1 (indicating no object)
    for (new i = 0; i < GREENHOUSE_PROGRESS_STAGES * GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE; i++)
    {
        gh_data[gh_DynamicObjectIDs][i] = -1;
    }
}

stock Greenhouse_GetPositionByIntID(positionID)
{
    if (positionID == GREENHOUSE_POSITION_1_ID)
    {
        return GREENHOUSE_POSITION_1;
    }
    else if (positionID == GREENHOUSE_POSITION_2_ID)
    {
        return GREENHOUSE_POSITION_2;
    }
    else if (positionID == GREENHOUSE_POSITION_3_ID)
    {
        return GREENHOUSE_POSITION_3;
    }
    else if (positionID == GREENHOUSE_POSITION_4_ID)
    {
        return GREENHOUSE_POSITION_4;
    }
    else if (positionID == GREENHOUSE_POSITION_5_ID)
    {
        return GREENHOUSE_POSITION_5;
    }
    
    // Default position if ID is invalid
    new Float:defaultPos[3] = {0.0, 0.0, 0.0};
    return defaultPos;
}
