#include "persistence/repositories/user-repository.pwn"
#include "persistence/repositories/greenhouse-repository.pwn"

#include "domain/dtos/repository-responses/user/find-or-create-user-rep-response.pwn"
#include "domain/dtos/repository-responses/greenhouse/find-all-greenhouses-by-user-rep-response.pwn"

#include "domain/greenhouse.pwn"

#include "systems/greenhouses-system.pwn"
#include "factories/greenhouse-object-factory.pwn"


stock OnPlayerConnectedCommandOld(playerid)
{
    // Send a message to the chat
    SendClientMessage(playerid, -1, "Welcome to the Greenhouse Test Server!");

    // collect player from persistence:
    new username[MAX_PLAYER_NAME];
    GetPlayerName(playerid, username, sizeof(username));

    new userRepResponse[E_USER_FIND_OR_CREATE_REP_RESPONSE];
    userRepResponse = UserRepository_FindOrCreateUser(username);

    printf("UserRepository_FindOrCreateUser response: ID=%d, Username=%s", userRepResponse[u_ID], userRepResponse[u_Username]);


    // new createdGreenhouseID = GreenhouseRepository_CreateGreenhouseForUser(userRepResponse[u_ID], GREENHOUSE_POSITION_1_ID);
    // printf("GreenhouseRepository_CreateGreenhouseForUser response: Created Greenhouse ID=%d for User ID=%d", createdGreenhouseID, userRepResponse[u_ID]);

    new greenhouseRepResponse[MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_FIND_ALL_BY_USER_REP_RESPONSE];
    greenhouseRepResponse = GreenhouseRepository_FindAllGreenhousesByUser(userRepResponse[u_ID]);

    for (new i = 0; i < MAX_GREENHOUSES_PER_PLAYER && greenhouseRepResponse[i][gh_ID] != -1; i++)
    {
        // printf("Greenhouse %d for User ID %d: Greenhouse ID=%d, Position ID=%d, Progress=%d seconds, Is Boosted=%d",
        //        i, userRepResponse[u_ID], greenhouseRepResponse[i][gh_ID], greenhouseRepResponse[i][gh_positionID],
        //        greenhouseRepResponse[i][gh_progress], greenhouseRepResponse[i][gh_isUpgraded]);

        new gh_data[E_GREENHOUSE_DATA];
        gh_data[gh_ID] = greenhouseRepResponse[i][gh_ID];
        gh_data[gh_OwnerID] = playerid; // runtime player ID, not persisted.
        gh_data[gh_PositionID] = greenhouseRepResponse[i][gh_positionID];

        new Float:pos[3];
        pos = Greenhouse_GetPositionByIntID(gh_data[gh_PositionID]);

        gh_data[gh_Pos][0] = pos[0];
        gh_data[gh_Pos][1] = pos[1];
        gh_data[gh_Pos][2] = pos[2];
        gh_data[gh_Progress] = greenhouseRepResponse[i][gh_progress];
        gh_data[gh_IsUpgraded] = greenhouseRepResponse[i][gh_isUpgraded];
        gh_data[gh_IsPaused] = false;

        new bool:successAdd = GreenhouseSystem_AddGreenhouse(gh_data);
        printf("GreenhouseSystem_AddGreenhouse response for greenhouse ID %d: %d", gh_data[gh_ID], successAdd);

        new objectIds[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE * GREENHOUSE_PROGRESS_STAGES];
        objectIds = GhObjFactory_Spawn(playerid, 0, gh_data);

        new bool:successAssociation = GreenhouseSystem_AssociateDynamicObjectsWithGreenhouse(gh_data[gh_ID], objectIds);
        printf("GreenhouseSystem_AssociateDynamicObjectsWithGreenhouse response for greenhouse ID %d: %d", gh_data[gh_ID], successAssociation);
    }

    // new result = GreenhouseRepository_UpdateGreenhouse(greenhouseRepResponse[0][gh_ID], greenhouseRepResponse[0][gh_progress] + 10, greenhouseRepResponse[0][gh_isUpgraded]);
    // printf("GreenhouseRepository_UpdateGreenhouse response: %d", result);

    return 1;
}


stock OnPlayerConnectedCommand(playerid)
{
    SendClientMessage(playerid, -1, "Welcome to the Greenhouse Test Server!");

    new username[MAX_PLAYER_NAME];
    GetPlayerName(playerid, username, sizeof(username));

    // Kick off the chain, pushing playerid into the void so it comes back to us
    UserRepository_FindOrCreateUserAsync(username, "OnPlayerConnectedCommandInternal_OnUserLoadedForGreenhouse", playerid);
    return 1;
}

forward OnPlayerConnectedCommandInternal_OnUserLoadedForGreenhouse(userID, username[], playerid);
public OnPlayerConnectedCommandInternal_OnUserLoadedForGreenhouse(userID, username[], playerid)
{
    printf("OnPlayerConnectedCommandInternal_OnUserLoadedForGreenhouse response: ID=%d, Username=%s", userID, username);

    GreenhouseRepository_FindAllGreenhousesByUserAsync(userID, "OnPlayerConnectedCommandInternal_OnGreenhousesLoadedForPlayer", playerid);
    return 1;
}

forward OnPlayerConnectedCommandInternal_OnGreenhousesLoadedForPlayer(userID, rowCount, playerid);
public OnPlayerConnectedCommandInternal_OnGreenhousesLoadedForPlayer(userID, rowCount, playerid)
{
    printf("Found %d greenhouses for user %d (Player %d)", rowCount, userID, playerid);

    // Loop through the active cache directly
    for (new i = 0; i < rowCount; i++)
    {
        if (i >= MAX_GREENHOUSES_PER_PLAYER) break;

        new gh_data[E_GREENHOUSE_DATA];

        // Fetch data from MySQL cache
        cache_get_value_name_int(i, "id", gh_data[gh_ID]);
        cache_get_value_name_int(i, "position_id", gh_data[gh_PositionID]);
        cache_get_value_name_int(i, "grow_progress_seconds", gh_data[gh_Progress]);
        cache_get_value_name_int(i, "is_boosted", gh_data[gh_IsUpgraded]);

        // runtime player ID, not persisted.
        // i'd love to use cache instead of this playerid hack but i'm not sure how to make this cache reliable in concurrency.
        // actually, now that i think about it, i am not sure this whole function is concurrently reliable :D
        gh_data[gh_OwnerID] = playerid;
        gh_data[gh_IsPaused] = false;

        new Float:pos[3];
        pos = Greenhouse_GetPositionByIntID(gh_data[gh_PositionID]);

        gh_data[gh_Pos][0] = pos[0];
        gh_data[gh_Pos][1] = pos[1];
        gh_data[gh_Pos][2] = pos[2];

        new bool:successAdd = GreenhouseSystem_AddGreenhouse(gh_data);
        printf("GreenhouseSystem_AddGreenhouse response for greenhouse ID %d: %d", gh_data[gh_ID], successAdd);

        new objectIds[GREENHOUSE_MAX_DYNAMIC_OBJECTS_PER_STAGE * GREENHOUSE_PROGRESS_STAGES];
        objectIds = GhObjFactory_Spawn(playerid, playerid, gh_data);

        new bool:successAssoc = GreenhouseSystem_AssociateDynamicObjectsWithGreenhouse(gh_data[gh_ID], objectIds);
        printf("GreenhouseSystem_Associate... response for greenhouse ID %d: %d", gh_data[gh_ID], successAssoc);
    }
    
    return 1;
}
