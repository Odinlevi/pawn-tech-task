#if defined _SERVER_DB_CONTEXT_INCLUDED
    #endinput
#endif
#define _SERVER_DB_CONTEXT_INCLUDED

//todo: persistence should be done with async operations and callbacks; should be used https://github.com/pBlueG/SA-MP-MySQL 

static DB:gDBConnectionHandle;

new ServerDBContext_DatabaseFilename[50];

stock ServerDBContext_InitializeDatabase(db_filename[50])
{
    strcopy(ServerDBContext_DatabaseFilename, db_filename);

    // Open or create the SQLite database
    gDBConnectionHandle = DB_Open(db_filename);
    if (!gDBConnectionHandle)
    {
        print("Failed to open database!");
        return false;
    }

    print("Database initialized successfully.");
    return true;
}

stock ServerDBContext_ReopenConnection()
{
    // Close existing connection if open
    if (gDBConnectionHandle)
    {
        DB_Close(gDBConnectionHandle);
        gDBConnectionHandle = DB:0;
    }

    // Reopen the database connection
    gDBConnectionHandle = DB_Open(ServerDBContext_DatabaseFilename);
    if (!gDBConnectionHandle)
    {
        print("Failed to reopen database!");
        return false;
    }

    print("Database connection reopened successfully.");
    return true;
}

stock ServerDBContext_CloseDatabase()
{
    if (gDBConnectionHandle)
    {
        DB_Close(gDBConnectionHandle);
        gDBConnectionHandle = DB:0;

        print("Database connection closed successfully.");
        return true;
    }
    print("No database connection to close.");
    return false;
}

stock ServerDBContext_GetDBConnectionHandle()
{
    return gDBConnectionHandle;
}
