#include "systems/greenhouses-system.pwn"

#if defined _server_tick_system_included
    #endinput
#endif
#define _server_tick_system_included

#if !defined SERVER_TICK_INTERVAL
    #define SERVER_TICK_INTERVAL 20 // Time in milliseconds for each server tick (50 ticks per second)
#endif

#if !defined SERVER_TICKS_PER_SECOND
    #define SERVER_TICKS_PER_SECOND (1000 / SERVER_TICK_INTERVAL)
#endif


forward ServerTickSystemFireTick();
public ServerTickSystemFireTick()
{
    static g_ServerTick_CurrentSecondTick = 0; // i don't know how i can encapsulate this better without using a static variable.
    g_ServerTick_CurrentSecondTick++;
    
    // ----- block for triggered systems that run every tick -----

    ProcessNextGreenhouseChunk();

    // ----- end block for triggered systems that run every tick -----

    if (g_ServerTick_CurrentSecondTick >= SERVER_TICKS_PER_SECOND) // If we've reached 1 second (1000 ms)
    {
        g_ServerTick_CurrentSecondTick = 0; // Reset the tick counter

        // ----- block for triggered systems that run every second -----

        // (Currently empty)

        // ----- end block for triggered systems that run every second -----
    } 
}
