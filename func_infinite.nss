/*
The beauty of these is that you can run the same placeable/creature with the same script as many times as you want and they'll all be
considered as unique because of UUID. In other words you don't need to make a completely new placeable with a new tag and a new script
name to run multiple instances of these functions. You can make a placeable, add InfinitySpawnerPlaceable in the OnHeartbeat event and
use it as many times as you want in the same area without a problem. Just don't forget to put InfinitySpawnerPlaceableSpawnDeath("Placeable");
in the OnDeath event of the creature you're spawning with InfinitySpawnerPlaceable.
*/

// Use this script in the Heartbeat event of a placeable object to infinitely spawn a creature up to iMaxSpawnAmount in number.
// It's very important that you set the "InfinityPlaceableSpawnDeath(string sSpawnerTag)" in the OnDeath event of the creature you're spawning.
// If you want a placeable to keep spawning a creature until it dies this is the correct function to use.
// WARNING!! Don't create a infinity spawn which creates a creature that creates another creature. You can crash your game.
// sCreatureResRef = Resref ID of the creature you want to spawn infinitely.
// sCreatureTag = Tag of the creature you want to spawn infinitely.
// iMaxSpawnAmount = Maximum amount of creatures to spawn. (Note: After a creature is killed it spawns another up to this amount infinitely.)
// fSpawnFrequency = How many seconds it takes between each spawn. Example: Setting this to 5.0(Default Value) will spawn a creature every 5 seconds.
// iVFX = EffectVisualEffect(iVFX); List of visual effects here: https://nwnlexicon.com/index.php/EffectVisualEffect
void InfinitySpawnerPlaceable(string sCreatureResRef, string sCreatureTag, int iMaxSpawnAmount, float fSpawnFrequency=5.0, int iVFX=0);

// Whichever creature you're spawning with the InfintySpawnerPlaceable function needs to have this placed in their OnDeath event.
void InfinityPlaceableSpawnDeath();

// Use this script in the Heartbeat event of a creature object to infinitely spawn a creature up to iMaxSpawnAmount in number.
// It's very important that you set the "InfinityCreatureSpawnDeath(string sSpawnerTag)" in the OnDeath event of the creature you're spawning.
// If you want a enemy creature to keep spawning a creature until it dies this is the correct function to use.
// WARNING!! Don't create a infinity spawn which creates a creature that creates another creature. You can crash your game.
// sCreatureResRef = Resref ID of the creature you want to spawn infinitely.
// sCreatureTag = Tag of the creature you want to spawn infinitely.
// iMaxSpawnAmount = Maximum amount of creatures to spawn. (Note: After a creature is killed it spawns another up to this amount infinitely.)
// fSpawnFrequency = How many seconds it takes between each spawn. Example: Setting this to 5.0(Default Value) will spawn a creature every 5 seconds.
// iVFX = EffectVisualEffect(iVFX); List of visual effects here: https://nwnlexicon.com/index.php/EffectVisualEffect
void InfinitySpawnerCreature(string sCreatureResRef, string sCreatureTag, int iMaxSpawnAmount, float fSpawnFrequency=5.0, int iVFX=0);

// Whichever creature you're spawning with the InfinitySpawnerCreature function needs to have this placed in their OnDeath event.
void InfinityCreatureSpawnDeath();

/////////////
//FUNCTIONS//
/////////////

// Checks if theirs a player charachter in the area where the caller of the script is located.
// Returns TRUE if theirs a player in the area and FALSE if theirs not.
int PCInArea()
{
    object oPlayer = GetFirstPC();
    while(oPlayer != OBJECT_INVALID)
    {
        object oPlayerArea = GetArea(oPlayer);
        if(oPlayerArea == GetArea(OBJECT_SELF))
        {
            return TRUE;
        }
        oPlayer = GetNextPC();
    }
    return FALSE;
}

///////////////////////
//Placeable Functions//
///////////////////////

