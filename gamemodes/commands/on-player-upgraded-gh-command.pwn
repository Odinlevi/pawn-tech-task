#include "systems/greenhouses-system.pwn"

stock OnPlayerUpgradedGhCommand(playerid, positionID)
{
    SendClientMessage(playerid, -1, "Upgrading Greenhouse at position %d...", positionID);

    new cacheHit = GreenhouseSystem_FindGreenhouseIndexByPlayerAndPositionID(playerid, positionID);

    if (cacheHit == -1)
    {
        SendClientMessage(playerid, -1, "No greenhouse found at this position to upgrade.");
        return 1;
    }

    new bool:successUpgrade = GreenhouseSystem_UpgradeGreenhouse(cacheHit);
    printf("GreenhouseSystem_UpgradeGreenhouse response for greenhouse index %d: %d", cacheHit, successUpgrade);

    if (successUpgrade)
    {
        SendClientMessage(playerid, -1, "Greenhouse at position %d upgraded successfully.", positionID);
    }
    else
    {
        SendClientMessage(playerid, -1, "Failed to upgrade greenhouse at position %d.", positionID);
    }

    return 1;
}