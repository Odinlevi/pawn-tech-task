#if defined _user_repository_included
    #endinput
#endif
#define _user_repository_included

#include "persistence/server-db-context.pwn"
#include "domain/dtos/repository-responses/user/find-or-create-user-rep-response.pwn"

stock UserRepository_FindOrCreateUser(username[])
{
    new userID = UserRepository_FindUserIDByUsername(username);

    if (userID != -1)
    {
        // User already exists, return existing user data
        new response[E_USER_FIND_OR_CREATE_REP_RESPONSE];
        response[u_ID] = userID;
        strcopy(response[u_Username], username, sizeof(response[u_Username]));
        return response;
    }

    // User does not exist, create a new user
    new DB:dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();
    if (!dbConnectionHandle)
    {
        ServerDBContext_ReopenConnection();
        dbConnectionHandle = ServerDBContext_GetDBConnectionHandle();

        if (!dbConnectionHandle)
        {
            print("Failed to get database connection handle after reopening!");
            new response[E_USER_FIND_OR_CREATE_REP_RESPONSE];
            response[u_ID] = -1;
            return response;
        }
    }

    new query[256];
    format(query, sizeof(query), "INSERT INTO users (username) VALUES ('%s') RETURNING id", username); // todo: this is vulnerable to SQL injection.

    new DBResult:dbResultSet = DB_ExecuteQuery(dbConnectionHandle, query);

    new response[E_USER_FIND_OR_CREATE_REP_RESPONSE];

    if (dbResultSet)
    {
        // Successfully inserted new user, now retrieve the new user's ID
        new userID = DB_GetFieldIntByName(dbResultSet, "id"); // Assuming 'id' is the first column in the result set
        response[u_ID] = userID;
        strcopy(response[u_Username], username, sizeof(response[u_Username]));
    }
    else
    {
        print("Failed to create new user!");
        new response[E_USER_FIND_OR_CREATE_REP_RESPONSE];
        response[u_ID] = -1;
    }

    DB_FreeResultSet(dbResultSet);
    return response;
}

stock UserRepository_FindUserIDByUsername(username[])
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
    format(query, sizeof(query), "SELECT id FROM users WHERE username = '%s' LIMIT 1", username); // todo: this is vulnerable to SQL injection.
    new DB:resultSetHandle = DB_ExecuteQuery(dbConnectionHandle, query);

    if (resultSetHandle)
    {
        if (DB_GetRowCount(resultSetHandle) > 0)
        {
            new userID = DB_GetFieldIntByName(resultSetHandle, "id");
            DB_FreeResultSet(resultSetHandle);
            return userID;
        }
        DB_FreeResultSet(resultSetHandle);
    }

    return -1; // User not found
}
