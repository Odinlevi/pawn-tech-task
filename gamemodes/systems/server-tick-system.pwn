#include "systems/greenhouses-system.pwn"

forward ServerTickSystemFireTick();
public ServerTickSystemFireTick()
{
    ProcessNextGreenhouseChunk();
}
