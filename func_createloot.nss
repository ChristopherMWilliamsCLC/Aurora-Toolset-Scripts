
/*
    -Loot system that generates loot directly from shops in the game.
    -Lets you choose how many items to create.
    -Lets you convert an item to a percentage of it's gold value with a percent chance.
*/

////////////////////
//Default Settings//
////////////////////

// Percent chance out of 100 for a created item to be converted to gold.
const int GOLD_CONVERSION_CHANCE = 30;

// Percent of the converted items gold value to be given. (1.0 gives 100% of the converted items value in gold)
const float GOLD_CONVERSION_PERCENTAGE = 0.25;

//////////////////
//SHOP CONSTANTS//
//////////////////

const string SHOP_MISC_001 = "LDS_MISC_001"; // Misc items like potions/kits/scrolls
const string SHOP_STARTING_EQUIPMENT = "m_hok_startingequipment"; // level 1
const string SHOP_LEVEL_FOUR_THROUGH_FIVE = "LDS_FOUR_THROUGH_FIVE"; // level 4-5 loot.
const string SHOP_LEVEL_SEVEN_THROUGH_TEN = "LDS_SEVEN_THROUGH_TEN"; // level 7-10 loot.
//const string YOUR_SHOP_HERE = "YOUR_SHOPS_TAG";

////////////////////////
//Function Definitions//
////////////////////////

// iIn out of iOutOf chance.
int RandomChance(int iIn, int iOutOf);

// Loops through a shops inventory and creates items up to iMaxNumberOfItems on oCreature.
// sShop = Tag name of the shop. (Can use constants above for this)
// iChance = Percent chance out of 100 for items to be created from the shop.
// iMaxNumberOfItems = Maximum number of items that can be created from the shop.
// iGoldConvertChance = Percent chance out of 100 to convert a generated item into gold. Set to a 30% chance by default.
// fGoldConversionPercent = If an item is converted to gold this indicates what percent of the items gold value should be given, it's set to 15% by default.
// oCreature = Creature to create the shop items on. OBJECT_SELF by default.
void CreateShopItems(string sShop, int iChance, int iMaxNumberOfItems, int iGoldConvertChance = GOLD_CONVERSION_CHANCE, float fGoldConversionPercent = GOLD_CONVERSION_PERCENTAGE, object oCreature = OBJECT_SELF);

// Generates loot based on the creatures challenge rating in the OnSpawn event of the creature. Replacement for biowares default loot model in nw_c2_default9. (Max CR is 125)
void CreateLoot();

///////////////////////////
//Function Implementation//
///////////////////////////

int RandomChance(int iIn, int iOutOf)
{
    int iRandom = Random(iOutOf);
    if(iRandom == 0) return FALSE;
    if(iRandom <= iIn)
        return TRUE;
    else
        return FALSE;
}

