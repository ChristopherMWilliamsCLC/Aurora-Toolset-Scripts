#include "func_od_xp"

/////////////
//Constants//
/////////////

// Landmark constants.
const string LANDMARK_001 = "SnowyHillCampsite";
const string LANDMARK_002 = "WizardTowerPortal";
const string LANDMARK_003 = "DragonBones";
const string LANDMARK_004 = "HuntersRest";
const string LANDMARK_005 = "MountainBaseCamp";

// Quest constants.
const string QUEST_WOLF_HIDE = "WolfHide";
const string QUEST_DRUGO_GOBLIN_CHEIF = "GoblinCheif";
const string QUEST_DRUGO_GOBLIN_KILL_COUNT = "GoblinKillCount";
const string QUEST_KAMINDRA_PART_I = "KamindraPartOne";
const string QUEST_KAMINDRA_PART_II = "KamindraPartTwo";
const string QUEST_UNDEAD_KILL_COUNT = "UndeadKillCount";
const string QUEST_TROLL_KILL_COUNT = "TrollKillCount";
const string QUEST_COUGAR_KILL_COUNT = "CougarKillCount";
const string QUEST_ETTIN_KILL_COUNT = "EttinKillCount";
const string QUEST_POLAR_BEAR_KILL_COUNT = "PolarBearKillCount";
const string QUEST_OGRE_KILL_COUNT = "OgreKillCount";
const string QUEST_RETAKE_THE_FORT = "RetakeTheFort";

// Plot ID constants.
const string PLOT_ID_WOLF_HIDE = "WolfHidePlot";
const string PLOT_ID_DRUGO_GOBLIN_CHEIF = "DrugoGolblinCheifPlot";
const string PLOT_ID_DRUGO_GOBLIN_KILL_COUNT = "DrugoGoblinKillCount";
const string PLOT_ID_KAMINDRA_PART_I = "KamindraPartOnePlot";
const string PLOT_ID_KAMINDRA_PART_II = "KamindraPartTwoPlot";
const string PLOT_ID_UNDEAD_KILL_COUNT = "UndeadKillCountPlot";
const string PLOT_ID_TROLL_KILL_COUNT = "TrollKillCountPlot";
const string PLOT_ID_COUGAR_KILL_COUNT = "CougarKillCountPlot";
const string PLOT_ID_ETTIN_KILL_COUNT = "EttinKillCountPlot";
const string PLOT_ID_POLAR_BEAR_KILL_COUNT = "PolarBearKillCountPlot";
const string PLOT_ID_OGRE_KILL_COUNT = "OgreKillCountPlot";
const string PLOT_ID_RETAKE_THE_FORT = "RetakeTheFortPlot";

// Max DB string length.
const int DB_STR_MAX_LENGTH = 32;

////////////////////////
//Function Definitions//
////////////////////////

// Saves the landmark location in the database using the player characters name.
void SaveLandmarkLocation(object oPC, string sLandmark);

// Gets the landmark location in the database using the player characters name.
int GetLandmarkLocation(object oPC, string sLandmark);

// Sets a campaign quest to the value of iProgress in the database.
void SetCampaignQuestProgress(object oPC, string sQuestName, string szPlotID, int iProgress);

// Gets the campaign quest progress from the database.
int GetCampaignQuestProgress(object oPC, string sQuestName);

// Counts the amount of kills oKiller has. When iMaxKills is reached this sets the quests progress to 2.
// sQuestName = Name of the quest. Use the quest constants for this QUEST_*.
// szPlotId = Name of the quest in the journal editor. Use the plot id constants for this PLOT_ID_*.
// iMaxKills = Amount of kills needed to update quest progress to 2.
void SetCampaignKillCount(string sQuestName, string szPlotID, int iMaxKills);

// Add data in the 'newchar' database if the player is new.
void SetNewPCData();

// Get data from the 'newchar' database. Returns false if the player has never been added to the database.
int GetNewPCData();

// Deletes the data from the 'newchar' database associated with oPC.
void DeleteNewPCData(object oPC);

// Resets the journal updates in the on client enter of the module.
void OnClientEnterUpdateJournalEntry(object oPC);

