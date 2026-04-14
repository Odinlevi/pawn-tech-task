#if defined _MYSQL_SERVER_DB_CONTEXT_INCLUDED
    #endinput
#endif
#define _MYSQL_SERVER_DB_CONTEXT_INCLUDED

#include <a_mysql>

#define DB_HOST "127.0.0.1"
#define DB_USER "admin"
#define DB_PASSWORD "12345678"
#define DB_NAME "tech_task_server"

static MySQL:gMysqlConnectionHandle;

// todo: connection pools.
stock MySQLServerDBContext_InitializeDatabase()
{
    new errno;
    gMysqlConnectionHandle = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);
    
    errno = mysql_errno(gMysqlConnectionHandle);
    
    if (errno != 0) 
    {
        new error[100];
    
        mysql_error(error, sizeof (error), gMysqlConnectionHandle);
        printf("[ERROR] #%d '%s'", errno, error);
    }
    else
    {
        printf("Successfully connected to the MySQL database.");
    }

    new registered_players, Cache:result = mysql_query(gMysqlConnectionHandle, "SELECT COUNT(*) FROM `users`");
    cache_get_value_int(0, 0, registered_players);
    printf("There are %d players in the database.", registered_players);
    cache_delete(result);

    return 1;
}

stock MySQLServerDBContext_ReopenConnection()
{
    mysql_close(gMysqlConnectionHandle);
    return MySQLServerDBContext_InitializeDatabase();
}

stock MySQLServerDBContext_CloseDatabase()
{
    mysql_close(gMysqlConnectionHandle);
    printf("MySQL database connection closed.");
    return 1;
}

stock MySQLServerDBContext_GetConnectionHandle()
{
    return gMysqlConnectionHandle;
}
