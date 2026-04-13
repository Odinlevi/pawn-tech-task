#if defined _gh_object_fabric_included
    #endinput
#endif
#define _gh_object_fabric_included

#include <streamer>

#include "domain/greenhouse.pwn"
#include "systems/greenhouses-system.pwn"

#include "domain/dynamic-objects/dynamic-object.pwn"

#define GH_DYN_OBJ_COUNT_STAGE0 6
#define GH_DYN_OBJ_COUNT_STAGE1 3
#define GH_DYN_OBJ_COUNT_STAGE2 3
#define GH_DYN_OBJ_COUNT_STAGE3 3
#define GH_DYN_OBJ_COUNT_STAGE4 3

new GhComplexDynamicObjectStage0[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE][E_DYNAMIC_OBJECT_DATA]; // i wanted to have less space allocated here, but no arrays copy are available for pawn.
new GhComplexDynamicObjectStage1[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE][E_DYNAMIC_OBJECT_DATA];
new GhComplexDynamicObjectStage2[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE][E_DYNAMIC_OBJECT_DATA];
new GhComplexDynamicObjectStage3[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE][E_DYNAMIC_OBJECT_DATA];
new GhComplexDynamicObjectStage4[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE][E_DYNAMIC_OBJECT_DATA];


// This fabric is responsible for spawning the dynamic objects that represent the greenhouse's growth stages.
// ** IMPORTANT **: there is a side effect of this fabric which is that it also initializes the dynamic object IDs in the greenhouse data structure. be aware.

// todo: after some thinking, i think i can just get the array of spawned objects ids and return it. will return to it later if i'll have time.
stock GhObjFabric_Spawn(playerid, virtualWorldID, gh_data[E_GREENHOUSE_DATA])
{
    new currentStage = gh_data[gh_Progress] / (GREENHOUSE_MAX_PROGRESS / GREENHOUSE_PROGRESS_STAGES);
    if (currentStage >= GREENHOUSE_PROGRESS_STAGES)
        currentStage = GREENHOUSE_PROGRESS_STAGES - 1; // clumped on progress == GREENHOUSE_MAX_PROGRESS. kind of a hack.

    for (new stage = 0; stage <= currentStage; stage++)
    {
        GhObjFabric_SpawnOnStage(playerid, virtualWorldID, gh_data, stage);
    }
}

stock GhObjFabric_SpawnOnStage(playerid, virtualWorldID, gh_data[E_GREENHOUSE_DATA], stage)
{
    if (GhComplexDynamicObjectStage0[0][do_ModelID] == 0) // only once.
    {
        GhObjFabric_InitializeGhStage0();
        GhObjFabric_InitializeGhStage1();
        GhObjFabric_InitializeGhStage2();
        GhObjFabric_InitializeGhStage3();
        GhObjFabric_InitializeGhStage4();
    }
    
    new stageObjects[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE][E_DYNAMIC_OBJECT_DATA];
    new objectsCount = 0;

    switch (stage)
    {
        case 0:
        {
            stageObjects = GhComplexDynamicObjectStage0;
            objectsCount = GH_DYN_OBJ_COUNT_STAGE0;
        }
        case 1:
        {
            stageObjects = GhComplexDynamicObjectStage1;
            objectsCount = GH_DYN_OBJ_COUNT_STAGE1;
        }
        case 2:
        {
            stageObjects = GhComplexDynamicObjectStage2;
            objectsCount = GH_DYN_OBJ_COUNT_STAGE2;
        }
        case 3:
        {
            stageObjects = GhComplexDynamicObjectStage3;
            objectsCount = GH_DYN_OBJ_COUNT_STAGE3;
        }
        case 4:
        {
            stageObjects = GhComplexDynamicObjectStage4;
            objectsCount = GH_DYN_OBJ_COUNT_STAGE4;
        }
    }

    for (new i = 0; i < objectsCount; i++)
    {
        new objectid = CreateDynamicObject(stageObjects[i][do_ModelID], 
                                            gh_data[gh_Pos][0] + stageObjects[i][do_Pos][0],
                                            gh_data[gh_Pos][1] + stageObjects[i][do_Pos][1],
                                            gh_data[gh_Pos][2] + stageObjects[i][do_Pos][2],
                                            0.0, 0.0, stageObjects[i][do_Rot][2], 
                                            virtualWorldID, -1, playerid, 
                                            GREENHOUSE_DISTANCE_THRESHOLD, GREENHOUSE_DISTANCE_THRESHOLD, 
                                            -1, 0);
        gh_data[gh_DynamicObjectIDs][stage * GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE + i] = objectid;
    }
    
}