void CreateShopItems(string sShop, int iChance, int iMaxNumberOfItems, int iGoldConvertChance=30, float fGoldConversionPercent=0.15, object oCreature = OBJECT_SELF)
{
    object oShop = GetObjectByTag(sShop);
    if(GetLocalInt(oCreature, "DO_ONCE") == FALSE)
    {
        if(RandomChance(iChance, 100)) {

            // Initialize the data for the shop items if it doesn't exist.
            if(GetLocalObject(oShop, "Item #" + IntToString(0)) == OBJECT_INVALID)
            {
                int i = 0;
                object oItem = GetFirstItemInInventory(oShop);
                while(oItem != OBJECT_INVALID)
                {
                    SetLocalString(oShop, "Item #" + IntToString(i), GetResRef(oItem));
                    SetLocalObject(oShop, "Item #" + IntToString(i), oItem);
                    oItem = GetNextItemInInventory(oShop);
                    i++;
                }
                // Set amount of items in the shop. (0 counts as an item so if theirs 44 items this will be 43)
                SetLocalInt(oShop, sShop, i);
            }

            // Get amount of items in the shop.
            int iTotalItems = GetLocalInt(oShop, sShop);

            //SpeakString("TOTAL ITEMS: " + IntToString(iTotalItems+1));

            int iItemDrops = 0;
            while(iItemDrops < iMaxNumberOfItems)
            {

                int iRandomShopItem = Random(iTotalItems);
                string sRandomItemResRef = GetLocalString(oShop, "Item #" + IntToString(iRandomShopItem));
                object oRandomItemObject = GetLocalObject(oShop, "Item #" + IntToString(iRandomShopItem));
                int iStackSize = GetItemStackSize(oRandomItemObject);
                object oCreatedItem = CreateItemOnObject(sRandomItemResRef, oCreature, iStackSize);

                //SpeakString("RANDOM ITEM #: " + IntToString(iRandomShopItem));
                //SpeakString("CREATED ITEM RESREF: " + GetResRef(oCreatedItem));

                // Random chance to convert a created item into a percentage of it's unidentified gold value.
                if(RandomChance(iGoldConvertChance, 100))
                {
                    SetIdentified(oCreatedItem, TRUE);
                    int iGoldValue = FloatToInt(GetGoldPieceValue(oCreatedItem) * fGoldConversionPercent);
                    iGoldValue = (iGoldValue < 1) ? 1 : iGoldValue; // If gold value is less than 1 it's 1 otherwise it's the new gold value.
                    //SpeakString("CONVERTED ITEM GOLD VALUE: " + IntToString(iGoldValue));
                    DestroyObject(oCreatedItem);
                    CreateItemOnObject("NW_IT_GOLD001", oCreature, iGoldValue);
                }
                iItemDrops++;
            }
        }
        SetLocalInt(oCreature, "DO_ONCE", TRUE);
    }
}

// Default OnDeath replacement for biowares default loot model in nw_c2_default9. (Max CR is 125)
void CreateLoot()
{
    float fChallengeRating = GetChallengeRating(OBJECT_SELF);
    switch(FloatToInt(fChallengeRating))
    {
        case 1:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_STARTING_EQUIPMENT, 15, 2);
            break;
        case 2:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_STARTING_EQUIPMENT, 15, 2);
            break;
        case 3:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_STARTING_EQUIPMENT, 15, 2);
            break;
        case 4:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_LEVEL_FOUR_THROUGH_FIVE, 15, 2);
            break;
        case 5:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_LEVEL_FOUR_THROUGH_FIVE, 15, 2);
            break;
        case 6:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_LEVEL_FOUR_THROUGH_FIVE, 15, 2);
            break;
        case 7:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_LEVEL_SEVEN_THROUGH_TEN, 15, 2);
            break;
        case 8:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_LEVEL_SEVEN_THROUGH_TEN, 15, 2);
            break;
        case 9:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_LEVEL_SEVEN_THROUGH_TEN, 15, 2);
            break;
        case 10:
            CreateShopItems(SHOP_MISC_001, 20, 4, 0, 0.0);
            CreateShopItems(SHOP_LEVEL_SEVEN_THROUGH_TEN, 15, 2);
            break;
        case 11:
            break;
        case 12:
            break;
        case 13:
            break;
        case 14:
            break;
        case 15:
            break;
        case 16:
            break;
        case 17:
            break;
        case 18:
            break;
        case 19:
            break;
        case 20:
            break;
        case 21:
            break;
        case 22:
            break;
        case 23:
            break;
        case 24:
            break;
        case 25:
            break;
        case 26:
            break;
        case 27:
            break;
        case 28:
            break;
        case 29:
            break;
        case 30:
            break;
        case 31:
            break;
        case 32:
            break;
        case 33:
            break;
        case 34:
            break;
        case 35:
            break;
        case 36:
            break;
        case 37:
            break;
        case 38:
            break;
        case 39:
            break;
        case 40:
            break;
        default:
            break;
    }
}
