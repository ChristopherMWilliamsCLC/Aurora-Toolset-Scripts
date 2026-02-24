//////////////////////////////
//Created By: Chris Williams//
//Date: 8/18/25///////////////
//////////////////////////////

/*
    Description:
    Set of functions for creating a hostile mimic of a player.
    The copy drops no items or gold and attacks the player as
    soon as it's created.

    Notes:
    EraseInventoryItems() and SetEquippedUndroppable() are both
    needed because EraseInventoryItems only destroys items in
    the targets inventory, equipped items don't get destroyed.
    You need the mimic to have the same equipped gear as the
    player so destroying the gear wouldn't be an option anyways.
    Instead you can set the equipped items to undroppable so that
    they can't be picked up after the mimic dies. This was originally
    created to be used on a placeables OnUsed event but i'll leave
    it to the developer to use it wherever they want.
*/

////////////////////////
//Function Definitions//
////////////////////////

// Destroy every object in the inventory of oTarget.
void EraseInventoryItems(object oTarget);

// Set every equipped item of oCreature to undroppable.
void SetEquippedUndroppable(object oCreature);

// Create a hostile copy of oPC. The copy drops no loot & attacks oPC. The caller object of this function is destroyed.
void CreateMimic(object oPC);

// oPC is the player character who created the mimic. Returns OBJECT_INVALID on failure.
object GetMimic(object oPC);

///////////////////////////
//Function Implementation//
///////////////////////////

void EraseInventoryItems(object oTarget)
{
    object oItem = GetFirstItemInInventory(oTarget);
    while(oItem != OBJECT_INVALID)
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oTarget);
    }
}

void SetEquippedUndroppable(object oCreature)
{
    object oSlot;
    int i = 0;
    while(i < 16)
    {
        oSlot = GetItemInSlot(i, oCreature);
        if(oSlot != OBJECT_INVALID)
        {
            SetDroppableFlag(oSlot, FALSE);
        }
        i++;
    }
}

void CreateMimic(object oPC)
{
    object oMimic;
    object oSelf = OBJECT_SELF;
    string sNewTag = GetSubString(GetObjectUUID(oPC), 0, 10) + "mimic";
    effect eVFX = EffectVisualEffect(VFX_DUR_GHOST_TRANSPARENT);
    effect eVFX2 = EffectVisualEffect(VFX_DUR_GHOST_SMOKE_2);

    // If the user of the placeable is a player character continue.
    if(GetIsPC(oPC)) {
        // Create a floating text string above the player.
        FloatingTextStringOnCreature(GetStringUpperCase("--The " + GetName(oSelf) + " mimics you--"), oPC, FALSE);
        // Make a copy of the player that used the placeable.
        CopyObject(oPC, GetLocation(oSelf), OBJECT_INVALID, sNewTag, FALSE);
        // Destroy the placeable.
        DestroyObject(oSelf);
        // Get the copy of the player object using the new tag.
        oMimic = GetObjectByTag(sNewTag);
        // Change the name of the mimic.
        SetName(oMimic, GetName(oPC) + "'s" + " Mimic");
        // Erase the inventory items held by the copy.
        EraseInventoryItems(oMimic);
        // Set equipped items of the copy to undroppable.
        SetEquippedUndroppable(oMimic);
        // Set the copys gold to equal 0.
        TakeGoldFromCreature(GetGold(oMimic), oMimic, TRUE);
        // Apply visual effect 1 to the mimic.
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVFX, oMimic);
        // Apply visual effect 2 to the mimic.
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVFX2, oMimic);
        // Set the copy to hostile.
        ChangeToStandardFaction(oMimic, STANDARD_FACTION_HOSTILE);
        // Make the copy attack the player.
        AssignCommand(oMimic, ActionAttack(oPC));
    }
}

object GetMimic(object oPC)
{
    object oMimic = GetObjectByTag(GetSubString(GetObjectUUID(oPC), 0, 10) + "mimic");
    if(oMimic != OBJECT_INVALID)
        return oMimic;
    return OBJECT_INVALID;
}