stock GhObjFabric_InitializeGhStage0()
{
    GhComplexDynamicObjectStage0[0][do_ModelID] = 1479;
    GhComplexDynamicObjectStage0[0][do_Pos][0] = 0.0;
    GhComplexDynamicObjectStage0[0][do_Pos][1] = 0.0;
    GhComplexDynamicObjectStage0[0][do_Pos][2] = 3.5;
    GhComplexDynamicObjectStage0[0][do_Rot][2] = 150.0;
    
    GhComplexDynamicObjectStage0[1][do_ModelID] = 2244;
    GhComplexDynamicObjectStage0[1][do_Pos][0] = -3.4;
    GhComplexDynamicObjectStage0[1][do_Pos][1] = 1.0;
    GhComplexDynamicObjectStage0[1][do_Pos][2] = 2.4;

    GhComplexDynamicObjectStage0[2][do_ModelID] = 2244;
    GhComplexDynamicObjectStage0[2][do_Pos][0] = -2.3;
    GhComplexDynamicObjectStage0[2][do_Pos][1] = -0.5;
    GhComplexDynamicObjectStage0[2][do_Pos][2] = 2.4;
    
    GhComplexDynamicObjectStage0[3][do_ModelID] = 2244;
    GhComplexDynamicObjectStage0[3][do_Pos][0] = -0.8;
    GhComplexDynamicObjectStage0[3][do_Pos][1] = -1.4;
    GhComplexDynamicObjectStage0[3][do_Pos][2] = 2.4;

    GhComplexDynamicObjectStage0[4][do_ModelID] = 2244;
    GhComplexDynamicObjectStage0[4][do_Pos][0] = 0.5;
    GhComplexDynamicObjectStage0[4][do_Pos][1] = -2.3;
    GhComplexDynamicObjectStage0[4][do_Pos][2] = 2.4;

    GhComplexDynamicObjectStage0[5][do_ModelID] = 2244;
    GhComplexDynamicObjectStage0[5][do_Pos][0] = 2.5;
    GhComplexDynamicObjectStage0[5][do_Pos][1] = -2.2;
    GhComplexDynamicObjectStage0[5][do_Pos][2] = 2.4;
}

stock GhObjFabric_InitializeGhStage1()
{
    GhComplexDynamicObjectStage1[0][do_ModelID] = 19636;
    GhComplexDynamicObjectStage1[0][do_Pos][0] = 2.2;
    GhComplexDynamicObjectStage1[0][do_Pos][1] = -3.3;
    GhComplexDynamicObjectStage1[0][do_Pos][2] = 2.12;

    GhComplexDynamicObjectStage1[1][do_ModelID] = 19636;
    GhComplexDynamicObjectStage1[1][do_Pos][0] = 2.2;
    GhComplexDynamicObjectStage1[1][do_Pos][1] = -3.3;
    GhComplexDynamicObjectStage1[1][do_Pos][2] = 2.3;
    GhComplexDynamicObjectStage1[1][do_Rot][2] = 30.0;

    GhComplexDynamicObjectStage1[2][do_ModelID] = 19636;
    GhComplexDynamicObjectStage1[2][do_Pos][0] = 2.2;
    GhComplexDynamicObjectStage1[2][do_Pos][1] = -3.3;
    GhComplexDynamicObjectStage1[2][do_Pos][2] = 2.46;
    GhComplexDynamicObjectStage1[2][do_Rot][2] = -30.0;
}