void InfinitySpawnerPlaceable(string sCreatureResRef, string sCreatureTag, int iMaxSpawnAmount, float fSpawnFrequency=5.0, int iVFX=0)
{
    if(GetLocalInt(OBJECT_SELF, "DISABLE") == 1)
    {
        return;
    }

    if( PCInArea() == TRUE )
    {
        int iSpawnAmount = GetLocalInt(OBJECT_SELF, "SpawnAmount");
        int iCutOffAmount = GetLocalInt(OBJECT_SELF, "CutOffAmount");

        while(iSpawnAmount < 1)
        {
            vector vPos = GetPosition(OBJECT_SELF);
            location lSpawnLocation = Location(GetArea(OBJECT_SELF), vPos, GetFacing(OBJECT_SELF) + 180.0);
            effect eVFX = EffectVisualEffect(iVFX);

            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lSpawnLocation);
            CreateObject(OBJECT_TYPE_CREATURE, sCreatureResRef, lSpawnLocation);
            SpeakString("Created a " + GetName(GetObjectByTag(sCreatureTag)));
            SetLocalInt(OBJECT_SELF, "SpawnAmount", iSpawnAmount +=1);
            SetLocalInt(OBJECT_SELF, "CutOffAmount", iCutOffAmount +=1);
        }

        object oInfinitySpawn = GetObjectByTag(sCreatureTag);
        DelayCommand(1.0, SetLocalInt(oInfinitySpawn, "Spawner" + GetObjectUUID(OBJECT_SELF), 1));
        DelayCommand(fSpawnFrequency, DeleteLocalInt(OBJECT_SELF, "SpawnAmount"));

        if(iCutOffAmount == iMaxSpawnAmount)
        {
            SetLocalInt(OBJECT_SELF, "DISABLE", 1);
        }
    }
}

void InfinityPlaceableSpawnDeath()
{
    object oAll = GetFirstObjectInArea(GetArea(OBJECT_SELF), OBJECT_TYPE_PLACEABLE);
    while(oAll != OBJECT_INVALID)
    {
        string sSpawner = GetObjectUUID(oAll);
        if(GetLocalInt(OBJECT_SELF, "Spawner" + sSpawner) == 1)
        {
            object oSpawner = GetObjectByUUID(sSpawner);
            int iCutOffAmount = GetLocalInt(oSpawner, "CutOffAmount");
            SetLocalInt(oSpawner, "CutOffAmount", iCutOffAmount -=1);
            if(GetLocalInt(oSpawner, "DISABLE") == 1)
            {
                DeleteLocalInt(oSpawner, "DISABLE");
            }
        }
        oAll = GetNextObjectInArea(GetArea(OBJECT_SELF), OBJECT_TYPE_PLACEABLE);
    }
}

//////////////////////
//Creature Functions//
//////////////////////

void InfinitySpawnerCreature(string sCreatureResRef, string sCreatureTag, int iMaxSpawnAmount, float fSpawnFrequency=5.0, int iVFX=0)
{
    if(GetLocalInt(OBJECT_SELF, "DISABLE") == 1)
    {
        return;
    }

    if(PCInArea() == TRUE)
    {
        int iSpawnAmount = GetLocalInt(OBJECT_SELF, "SpawnAmount");
        int iCutOffAmount = GetLocalInt(OBJECT_SELF, "CutOffAmount");

        while(iSpawnAmount < 1)
        {
            vector vPos = GetPosition(OBJECT_SELF);
                   vPos.x = vPos.x + (1.0 * Random(10));
                   vPos.y = vPos.y + (1.0 * Random(10));
            location lSpawnLocation = Location(GetArea(OBJECT_SELF), vPos, 1.0 * Random(360));
            effect eVFX = EffectVisualEffect(iVFX);

            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lSpawnLocation);
            CreateObject(OBJECT_TYPE_CREATURE, sCreatureResRef, lSpawnLocation);
            SpeakString("Created a " + GetName(GetObjectByTag(sCreatureTag)));
            SetLocalInt(OBJECT_SELF, "SpawnAmount", iSpawnAmount +=1);
            SetLocalInt(OBJECT_SELF, "CutOffAmount", iCutOffAmount +=1);
        }

        object oInfinitySpawn = GetObjectByTag(sCreatureTag);
        DelayCommand(1.0, SetLocalInt(oInfinitySpawn, "Spawner" + GetObjectUUID(OBJECT_SELF), 1));
        DelayCommand(fSpawnFrequency, DeleteLocalInt(OBJECT_SELF, "SpawnAmount"));

        if(iCutOffAmount == iMaxSpawnAmount)
        {
            SetLocalInt(OBJECT_SELF, "DISABLE", 1);
        }
    }
}

void InfinityCreatureSpawnDeath()
{
    object oAll = GetFirstObjectInArea(GetArea(OBJECT_SELF), OBJECT_TYPE_CREATURE);
    while(oAll != OBJECT_INVALID)
    {
        string sSpawner = GetObjectUUID(oAll);
        if(GetLocalInt(OBJECT_SELF, "Spawner" + sSpawner) == 1)
        {
            object oSpawner = GetObjectByUUID(sSpawner);
            int iCutOffAmount = GetLocalInt(oSpawner, "CutOffAmount");
            SetLocalInt(oSpawner, "CutOffAmount", iCutOffAmount -=1);
            if(GetLocalInt(oSpawner, "DISABLE") == 1)
            {
                DeleteLocalInt(oSpawner, "DISABLE");
            }
        }
        oAll = GetNextObjectInArea(GetArea(OBJECT_SELF), OBJECT_TYPE_CREATURE);
    }
}

