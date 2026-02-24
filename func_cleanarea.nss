// How many seconds it takes before cleaning the area. (Every 15 minutes)
const float fTimer = 900.0;

// Return TRUE if a player is in the area.
int PCInArea();

// Cleans the area by destroying and re-creating it. Put this in the OnHeartbeat Event.
void HB_AREA_CLEAN();

/////////////
//FUNCTIONS//
/////////////

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

void HB_AREA_CLEAN()
{
    // If a player isn't in the area delete and re-create the area.
    if(PCInArea() == FALSE)
    {
        // If TIMES_UP is TRUE then continue.
        if(GetLocalInt(OBJECT_SELF, "TIMES_UP") == TRUE)
        {
            // Set a variable to store data for CreateArea();
            object oCreate = CreateArea(GetResRef(OBJECT_SELF), GetTag(OBJECT_SELF), GetName(OBJECT_SELF));

            // Destroy the area.
            DestroyArea(OBJECT_SELF);

            // Re-create the area with the stored data.
            oCreate;

            // Set TIMES_UP to FALSE so this doesn't run again.
            SetLocalInt(OBJECT_SELF, "TIMES_UP", FALSE);

            // Set CHECK_ONCE to FALSE to reset fTimer.
            SetLocalInt(OBJECT_SELF, "CHECK_ONCE", FALSE);

            // Debug Message.
            //SpeakString("Area " + GetName(OBJECT_SELF) + " Cleaned!", TALKVOLUME_SHOUT);
        }
    }

    // If CHECK_ONCE is FALSE then continue.
    if(GetLocalInt(OBJECT_SELF, "CHECK_ONCE") == FALSE)
    {
        // Set TIMES_UP to TRUE after a delay to clean the area again in fTimer seconds.
        DelayCommand(fTimer, SetLocalInt(OBJECT_SELF, "TIMES_UP", TRUE));

        // Set CHECK_ONCE to TRUE so you don't run this block again on the next heartbeat.
        SetLocalInt(OBJECT_SELF, "CHECK_ONCE", TRUE);
    }
}

