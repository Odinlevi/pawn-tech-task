#include "systems/greenhouses-system.pwn"

#include "persistence/repositories/user-repository.pwn"
#include "persistence/repositories/greenhouse-repository.pwn"

stock OnPlayerCreatedGhCommand(playerid, positionID)
{
    SendClientMessage(playerid, -1, "Creating Greenhouse at position %d...", positionID);

    new cacheHit = GreenhouseSystem_FindGreenhouseIndexByPlayerAndPositionID(playerid, positionID);

    if (cacheHit != -1)
    {
        SendClientMessage(playerid, -1, "Greenhouse already exists at this position.");
        return 1;
    }

    // collect player from persistence:
    new username[MAX_PLAYER_NAME];
    GetPlayerName(playerid, username, sizeof(username));

    new userRepResponse[E_USER_FIND_OR_CREATE_REP_RESPONSE];
    userRepResponse = UserRepository_FindOrCreateUser(username);

    new greenhouseRepID = GreenhouseRepository_CreateGreenhouseForUser(userRepResponse[u_ID], positionID);

    if (greenhouseRepID == -1)
    {
        SendClientMessage(playerid, -1, "Failed to create greenhouse in the database.");
        return 1;
    }

    new gh_data[E_GREENHOUSE_DATA];
    gh_data[gh_ID] = greenhouseRepID;
    gh_data[gh_OwnerID] = playerid; // runtime player ID, not persisted.
    gh_data[gh_PositionID] = positionID;

    new Float:pos[3];
    pos = Greenhouse_GetPositionByIntID(gh_data[gh_PositionID]);

    gh_data[gh_Pos][0] = pos[0];
    gh_data[gh_Pos][1] = pos[1];
    gh_data[gh_Pos][2] = pos[2];
    gh_data[gh_Progress] = 0;
    gh_data[gh_IsUpgraded] = false;
    gh_data[gh_IsPaused] = false;

    new bool:successAdd = GreenhouseSystem_AddGreenhouse(gh_data);
    printf("GreenhouseSystem_AddGreenhouse response for greenhouse ID %d: %d", gh_data[gh_ID], successAdd);

    new objectIds[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE * GREENHOUSE_PROGRESS_STAGES];
    objectIds = GhObjFactory_Spawn(playerid, 0, gh_data);

    new bool:successAssociation = GreenhouseSystem_AssociateDynamicObjectsWithGreenhouse(gh_data[gh_ID], objectIds);
    printf("GreenhouseSystem_AssociateDynamicObjectsWithGreenhouse response for greenhouse ID %d: %d", gh_data[gh_ID], successAssociation);

    SendClientMessage(playerid, -1, "Greenhouse created at position %d.", positionID);

    return 1;
}