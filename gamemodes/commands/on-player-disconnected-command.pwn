#include "persistence/repositories/user-repository.pwn"
#include "persistence/repositories/greenhouse-repository.pwn"

#include "domain/greenhouse.pwn"

#include "systems/greenhouses-system.pwn"

stock OnPlayerDisconnectedCommand(playerid)
{
    // no need for now since greenhouses can be updated without player presence. 
    // // collect player from persistence:
    // new username[MAX_PLAYER_NAME];
    // GetPlayerName(playerid, username, sizeof(username));

    // new userIDRepResponse;
    // userIDRepResponse = UserRepository_FindUserIDByUsername(username);

    // if (userIDRepResponse == -1)
    // {
    //     printf("OnPlayerDisconnectedCommand: Failed to find user ID for username %s", username);
    //     return 0;
    // }

    new outputGreenhouses[MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_DATA];
    new greenhousesCount = GreenhouseSystem_GetGreenhousesByPlayerID(playerid, outputGreenhouses);

    // todo: batches are preferred here.
    for (new i = 0; i < greenhousesCount; i++)
    {
        new updateResult = GreenhouseRepository_UpdateGreenhouse(
            outputGreenhouses[i][gh_ID],
            outputGreenhouses[i][gh_Progress],
            outputGreenhouses[i][gh_IsUpgraded]
        );

        if (updateResult)
        {
            printf("OnPlayerDisconnectedCommand: Successfully updated greenhouse ID %d for player ID %d", outputGreenhouses[i][gh_ID], playerid);
        }
        else
        {
            printf("OnPlayerDisconnectedCommand: Failed to update greenhouse ID %d for player ID %d", outputGreenhouses[i][gh_ID], playerid);

        }
    }

    GreenhouseSystem_DeleteGreenhousesByPlayerID(playerid);

    return 1;
}