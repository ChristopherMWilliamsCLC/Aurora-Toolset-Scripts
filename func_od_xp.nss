///////////////////////////////////////
/// Created By: Christopher Williams //
/// Date: 7/23/2025 ///////////////////
/// Email: cw174531@gmail.com//////////
///////////////////////////////////////

/*
    ///////////////
    //TERMINOLOGY//
    ///////////////

    True Challenge Rating: The challenge rating that you see when you examine an enemy creature in game.
    Enemy Challenge Rating: The challenge rating of a creature in toolset.

    ///////////////////////
    //CALCULATION EXAMPLE//
    ///////////////////////

    XP calculation = (XP_YEILD * ENEMY_CHALLENGE_RATING) + ((XP_YEILD * ENEMY_CHALLENGE_RATING) * XP_MULTIPLIER_BY_TRUE_CR)

    Lets say you examine a creature in game and it's true CR is challenging(0.25 multiplier).
    Lets say the creature CR is 10 and the xp yield is 15.
    The xp for killing this creature is (15 * 10) + ((15 * 10) * 0.25) = 187 (rounds down)

    Lets say we use the same calculation but the creature is effortless(-0.99 multiplier)
    The xp for killing this creature is (15 * 10) + ((15 * 10) * -0.99) = 1 (rounds down)

    For the first calculation your charachter is level 9-10.
    For the second calculation your charachter is level 16+.

    //////////////////////
    //USEFUL INFORMATION//
    //////////////////////

    -The maximum possible xp in this system using the default settings is 3750 because the maximum creature CR is 125.
     It can be higher or lower by modifying the XP_YIELD and TCR multiplier constants.

    -Make sure you turn off the xp slider on your module if you're using this.

    -Adding GiveXpGp(); inside nw_c2_default7 will handle xp/gp for every creature. You can also do it on a creature to creature
     basis but I reccomend adding it to nw_c2_default7 (default OnDeath handler).
     ---------------------------------------
     [nw_c2_default7 implementation example]
     ---------------------------------------
     #include "func_od_xp"
     void main()
     {
        int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
        int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
        object oKiller = GetLastKiller();

        GiveXpGp();
        And so on..
     }
*/

////////////////
//OPTIONS MENU//
////////////////

// Distance in meters that a player will receive xp. If it's 100.0, the player wont get xp for something killed 101.0 meters away. Stops party members from getting xp for not being in the area.
const float XP_DISTANCE = 250.0;

// The level range which party members can receive xp. If PARTY_LEVEL_RANGE = 5; a group member 6 levels below or above you wont get xp.
const int PARTY_LEVEL_RANGE = 5;

// The xp yield is the amount that you multiply the enemy challenge rating by.
const int XP_YIELD = 15;

// Setting this to 1.0 means the killer gets double the gold for the amount of xp received. Set this to -1.0 to turn off the gold reward.
const float GOLD_MULTIPLIER = 1.0;

// You can set the XP_MULTIPLIER_BY_TRUE_CR based on the true challenge rating.
const float EFFORTLESS = -0.99; // 6+ levels lower
const float EASY = -0.50; // 4-5 levels lower
const float MODERATE = 0.00; // 2-3 levels lower
const float CHALLENGING = 0.25; // Same level of 1 level lower
const float VERY_DIFFICULT = 0.50; // 1-2 levels higher
const float OVERPOWERING = 0.75; // 3-4 levels higher
const float IMPOSSIBLE = 1.0; // 5+ levels higher

////////////////////////
//FUNCTION DEFINITIONS//
////////////////////////

// Get oPC level by xp amount to stop power leveling.
int GetLevelByXp(object oPC);

// Gets the level of the killer. If the killer is an associate, get the master of the associate.
int GetKillerLevel();

// Get the true challenge rating using the level difference between the killer and the killed. Returns the above xp multiplier constants.
float GetTrueChallengeRating();

// Print the true challenge rating of the creature that was just killed.
void PrintTrueCR(object oPC);

// Multiplies XpAmount by the constant values above. Based on the true challenge rating of the encounter.
int ChallengeRatingXpMultiplier(int XpAmount);

// Get the killed enemys xp yield by multiplying iXpYeild by it's challenge rating. (Not it's true challenge rating)
int EnemyXpYieldByCR(int iXpYield);

// Check if the party is not within the valid radius to receive xp.
int PartyNotInValidRadius(object oParty);

// Check if the party is in the valid level range to receive xp.
int PartyInValidLevelRange(object oKiller, object oParty);

// Wraps everything together to give xp & gp to the killer, and party. (Put this in nw_c2_default7)
void GiveXpGp();

/////////////
//FUNCTIONS//
/////////////

int GetLevelByXp(object oPC)
{
    int i = 0;
    int iPlayerXp = GetXP(oPC);
    while(i < 39)
    {
        i += 1;
        int iLowerBound = ((i * (i - 1)) / 2) * 1000;
        int iUpperBound = (((i+1) * ((i+1) - 1)) / 2) * 1000;
        if(iPlayerXp >= 780000) return 40;
        if(iPlayerXp >= iLowerBound && iPlayerXp < iUpperBound) return i;
    }
    return -1;
}

int GetKillerLevel()
{
    object oKiller = GetLastKiller();
    int iKillerLevel = 0;
    if(GetIsPC(oKiller)) {
        iKillerLevel = GetLevelByXp(oKiller);
    } else {
        object oMaster = GetMaster(oKiller);
        iKillerLevel = GetLevelByXp(oMaster);
    }
    return iKillerLevel;
}