// Deletes the landmark location associated with oPC from the database.
void DeleteLandmarkLocation(object oPC, string sLandmark);

// Deletes all landmark locations associated with oPC from the database.
void DeleteAllLandmarkLocations(object oPC);

// Deletes the quest associated with oPC from the database.
void DeleteCampaignQuest(object oPC, string sQuestName);

// Deletes all quests associated with oPC from the database.
void DeleteAllCampaignQuests(object oPC);

// Deletes the kill count progress for the quest associated with oPC from the database.
void DeleteCampaignKillCount(object oPC, string sQuestName);

// Deletes all the kill count progress quests associated with oPC from the database.
void DeleteAllCampaignKillCount(object oPC);

// Save the campaign location in the campaign database.
void SaveCampaignLocation(object oPC);

// Delete the campaign location.
void DeleteCampaignLocation(object oPC);

// Save the players hit points in the campaign database. If hitpoints are less than 1 store the players death status in the campaign database.
void SaveCampaignHitPoints(object oPC);

// Reset the players hit points with the value stored in the database. If hitpoints are less than 1 kill the player.
void SetCampaignHitPoints(object oPC);

// Delete the players hit points from the database. (put this in the module respawn event.)
void DeleteCampaignHitPoints(object oPC);

// Delete the players dead or alive status from the database. (put this in the module respawn event.)
void DeleteCampaignDeathStatus(object oPC);

// Delete the players data from all campaign databases. (used in at_deletechar)
void DeleteAllCharacterData(object oPC);

/////////////
//Functions//
/////////////

void OnClientEnterUpdateJournalEntry(object oPC)
{
    /////////////////////////////////
    //Handle Quest Journal Updates.//
    /////////////////////////////////

    // Wolf hide.
    RemoveJournalQuestEntry(PLOT_ID_WOLF_HIDE, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_WOLF_HIDE, GetCampaignQuestProgress(oPC, QUEST_WOLF_HIDE), oPC, FALSE);
    // Goblin cheif.
    RemoveJournalQuestEntry(PLOT_ID_DRUGO_GOBLIN_CHEIF, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_DRUGO_GOBLIN_CHEIF, GetCampaignQuestProgress(oPC, QUEST_DRUGO_GOBLIN_CHEIF), oPC, FALSE);
    // Goblin kill count.
    RemoveJournalQuestEntry(PLOT_ID_DRUGO_GOBLIN_KILL_COUNT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_DRUGO_GOBLIN_KILL_COUNT, GetCampaignQuestProgress(oPC, QUEST_DRUGO_GOBLIN_KILL_COUNT), oPC, FALSE);
    // Kamindra part I.
    RemoveJournalQuestEntry(PLOT_ID_KAMINDRA_PART_I, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_KAMINDRA_PART_I, GetCampaignQuestProgress(oPC, QUEST_KAMINDRA_PART_I), oPC, FALSE);
    // Kamindra part II.
    RemoveJournalQuestEntry(PLOT_ID_KAMINDRA_PART_II, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_KAMINDRA_PART_II, GetCampaignQuestProgress(oPC, QUEST_KAMINDRA_PART_II), oPC, FALSE);
    // Undead kill count.
    RemoveJournalQuestEntry(PLOT_ID_UNDEAD_KILL_COUNT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_UNDEAD_KILL_COUNT, GetCampaignQuestProgress(oPC, QUEST_UNDEAD_KILL_COUNT), oPC, FALSE);
    // Troll kill count.
    RemoveJournalQuestEntry(PLOT_ID_TROLL_KILL_COUNT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_TROLL_KILL_COUNT, GetCampaignQuestProgress(oPC, QUEST_TROLL_KILL_COUNT), oPC, FALSE);
    // Cougar kill count.
    RemoveJournalQuestEntry(PLOT_ID_COUGAR_KILL_COUNT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_COUGAR_KILL_COUNT, GetCampaignQuestProgress(oPC, QUEST_COUGAR_KILL_COUNT), oPC, FALSE);
    // Ettin kill count.
    RemoveJournalQuestEntry(PLOT_ID_ETTIN_KILL_COUNT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_ETTIN_KILL_COUNT, GetCampaignQuestProgress(oPC, QUEST_ETTIN_KILL_COUNT), oPC, FALSE);
    // Polar bear kill count.
    RemoveJournalQuestEntry(PLOT_ID_POLAR_BEAR_KILL_COUNT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_POLAR_BEAR_KILL_COUNT, GetCampaignQuestProgress(oPC, QUEST_POLAR_BEAR_KILL_COUNT), oPC, FALSE);
    // Ogre kill count.
    RemoveJournalQuestEntry(PLOT_ID_OGRE_KILL_COUNT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_OGRE_KILL_COUNT, GetCampaignQuestProgress(oPC, QUEST_OGRE_KILL_COUNT), oPC, FALSE);
    // Ogre boss.
    RemoveJournalQuestEntry(PLOT_ID_RETAKE_THE_FORT, oPC, FALSE);
    AddJournalQuestEntry(PLOT_ID_RETAKE_THE_FORT, GetCampaignQuestProgress(oPC, QUEST_RETAKE_THE_FORT), oPC, FALSE);

   // RemoveJournalQuestEntry(PLOT_ID_, oPC, FALSE);
   // AddJournalQuestEntry(PLOT_ID_, GetCampaignQuestProgress(oPC, QUEST_), oPC, FALSE);
}

