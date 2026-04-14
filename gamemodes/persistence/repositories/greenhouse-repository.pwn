#if defined _greenhouse_repository_included
    #endinput
#endif
#define _greenhouse_repository_included

#include "domain/greenhouse.pwn"
#include "persistence/server-db-context.pwn"
#include "domain/dtos/repository-responses/greenhouse/find-all-greenhouses-by-user-rep-response.pwn"

stock GreenhouseRepository_FindAllGreenhousesByUser(userID)
{
    new DB:dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();
    if (!dbConnectionHandle)
    {
        ServerDBContext_ReopenConnection();
        dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();

        if (!dbConnectionHandle)
        {
            print("Failed to get database connection handle after reopening!");
            new response[MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_FIND_ALL_BY_USER_REP_RESPONSE];
            response[0][gh_ID] = -1;
            return response;
        }
    }

    new query[256];
    format(query, sizeof(query), "SELECT id, position_id, grow_progress_seconds, is_boosted FROM greenhouses WHERE user_id = %d", userID);

    new DBResult:dbResultSet = DB_ExecuteQuery(dbConnectionHandle, query);

    new response[MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_FIND_ALL_BY_USER_REP_RESPONSE];
    new index = 0;

    response[0][gh_ID] = -1; // Default to no greenhouses found


    if (dbResultSet)
    {
        if (DB_GetRowCount(dbResultSet) > 0)
        {
            do
            {
                if (index >= MAX_GREENHOUSES_PER_PLAYER)
                {
                    print("Max greenhouses per player reached while fetching greenhouses for user ID: %d", userID);
                    break;
                }

                response[index][gh_ID] = DB_GetFieldIntByName(dbResultSet, "id");
                response[index][gh_userID] = userID;
                response[index][gh_positionID] = DB_GetFieldIntByName(dbResultSet, "position_id");
                response[index][gh_progress] = DB_GetFieldIntByName(dbResultSet, "grow_progress_seconds");
                response[index][gh_isUpgraded] = DB_GetFieldIntByName(dbResultSet, "is_boosted");
                index++;
            } while (DB_SelectNextRow(dbResultSet));
        }
    }


    if (index < MAX_GREENHOUSES_PER_PLAYER)
    {
        response[index][gh_ID] = -1; // Mark the end of valid greenhouses
    }

    DB_FreeResultSet(dbResultSet);
    return response;
}

stock GreenhouseRepository_CreateGreenhouseForUser(userID, positionID)
{
    new DB:dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();
    if (!dbConnectionHandle)
    {
        ServerDBContext_ReopenConnection();
        dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();

        if (!dbConnectionHandle)
        {
            print("Failed to get database connection handle after reopening!");
            return -1;
        }
    }

    new query[256];
    format(query, sizeof(query), "INSERT INTO greenhouses (user_id, position_id) VALUES (%d, %d) RETURNING id", userID, positionID); // todo: this is vulnerable to SQL injection.

    new DBResult:dbResultSet = DB_ExecuteQuery(dbConnectionHandle, query);

    if (dbResultSet)
    {
        new greenhouseID = DB_GetFieldIntByName(dbResultSet, "id");
        DB_FreeResultSet(dbResultSet);
        return greenhouseID;
    }
    else
    {
        print("Failed to create new greenhouse for user ID: %d", userID);
        DB_FreeResultSet(dbResultSet);
        return -1;
    }
}

stock GreenhouseRepository_UpdateGreenhouse(greenhouseID, progress, isUpgraded)
{
    new DB:dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();
    if (!dbConnectionHandle)
    {
        ServerDBContext_ReopenConnection();
        dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();

        if (!dbConnectionHandle)
        {
            print("Failed to get database connection handle after reopening!");
            return false;
        }
    }

    new query[256];
    format(query, sizeof(query), "UPDATE greenhouses SET grow_progress_seconds = %d, is_boosted = %d WHERE id = %d", progress, isUpgraded, greenhouseID); // todo: this is vulnerable to SQL injection.

    new result = DB_ExecuteQuery(dbConnectionHandle, query);
    return result != DBResult:0;
}