float GetTrueChallengeRating()
{
    float fKillerCR = IntToFloat(GetKillerLevel());
    float fSelfCR = GetChallengeRating(OBJECT_SELF);
    float fLevelDifference = fSelfCR - fKillerCR;
    float iTrueCR = 0.0;

    if(fLevelDifference >= 5.0) iTrueCR = IMPOSSIBLE;
    if(fLevelDifference == 4.0 || fLevelDifference == 3.0) iTrueCR = OVERPOWERING;
    if(fLevelDifference == 2.0 || fLevelDifference == 1.0) iTrueCR = VERY_DIFFICULT;
    if(fLevelDifference == 0.0 || fLevelDifference == -1.0) iTrueCR = CHALLENGING;
    if(fLevelDifference == -3.0 || fLevelDifference == -2.0) iTrueCR = MODERATE;
    if(fLevelDifference == -5.0 || fLevelDifference == -4.0) iTrueCR = EASY;
    if(fLevelDifference <= -6.0) iTrueCR = EFFORTLESS;

    // Handle 1/8th CR rated creatures.
    if(fSelfCR == 0.125 && fKillerCR > 1.0) {
        return EFFORTLESS;
    }
    if(fSelfCR == 0.125 && fKillerCR == 1.0) {
        return EASY;
    }

    // Handle 1/4th CR rated creatures.
    if(fSelfCR == 0.25 && fKillerCR >= 4.0) {
        return EFFORTLESS;
    }
    if(fSelfCR == 0.25 && (fKillerCR >= 2.0 && fKillerCR < 4.0)) {
        return EASY;
    }
    if(fSelfCR == 0.25 && fKillerCR == 1.0) {
        return MODERATE;
    }

    return iTrueCR;
}

void PrintTrueCR(object oPC)
{
    SendMessageToPC(oPC, "The enemy CR is " + FloatToString(GetChallengeRating(OBJECT_SELF)) + " the xp yield is " + IntToString(XP_YIELD));
    if(GetTrueChallengeRating() == EFFORTLESS) SendMessageToPC(oPC, "The true CR is Effortless -> Xp Multiplier = " + FloatToString(EFFORTLESS));
    if(GetTrueChallengeRating() == EASY) SendMessageToPC(oPC, "The true CR is Easy -> Xp Multiplier = " + FloatToString(EASY));
    if(GetTrueChallengeRating() == MODERATE) SendMessageToPC(oPC, "The true CR is Moderate -> Xp Multiplier = " + FloatToString(MODERATE));
    if(GetTrueChallengeRating() == CHALLENGING) SendMessageToPC(oPC, "The true CR is Challenging -> Xp Multiplier = " + FloatToString(CHALLENGING));
    if(GetTrueChallengeRating() == VERY_DIFFICULT) SendMessageToPC(oPC, "The true CR is Very Difficult -> Xp Multiplier = " + FloatToString(VERY_DIFFICULT));
    if(GetTrueChallengeRating() == OVERPOWERING) SendMessageToPC(oPC, "The true CR is Overpowering -> Xp Multiplier = " + FloatToString(OVERPOWERING));
    if(GetTrueChallengeRating() == IMPOSSIBLE) SendMessageToPC(oPC, "The true CR is Impossible -> Xp Multiplier = " + FloatToString(IMPOSSIBLE));
    SendMessageToPC(oPC, "Xp Received = " + FloatToString(GetChallengeRating(OBJECT_SELF)) + " * " + IntToString(XP_YIELD) + " + ((" + FloatToString(GetChallengeRating(OBJECT_SELF)) + " * " + IntToString(XP_YIELD) + ") * " + FloatToString(GetTrueChallengeRating()) + " = " + IntToString(ChallengeRatingXpMultiplier(EnemyXpYieldByCR(XP_YIELD))) + ")");
}

int ChallengeRatingXpMultiplier(int XpAmount)
{
    int fXpToGive = FloatToInt(XpAmount + (XpAmount * GetTrueChallengeRating()));
    return fXpToGive;
}

int EnemyXpYieldByCR(int iXpYield)
{
    int iXpToGive = iXpYield;
    int fSelfCR = FloatToInt(GetChallengeRating(OBJECT_SELF));

    if(fSelfCR < 1) {
        return iXpToGive;
    }
    else {
        return iXpToGive * fSelfCR;
    }
}

int PartyNotInValidRadius(object oParty)
{
    float fDist = GetDistanceToObject(oParty);
    return fDist == -1.0 || fDist > XP_DISTANCE;
}

int PartyInValidLevelRange(object oKiller, object oParty)
{
    return abs(GetLevelByXp(oKiller) - GetLevelByXp(oParty)) <= PARTY_LEVEL_RANGE;
}

void GiveXpGp()
{
    object oPC = GetLastKiller();
    object oKiller = oPC;

    if(!GetIsPC(oPC)) {
        oKiller = GetMaster(oPC);
    }

    //PrintTrueCR(oKiller);

    int iXpYield = EnemyXpYieldByCR(XP_YIELD);
    int iXpToGive = ChallengeRatingXpMultiplier(iXpYield);
    int iGpToGive = FloatToInt(iXpToGive + (iXpToGive * GOLD_MULTIPLIER));

    object oParty = GetFirstFactionMember(oKiller);
    while(oParty != OBJECT_INVALID)
    {
        if(PartyNotInValidRadius(oParty) || !PartyInValidLevelRange(oKiller, oParty)) {
            oParty = GetNextFactionMember(oKiller);
            continue;
        }
        GiveXPToCreature(oParty, iXpToGive);
        GiveGoldToCreature(oParty, iGpToGive);
        oParty = GetNextFactionMember(oKiller);
    }
}
