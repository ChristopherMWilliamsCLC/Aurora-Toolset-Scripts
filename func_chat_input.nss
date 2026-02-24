///////////////////////////////////////
/// Created By: Christopher Williams //
/// Date: 7/19/2025 ///////////////////
/// Email: cw174531@gmail.com//////////
///////////////////////////////////////

//////////////////////////
///FUNCTION DEFINITIONS///
//////////////////////////

// Check if the player is in a conversation in the area 'sAreaTag' then set the players chat input into the local int sVarName. (use this in the modules OnPlayerChat)
void SetLocalInputInt(string sAreaTag, string sVarName);

// Gets oObjects chat input int from sVarName. (functionally the same as GetLocalInt() but I wanted to stick to naming conventions.)
int GetLocalInputInt(object oObject, string sVarName);

// Deletes the data from sVarName. (functionally the same as DeleteLocalInt() but I wanted to stick to naming conventions.)
void DeleteLocalInputInt(object oObject, string sVarName);

// Check if the player is in a conversation in the area 'sAreaTag' then set the players chat input into the local string sVarName. (use this in the modules OnPlayerChat)
void SetLocalInputString(string sAreaTag, string sVarName);

// Gets oObjects chat input string from sVarname. (functionally the same as GetLocalString() but I wanted to stick to naming conventions.)
string GetLocalInputString(object oObject, string sVarName);

// Deletes the data from sVarName. (functionally the same as DeleteLocalString() but I wanted to stick to naming conventions.)
void DeleteLocalInputString(object oObject, string sVarname);

// Use this to test visual effects by typing the effects constant int value and pressing enter.
void ApplyEffectOnChatInput(int iDurationType, float fDuration=0.0f);

///////////////
///FUNCTIONS///
///////////////

int IsPlayerSpeakerInArea(string sAreaTag)
{
    // Check if the player speaker is in the area tagged "sAreaTag", true if yes and false if not.
    if(GetArea(GetPCChatSpeaker()) == GetArea(GetObjectByTag(sAreaTag)))
    {
        return TRUE;
    } else {
        return FALSE;
    }
}

void SetLocalInputIntHelper(object oObject, string sVarName)
{
    // Get the input from the players chat message.
    int inputAmount = StringToInt(GetPCChatMessage());

    // Store the input in a local int.
    SetLocalInt(oObject, sVarName, inputAmount);
}

void SetLocalInputInt(string sAreaTag, string sVarName)
{
    // Check if the speaker is in the area tagged sAreaTag.
    if(IsPlayerSpeakerInArea(sAreaTag)) {
        // Get the PC that sent the last player chat(text) message.
        object oPC = GetPCChatSpeaker();

        // Check if the player is in a conversation.
        if(IsInConversation(oPC)) {
            // If the player is in a conversation & in the area sAreaTag, record the players chat input in a local variable.
            SetLocalInputIntHelper(GetPCChatSpeaker(), sVarName);
        }
    }
}

int GetLocalInputInt(object oObject, string sVarName)
{
    // Return the local int.
    return GetLocalInt(oObject, sVarName);
}

void DeleteLocalInputInt(object oObject, string sVarName)
{
    // Delete the local int.
    DeleteLocalInt(oObject, sVarName);
}

void SetLocalInputStringHelper(object oObject, string sVarName)
{
    // Get the input from the players chat message.
    string inputAmount = GetPCChatMessage();

    // Store the input in a local string.
    SetLocalString(oObject, sVarName, inputAmount);
}

void SetLocalInputString(string sAreaTag, string sVarName)
{
    // Check if the speaker is in the area tagged sAreaTag.
    if(IsPlayerSpeakerInArea(sAreaTag)) {
        // Get the PC that sent the last player chat(text) message.
        object oPC = GetPCChatSpeaker();

        // Check if the player is in a conversation.
        if(IsInConversation(oPC)) {
            // If the player is in a conversation & in the area sAreaTag, record the players chat input in a local variable.
            SetLocalInputStringHelper(GetPCChatSpeaker(), sVarName);
        }
    }
}

string GetLocalInputString(object oObject, string sVarName)
{
    // Return the local string.
    return GetLocalString(oObject, sVarName);
}

void DeleteLocalInputString(object oObject, string sVarname)
{
    // Delete the local string.
    DeleteLocalString(oObject, sVarname);
}

void ApplyEffectOnChatInput(int iDurationType, float fDuration=0.0f)
{
    string sInput = GetPCChatMessage();
    effect eVFX = EffectVisualEffect(StringToInt(sInput));
    ApplyEffectToObject(iDurationType, eVFX, GetPCChatSpeaker(), fDuration);
}

