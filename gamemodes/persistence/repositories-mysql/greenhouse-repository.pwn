#if defined _greenhouse_repository_included
    #endinput
#endif
#define _greenhouse_repository_included

#include "domain/greenhouse.pwn"
#include "persistence/mysql-server-db-context.pwn"

// ----- CREATE GREENHOUSE -----

/* finds array of [MAX_GREENHOUSES_PER_PLAYER] gh_ID, gh_userID, gh_positionID, gh_progress, gh_isUpgraded
   but since Pawn doesn't support arrays of structs, returns only the count of greenhouses found. callback should
   rely in MySQL cache.

   code snippet example:

    forward OnPlayerGreenhousesLoaded(userID, rowCount);
    public OnPlayerGreenhousesLoaded(userID, rowCount)
    {
        // You can declare your array here
        // new PlayerGreenhouses[MAX_GREENHOUSES_PER_PLAYER][E_GREENHOUSE_DATA];

        printf("Loading %d greenhouses for user %d...", rowCount, userID);

        for (new i = 0; i < rowCount; i++)
        {
            // Prevent array out of bounds if they have more rows than max allowed
            if (i >= MAX_GREENHOUSES_PER_PLAYER) break;

            // Fetch directly from the active cache!
            new gh_ID, gh_positionID, gh_progress, gh_isUpgraded;
            
            cache_get_value_name_int(i, "id", gh_ID);
            cache_get_value_name_int(i, "position_id", gh_positionID);
            cache_get_value_name_int(i, "grow_progress_seconds", gh_progress);
            cache_get_value_name_int(i, "is_boosted", gh_isUpgraded);
            
            // PlayerGreenhouses[i][gh_ID] = gh_ID;
            // ... and so on
        }
        return 1;
    }
*/
stock GreenhouseRepository_CreateGreenhouseForUserAsync(userID, positionID, callbackFunction[], playerid = -1)
{
    new query[256];
    new MySQL:handle = MySQLServerDBContext_GetConnectionHandle();

    if (handle == MYSQL_INVALID_HANDLE) {
        printf("[ERROR] Connection handle is invalid.");
        return 0;
    }

    // grow_progress_seconds and is_boosted will default to 0 as per your DB schema
    mysql_format(handle, query, sizeof(query), "INSERT INTO `greenhouses` (`user_id`, `position_id`) VALUES (%d, %d)", userID, positionID);
    
    return mysql_tquery(handle, query, "GreenhouseRepositoryInternal_OnCreate", "ssi", userID, callbackFunction, playerid);
}

forward GreenhouseRepositoryInternal_OnCreate(userID, callbackFunction[], playerid);
public GreenhouseRepositoryInternal_OnCreate(userID, callbackFunction[], playerid)
{
    new newID = -1; // Default to -1 (Failed)

    // cache_affected_rows() returns the number of rows inserted
    if (cache_affected_rows() > 0)
    {
        // Grab the newly generated Auto-Increment ID
        newID = cache_insert_id();
    }

    CallLocalFunction(callbackFunction, "isi", newID, userID, playerid);
    return 1;
}

// ----- CREATE GREENHOUSE END -----


// ----- UPDATE GREENHOUSE -----

// returns id of the newly created greenhouse or -1 if creation failed
stock GreenhouseRepository_UpdateGreenhouseAsync(greenhouseID, progress, isUpgraded, callbackFunction[], playerid = -1)
{
    new query[256];
    new MySQL:handle = MySQLServerDBContext_GetConnectionHandle();

    if (handle == MYSQL_INVALID_HANDLE) {
        printf("[ERROR] Connection handle is invalid.");
        return 0;
    }

    mysql_format(handle, query, sizeof(query), "UPDATE `greenhouses` SET `grow_progress_seconds` = %d, `is_boosted` = %d WHERE `id` = %d", progress, isUpgraded, greenhouseID);
    
    return mysql_tquery(handle, query, "GreenhouseRepositoryInternal_OnUpdate", "sssi", callbackFunction, playerid);
}

forward GreenhouseRepositoryInternal_OnUpdate(callbackFunction[], playerid);
public GreenhouseRepositoryInternal_OnUpdate(callbackFunction[], playerid)
{
    // new success = 0; // 0 = false, 1 = true

    // Note: If the update query sends the EXACT SAME data that is already in the database, 
    // MySQL optimizes it and affects 0 rows. 
    // If you want to consider that a "success" too, you might want to omit this check 
    // and just pass 1, relying on the fact that if the query errored, this callback wouldn't run.
    // if (cache_affected_rows() > 0)
    // {
    //     success = 1;
    // }

    CallLocalFunction(callbackFunction, "isii", 1, playerid);
    return 1;
}

// ----- UPDATE GREENHOUSE END -----


// ----- FIND ALL GREENHOUSES BY USER ID -----

// returns true if update was successful, false otherwise
stock GreenhouseRepository_FindAllGreenhousesByUserAsync(userID, callbackFunction[], playerid = -1)
{
    new query[256];
    new MySQL:handle = MySQLServerDBContext_GetConnectionHandle();

    if (handle == MYSQL_INVALID_HANDLE) {
        printf("[ERROR] Connection handle is invalid.");
        return 0;
    }

    mysql_format(handle, query, sizeof(query), "SELECT * FROM `greenhouses` WHERE `user_id` = %d", userID);
    
    return mysql_tquery(handle, query, "GreenhouseRepositoryInternal_OnFindAll", "isi", userID, callbackFunction, playerid);
}

forward GreenhouseRepositoryInternal_OnFindAll(userID, callbackFunction[], playerid);
public GreenhouseRepositoryInternal_OnFindAll(userID, callbackFunction[], playerid)
{
    new rowCount = cache_num_rows();
    
    // Here is passed the row count to the callback.
    // Because CallLocalFunction runs synchronously, the MySQL cache is still
    // active in the callback.
    CallLocalFunction(callbackFunction, "iii", userID, rowCount, playerid);
    return 1;
}

// ----- FIND ALL GREENHOUSES BY USER ID END -----