void DeleteAllCampaignQuests(object oPC)
{
    DeleteCampaignQuest(oPC, QUEST_DRUGO_GOBLIN_CHEIF);
    DeleteCampaignQuest(oPC, QUEST_DRUGO_GOBLIN_KILL_COUNT);
    DeleteCampaignQuest(oPC, QUEST_KAMINDRA_PART_I);
    DeleteCampaignQuest(oPC, QUEST_KAMINDRA_PART_II);
    DeleteCampaignQuest(oPC, QUEST_TROLL_KILL_COUNT);
    DeleteCampaignQuest(oPC, QUEST_UNDEAD_KILL_COUNT);
    DeleteCampaignQuest(oPC, QUEST_WOLF_HIDE);
    DeleteCampaignQuest(oPC, QUEST_COUGAR_KILL_COUNT);
    DeleteCampaignQuest(oPC, QUEST_ETTIN_KILL_COUNT);
    DeleteCampaignQuest(oPC, QUEST_POLAR_BEAR_KILL_COUNT);
    DeleteCampaignQuest(oPC, QUEST_OGRE_KILL_COUNT);
    DeleteCampaignQuest(oPC, QUEST_RETAKE_THE_FORT);
    // DeleteCampaignQuest(oPC, QUEST_);
}

void DeleteAllCampaignKillCount(object oPC)
{
    DeleteCampaignKillCount(oPC, QUEST_WOLF_HIDE);
    DeleteCampaignKillCount(oPC, QUEST_DRUGO_GOBLIN_KILL_COUNT);
    DeleteCampaignKillCount(oPC, QUEST_UNDEAD_KILL_COUNT);
    DeleteCampaignKillCount(oPC, QUEST_TROLL_KILL_COUNT);
    DeleteCampaignKillCount(oPC, QUEST_COUGAR_KILL_COUNT);
    DeleteCampaignKillCount(oPC, QUEST_ETTIN_KILL_COUNT);
    DeleteCampaignKillCount(oPC, QUEST_POLAR_BEAR_KILL_COUNT);
    DeleteCampaignKillCount(oPC, QUEST_OGRE_KILL_COUNT);
    DeleteCampaignKillCount(oPC, QUEST_RETAKE_THE_FORT);
    // DeleteCampaignKillCount(oPC, QUEST_);
}

void DeleteAllLandmarkLocations(object oPC)
{
    DeleteLandmarkLocation(oPC, LANDMARK_001);
    DeleteLandmarkLocation(oPC, LANDMARK_002);
    DeleteLandmarkLocation(oPC, LANDMARK_003);
    DeleteLandmarkLocation(oPC, LANDMARK_004);
    DeleteLandmarkLocation(oPC, LANDMARK_005);
    // DeleteLandmarkLocation(oPC, LANDMARK_);
}

