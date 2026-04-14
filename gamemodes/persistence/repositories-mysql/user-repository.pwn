#if defined _user_repository_included
    #endinput
#endif
#define _user_repository_included

#include "persistence/mysql-server-db-context.pwn"

//todo: playerid in every request is more a hack. ideally the repository should be completely decoupled from the runtime
// if it is not possible, it should be anonymous meaning any number of args should be accepted and just passed through to the callback, instead of hardcoding playerid as the only accepted one. 

// ----- FIND OR CREATE USER -----
// returns userID and username[] if user is found or created successfully, otherwise returns userID = -1.
stock UserRepository_FindOrCreateUserAsync(username[], callbackFunction[], playerid = -1)
{
    new query[256];
    new MySQL:handle = MySQLServerDBContext_GetConnectionHandle();

    if (handle == MYSQL_INVALID_HANDLE) {
        printf("[ERROR] Connection handle is invalid.");
        return 0;
    }

    // Attempt to find the user first
    mysql_format(handle, query, sizeof(query), "SELECT `id` FROM `users` WHERE `username` = '%e' LIMIT 1", username);
    
    return mysql_tquery(handle, query, "UserRepositoryInternal_OnFindOrCreateSelect", "ssi", username, callbackFunction, playerid);
}

forward UserRepositoryInternal_OnFindOrCreateSelect(username[], callbackFunction[], playerid);
public UserRepositoryInternal_OnFindOrCreateSelect(username[], callbackFunction[], playerid)
{
    new userID = -1;

    if (cache_num_rows() > 0) 
    {
        // USER FOUND: Extract the ID and call the final callback
        cache_get_value_name_int(0, "id", userID);
        CallLocalFunction(callbackFunction, "isi", userID, username, playerid);
    }
    else 
    {
        // USER NOT FOUND: need to create them
        new query[256];
        new MySQL:handle = MySQLServerDBContext_GetConnectionHandle();
        
        mysql_format(handle, query, sizeof(query), "INSERT INTO `users` (`username`) VALUES ('%e')", username);
        
        // Execute the insert, and catch the new data in the next internal callback
        mysql_tquery(handle, query, "UserRepositoryInternal_OnFindOrCreateInsert", "ssi", username, callbackFunction, playerid);
    }
    return 1;
}

forward UserRepositoryInternal_OnFindOrCreateInsert(username[], callbackFunction[], playerid);
public UserRepositoryInternal_OnFindOrCreateInsert(username[], callbackFunction[], playerid)
{
    // USER CREATED: cache_insert_id() automatically grabs the AI (Auto-Increment) ID of the row we just inserted
    new userID = cache_insert_id();
    
    // Call the final callback with the newly minted ID
    CallLocalFunction(callbackFunction, "isi", userID, username, playerid);
    return 1;
}

// ----- FIND OR CREATE USER END -----


// ----- FIND USER ID BY USERNAME -----

// returns userID if found, otherwise returns -1.
stock UserRepository_FindUserIDByUsernameAsync(username[], callbackFunction[], playerid = -1)
{
    new query[256];
    new MySQL:handle = MySQLServerDBContext_GetConnectionHandle();

    if (handle == MYSQL_INVALID_HANDLE) {
        printf("[ERROR] Connection handle is invalid.");
        return 0;
    }

    mysql_format(handle, query, sizeof(query), "SELECT `id` FROM `users` WHERE `username` = '%e' LIMIT 1", username);
    
    new successfullyQueued = mysql_tquery(handle, query, "UserRepositoryInternal_FindUserIDByUsernameCallback", "ssi", username, callbackFunction, playerid);
    
    return successfullyQueued;
}

forward UserRepositoryInternal_FindUserIDByUsernameCallback(username[], callbackFunction[], playerid);
public UserRepositoryInternal_FindUserIDByUsernameCallback(username[], callbackFunction[], playerid)
{
    new userID = -1; // Default if not found

    if (cache_num_rows() > 0) 
    {
        cache_get_value_name_int(0, "id", userID);
    }

    CallLocalFunction(callbackFunction, "isi", userID, username, playerid);
}

// ----- FIND USER ID BY USERNAME END -----
