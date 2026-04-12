#include "persistence/repositories/user-repository.pwn"
#include "persistence/repositories/greenhouse-repository.pwn"

#include "domain/greenhouse.pwn"

#include "systems/greenhouses-system.pwn"

stock OnPlayerDisconnectedCommand(playerid)
{
    // collect player from persistence:
    new username[MAX_PLAYER_NAME];
    GetPlayerName(playerid, username, sizeof(username));

    new userIDRepResponse;
    userIDRepResponse = UserRepository_FindUserIDByUsername(username);

    if (userIDRepResponse == -1)
    {
        printf("OnPlayerDisconnectedCommand: Failed to find user ID for username %s", username);
        return 0;
    }

    new outputGreenhouses[MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_DATA];
    new greenhousesCount = GreenhouseSystem_GetGreenhousesByPlayerID(userIDRepResponse, outputGreenhouses);

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
            printf("OnPlayerDisconnectedCommand: Successfully updated greenhouse ID %d for user ID %d", outputGreenhouses[i][gh_ID], userIDRepResponse);
        }
        else
        {
            printf("OnPlayerDisconnectedCommand: Failed to update greenhouse ID %d for user ID %d", outputGreenhouses[i][gh_ID], userIDRepResponse);

        }
    }

    GreenhouseSystem_DeleteGreenhousesByPlayerID(userIDRepResponse);

    return 1;
}