void SaveLandmarkLocation(object oPC, string sLandmark)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sDbString = GetSubString(sCharName, 0, 16) + " : " + GetSubString(sLandmark, 0, 16);
    sDbString = GetSubString(sDbString, 0, 32);

    if(GetIsPC(oPC)) {
        if(GetLandmarkLocation(oPC, sLandmark) == FALSE) {
            FloatingTextStringOnCreature("--LANDMARK LOCATION SAVED--", oPC, FALSE, TRUE);
            SetCampaignInt("Landmarks", sDbString, TRUE);
        }
    }
}

int GetLandmarkLocation(object oPC, string sLandmark)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sDbString = GetSubString(sCharName, 0, 16) + " : " + GetSubString(sLandmark, 0, 16);
    sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);

    return GetCampaignInt("Landmarks", sDbString);
}

void DeleteLandmarkLocation(object oPC, string sLandmark)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sDbString = GetSubString(sCharName, 0, 16) + " : " + GetSubString(sLandmark, 0, 16);
    sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);

    DeleteCampaignVariable("Landmarks", sDbString);
}

void SetCampaignQuestProgress(object oPC, string sQuestName, string szPlotID, int iProgress)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sDbString = GetSubString(sCharName, 0, 16) + " : " + GetSubString(sQuestName, 0, 16);
    sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);

    SetCampaignInt("Quest", sDbString, iProgress);
    AddJournalQuestEntry(szPlotID, iProgress, oPC, FALSE);
}

int GetCampaignQuestProgress(object oPC, string sQuestName)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sDbString = GetSubString(sCharName, 0, 16) + " : " + GetSubString(sQuestName, 0, 16);
    sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);

    return GetCampaignInt("Quest", sDbString);
}

void DeleteCampaignQuest(object oPC, string sQuestName)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sDbString = GetSubString(sCharName, 0, 16) + " : " + GetSubString(sQuestName, 0, 16);
    sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);

    DeleteCampaignVariable("Quest", sDbString);
}

void SetCampaignKillCount(string sQuestName, string szPlotID, int iMaxKills)
{
    object oPC = GetLastKiller();
    object oKiller = oPC;

    if(!GetIsPC(oPC)) {
        oKiller = GetMaster(oPC);
    }

    // If the player has the quest.
    if(GetCampaignQuestProgress(oKiller, sQuestName) == 1)
    {
        // Max of 32 characters for db entry.
        string sCharName = GetName(oKiller);
        string sDbString = "Kills" + " : " + GetSubString(sCharName, 0, 16) + " : " + GetSubString(sQuestName, 0, 16);
        sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);

        int iCurrentAmount = GetCampaignInt("Quest", sDbString);

        object oParty = GetFirstFactionMember(oKiller);
        while(oParty != OBJECT_INVALID)
        {
            if(PartyNotInValidRadius(oParty) || !PartyInValidLevelRange(oKiller, oParty)) {
                oParty = GetNextFactionMember(oKiller);
                continue;
            }
            SetCampaignInt("Quest", sDbString, iCurrentAmount+=1);
            FloatingTextStringOnCreature("You've killed " + IntToString(iCurrentAmount) + " out of " + IntToString(iMaxKills) + " " + GetName(OBJECT_SELF)+ "'s.", oParty, FALSE);
            if(GetCampaignInt("Quest", sDbString) == iMaxKills)
            {
                SetCampaignQuestProgress(oParty, sQuestName, szPlotID, 2);
                DeleteCampaignVariable("Quest", sDbString);
                FloatingTextStringOnCreature("You've completed the quest. Go collect your reward.", oParty, FALSE);
            }
            oParty = GetNextFactionMember(oKiller);
        }
    }
}

void SetNewPCData()
{
    object oPC = GetEnteringObject();
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sCharName = GetName(oPC);
    string sVarname = sPublicCdKey + ":" + sCharName;
    if(GetNewPCData() == FALSE) {
            SetCampaignInt("newchar", sVarname, TRUE);
        }
}

int GetNewPCData()
{
    object oPC = GetEnteringObject();
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sCharName = GetName(oPC);
    string sVarname = sPublicCdKey + ":" + sCharName;
    return GetCampaignInt("newchar", sVarname);
}

