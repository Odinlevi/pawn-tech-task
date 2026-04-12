// Max number of greenhouses allowed in the server
#if !defined MAX_GREENHOUSES
    #define MAX_GREENHOUSES 5000
#endif

#if !defined GREENHOUSE_MODEL
    #define GREENHOUSE_MODEL 1337 // Replace with actual model ID
#endif

#if !defined GREENHOUSE_MAX_PROGRESS
    #define GREENHOUSE_MAX_PROGRESS 600 // Time in seconds for full growth (10 minutes)
#endif

#if !defined GREENHOUSE_UPDATE_INTERVAL
    #define GREENHOUSE_UPDATE_INTERVAL 1000 // Time in milliseconds for growth updates (1 second)
#endif

#if !defined GREENHOUSE_PROGRESS_STAGES
    #define GREENHOUSE_PROGRESS_STAGES 5 // Number of growth stages (0-4)
#endif

#if !defined GREENHOUSE_POSITION_1
    new Float:GREENHOUSE_POSITION_1[3] = {-20.0, 0.0, 10.0};
    #define GREENHOUSE_POSITION_1_ID 1
#endif

#if !defined GREENHOUSE_POSITION_2
    new Float:GREENHOUSE_POSITION_2[3] = {-10.0, 0.0, 10.0};
    #define GREENHOUSE_POSITION_2_ID 2
#endif

#if !defined GREENHOUSE_POSITION_3
    new Float:GREENHOUSE_POSITION_3[3] = {0.0, 0.0, 10.0};
    #define GREENHOUSE_POSITION_3_ID 3
#endif

#if !defined GREENHOUSE_POSITION_4
    new Float:GREENHOUSE_POSITION_4[3] = {10.0, 0.0, 10.0};
    #define GREENHOUSE_POSITION_4_ID 4
#endif

#if !defined GREENHOUSE_POSITION_5
    new Float:GREENHOUSE_POSITION_5[3] = {20.0, 0.0, 10.0};
    #define GREENHOUSE_POSITION_5_ID 5
#endif



enum E_GREENHOUSE_DATA {
    gh_ID,              // Database primary key ID
    Float:gh_Pos[3],    // X, Y, Z coordinates
    gh_VirtualWorld,    // Virtual World ID
    gh_PositionID,      // Position ID
    gh_Progress,        // Growth Progress in seconds
    bool:gh_IsUpgraded  // Upgrade Status
};