stock GhObjFabric_InitializeGhStage2()
{
    GhComplexDynamicObjectStage2[0][do_ModelID] = 19636;
    GhComplexDynamicObjectStage2[0][do_Pos][0] = 1.1;
    GhComplexDynamicObjectStage2[0][do_Pos][1] = -3.4;
    GhComplexDynamicObjectStage2[0][do_Pos][2] = 2.12;

    GhComplexDynamicObjectStage2[1][do_ModelID] = 19636;
    GhComplexDynamicObjectStage2[1][do_Pos][0] = 1.1;
    GhComplexDynamicObjectStage2[1][do_Pos][1] = -3.4;
    GhComplexDynamicObjectStage2[1][do_Pos][2] = 2.3;
    GhComplexDynamicObjectStage2[1][do_Rot][2] = 30.0;

    GhComplexDynamicObjectStage2[2][do_ModelID] = 19636;
    GhComplexDynamicObjectStage2[2][do_Pos][0] = 1.1;
    GhComplexDynamicObjectStage2[2][do_Pos][1] = -3.4;
    GhComplexDynamicObjectStage2[2][do_Pos][2] = 2.46;
    GhComplexDynamicObjectStage2[2][do_Rot][2] = -30.0;
}

stock GhObjFabric_InitializeGhStage3()
{
    GhComplexDynamicObjectStage3[0][do_ModelID] = 19636;
    GhComplexDynamicObjectStage3[0][do_Pos][0] = 2.2;
    GhComplexDynamicObjectStage3[0][do_Pos][1] = -3.3;
    GhComplexDynamicObjectStage3[0][do_Pos][2] = 2.62;

    GhComplexDynamicObjectStage3[1][do_ModelID] = 19636;
    GhComplexDynamicObjectStage3[1][do_Pos][0] = 2.2;
    GhComplexDynamicObjectStage3[1][do_Pos][1] = -3.3;
    GhComplexDynamicObjectStage3[1][do_Pos][2] = 2.78;
    GhComplexDynamicObjectStage3[1][do_Rot][2] = 30.0;

    GhComplexDynamicObjectStage3[2][do_ModelID] = 19636;
    GhComplexDynamicObjectStage3[2][do_Pos][0] = 2.2;
    GhComplexDynamicObjectStage3[2][do_Pos][1] = -3.3;
    GhComplexDynamicObjectStage3[2][do_Pos][2] = 2.94;
    GhComplexDynamicObjectStage3[2][do_Rot][2] = -30.0;
}

stock GhObjFabric_InitializeGhStage4()
{
    GhComplexDynamicObjectStage4[0][do_ModelID] = 19636;
    GhComplexDynamicObjectStage4[0][do_Pos][0] = 1.1;
    GhComplexDynamicObjectStage4[0][do_Pos][1] = -3.4;
    GhComplexDynamicObjectStage4[0][do_Pos][2] = 2.62;

    GhComplexDynamicObjectStage4[1][do_ModelID] = 19636;
    GhComplexDynamicObjectStage4[1][do_Pos][0] = 1.1;
    GhComplexDynamicObjectStage4[1][do_Pos][1] = -3.4;
    GhComplexDynamicObjectStage4[1][do_Pos][2] = 2.78;
    GhComplexDynamicObjectStage4[1][do_Rot][2] = 30.0;

    GhComplexDynamicObjectStage4[2][do_ModelID] = 19636;
    GhComplexDynamicObjectStage4[2][do_Pos][0] = 1.1;
    GhComplexDynamicObjectStage4[2][do_Pos][1] = -3.4;
    GhComplexDynamicObjectStage4[2][do_Pos][2] = 2.94;
    GhComplexDynamicObjectStage4[2][do_Rot][2] = -30.0;
}