void DeleteNewPCData(object oPC)
{
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sCharName = GetName(oPC);
    string sVarname = sPublicCdKey + ":" + sCharName;
    DeleteCampaignVariable("newchar", sVarname);
}

void DeleteCampaignKillCount(object oPC, string sQuestName)
{
        // Max of 32 characters for db entry.
        string sCharName = GetName(oPC);
        string sDbString = "Kills" + " : " + GetSubString(sCharName, 0, 16) + " : " + GetSubString(sQuestName, 0, 16);
        sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);

        DeleteCampaignVariable("quest", sDbString);
}

void SaveCampaignLocation(object oPC)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sDbString = GetSubString(sPublicCdKey, 0, 16) + ":" + GetSubString(sCharName, 0, 16);
           sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);
    object oCharDeleter = GetObjectByTag("HeadMonk");
    if(GetLocalInt(oCharDeleter, GetName(oPC) + "DELETED") == FALSE) {
        if(GetArea(oPC) != GetObjectByTag("HallofKnowledge")) {
            SetCampaignLocation("CAMPAIGN_LOCATION", sDbString, GetLocation(oPC));
        }
    }
}

void DeleteCampaignLocation(object oPC)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sDbString = GetSubString(sPublicCdKey, 0, 16) + ":" + GetSubString(sCharName, 0, 16);
           sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);
    DeleteCampaignVariable("CAMPAIGN_LOCATION", sDbString);
}

void SaveCampaignHitPoints(object oPC)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sDbString = GetSubString(sPublicCdKey, 0, 16) + ":" + GetSubString(sCharName, 0, 16);
           sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);
    int iCurrentHitPoints = GetCurrentHitPoints(oPC);
    object oCharDeleter = GetObjectByTag("HeadMonk");
    if(GetLocalInt(oCharDeleter, GetName(oPC) + "DELETED") == FALSE) {
        if(iCurrentHitPoints > 0) {
            SetCampaignInt("HIT_POINTS", sDbString, iCurrentHitPoints);
        } else {
            SetCampaignInt("PLAYER_DEAD", sDbString, TRUE);
        }
    }
}

void SetCampaignHitPoints(object oPC)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sDbString = GetSubString(sPublicCdKey, 0, 16) + ":" + GetSubString(sCharName, 0, 16);
           sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);
    int iSavedHitPoints = GetCampaignInt("HIT_POINTS", sDbString);
    int iPlayerDead = GetCampaignInt("PLAYER_DEAD", sDbString);

    if(iSavedHitPoints > 0) {
        int iCampaignHitPoints = GetMaxHitPoints(oPC) - (GetMaxHitPoints(oPC) - iSavedHitPoints);
        SetCurrentHitPoints(oPC, iCampaignHitPoints);
        DeleteCampaignHitPoints(oPC);
    }

    if(iPlayerDead == TRUE) {
        effect eDeath = EffectDeath();
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oPC);
    }
}

void DeleteCampaignHitPoints(object oPC)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sDbString = GetSubString(sPublicCdKey, 0, 16) + ":" + GetSubString(sCharName, 0, 16);
           sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);
    DeleteCampaignVariable("HIT_POINTS", sDbString);
}

void DeleteCampaignDeathStatus(object oPC)
{
    // Max of 32 characters for db entry.
    string sCharName = GetName(oPC);
    string sPublicCdKey = GetPCPublicCDKey(oPC, TRUE);
    string sDbString = GetSubString(sPublicCdKey, 0, 16) + ":" + GetSubString(sCharName, 0, 16);
           sDbString = GetSubString(sDbString, 0, DB_STR_MAX_LENGTH);
    DeleteCampaignVariable("PLAYER_DEAD", sDbString);
}

void DeleteAllCharacterData(object oPC)
{
    DeleteAllLandmarkLocations(oPC);
    DeleteAllCampaignQuests(oPC);
    DeleteAllCampaignKillCount(oPC);
    DeleteNewPCData(oPC);
    DeleteCampaignLocation(oPC);
}
