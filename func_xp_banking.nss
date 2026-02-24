///////////////////////////////////////
/// Created By: Christopher Williams //
/// Date: 7/19/2025 ///////////////////
/// Email: cw174531@gmail.com//////////
///////////////////////////////////////

#include "func_chat_input"

string FormatXp(string sXp)
{
    // Get the string length of the total xp.
    int iDigitAmount = GetStringLength(sXp);

    // Initialize the formatted string with the xp string.
    string sFormattedXp = sXp;

    // Initialize an integer with the total length of the xp string.
    int i = iDigitAmount;

    // While the total length of the string is greater than 0.
    while(i > 0)
    {
        // Decrement the total length by 3 for every place where you need a comma.
        i-=3;

        // If i is greater than 0, because you don't need a comma before the first digit.
        if(i > 0) {
        // For every iteration insert a comma 3 decimal places to the left and set the formatted string to equal the string with the newly inserted comma.
            sFormattedXp = InsertString(sFormattedXp, ",", i);
            /*
                Before Loop: sFormattedXp = 1000000
                1st Iteration: sForattedXp = 1000,000
                2nd Iteration: sFormattedXp = 1,000,000
            */
        }
    }
    return sFormattedXp;
}

void PrintXpToDeposit()
{
    // Get the player speaker in the conversation.
    object oPC = GetPCSpeaker();

    // Get the xp for the max level.
    int iMaxLevelXp = 780000;

    // Get the players total xp.
    int iPlayerXp = GetXP(oPC);

    // Get the maximum possible deposit.
    int iMaxDeposit = iPlayerXp - iMaxLevelXp;

    if(iMaxDeposit <= 0) iMaxDeposit = 0;

    // Send a message to the player letting him know how much he can deposit.
    SendMessageToPC(oPC, "Amount available to deposit: " + FormatXp(IntToString(iMaxDeposit)));
}

void PrintXpToWithdraw()
{
    // Get the player speaker in the conversation.
    object oPC = GetPCSpeaker();

    // Get the players public cd key.
    string sPlayerCdKey = GetPCPublicCDKey(oPC, TRUE);

    // Get the players stored xp from the database. (serialized to cd key)
    int iWithdrawAmount = GetCampaignInt("xp_bank", sPlayerCdKey);

    // Send a message to the player letting him know how much he can deposit.
    SendMessageToPC(oPC, "Amount available to withdraw: " + FormatXp(IntToString(iWithdrawAmount)));
}

int IsDigit(string sDigits)
{
    int i = 0;
    string sString = sDigits;
    while(i < GetStringLength(sString))
    {
        // If any charachter in the integer string equals 0, and any charachter in string does not eqaul "0".
        /*
            This might be a bit confusing. StringToInt returns 0 if the charachter is not a digit.
            Therefore if the charachter wrapped inside StringToInt is 0 it's not a digit. But a 0
            is actually a digit so you need to exclude the charachter "0" in the condition check
            GetSubString(sString, i, 1) != "0".
        */
        if(StringToInt(GetSubString(sString, i, 1)) == 0 && GetSubString(sString, i, 1) != "0")
        {
            return FALSE;
        }
        i+=1;
    }
    return TRUE;
}

void DepositXp()
{
    // Get the player speaker in the conversation.
    object oPC = GetPCSpeaker();

    // Check to see if the player speaker is the max level (780,000 xp).
    if(GetHitDice(oPC) == 40)
    {
        // Get the xp required for the maximum level.
        int iMaxLevelXp = 780000;

        // Get the players total xp.
        int iPlayerXp = GetXP(oPC);

        // Get the players maximum possible deposit. (all xp above 780,000)
        int iMaxDeposit = iPlayerXp - iMaxLevelXp;

        // If the maximum the player can deposit is above 0.
        if(iMaxDeposit > 0)
        {
            // Get the player speakers string chat input.
            string sDepositAmount = GetLocalInputString(oPC, "xp");

            // If the player speakers input isn't digits only end the program here.
            if(IsDigit(sDepositAmount) == FALSE)
            {
                // This debug message shows that 10aA is registering as 10 when checking valid digits. Internal engine bug. Need to use GetLocalInputString to check validity because of this.
                //int iDepositAmount = GetLocalInputInt(oPC, "xp");
                //SpeakString(IntToString(iDepositAmount));

                // Send a message to the player telling him to enter a valid number of xp to deposit.
                SendMessageToPC(oPC, "Please enter a valid number of experience points to deposit.");

                // Clean up the local input variables from the players chat.
                DeleteLocalInputInt(oPC, "xp");
                DeleteLocalInputString(oPC, "xp");

                // End the program.
                return;
            }

            // Get the player speakers integer chat input.
            int iDepositAmount = GetLocalInputInt(oPC, "xp");

            // If the players deposit amount equals 0.
            if(iDepositAmount == 0)
            {
                // Send a message to the player telling him to enter a valid number of xp to deposit.
                SendMessageToPC(oPC, "Please enter a valid number of experience points to deposit.");

                // Clean up the local input variables from the players chat.
                DeleteLocalInputInt(oPC, "xp");
                DeleteLocalInputString(oPC, "xp");

                // End the program.
                return;
            }

            // If the deposit amount is less than or equal to the maximum deposit amount.
            if(iDepositAmount <= iMaxDeposit)
            {
                // Get the players new xp after the deposit is made.
                int iNewXp = iPlayerXp - iDepositAmount;

                // Set the players xp to the new xp value.
                SetXP(oPC, iNewXp);

                // Get the players public cd key.
                string sPlayerCdKey = GetPCPublicCDKey(oPC, TRUE);

                // Get the currently stored amount of xp that the player has in the database. (serialized to cd key)
                int iCurrentlyBankedXp = GetCampaignInt("xp_bank", sPlayerCdKey);

                // Get the database's new xp after the deposit is made.
                int iNewBankedXpAmount = iCurrentlyBankedXp + iDepositAmount;

                // Set the database's xp to the new xp value.
                SetCampaignInt("xp_bank", sPlayerCdKey, iNewBankedXpAmount);

                // Clean up the local input variables from the players chat.
                DeleteLocalInputInt(oPC, "xp");
                DeleteLocalInputString(oPC, "xp");

                // Send a message to the player letting him know how much xp he has banked.
                SendMessageToPC(oPC, "You have " + FormatXp(IntToString(iNewBankedXpAmount)) + " in the bank.");

                // End the program.
                return;
            }
            else // If the players deposit amount is not less than or equal to the maximum possible deposit amount.
            {
                // Send a message to the player letting him know how much xp he has to deposit.
                PrintXpToDeposit();

                // Clean up the local input variables from the players chat.
                DeleteLocalInputInt(oPC, "xp");
                DeleteLocalInputString(oPC, "xp");

                // End the program.
                return;
            }
        }
        else // If the maximum deposit amount is not above 0
        {
            // Send a message to the player letting him know the conditions of storing xp.
            SendMessageToPC(oPC, "You must be level 40 and have over 780,000 experience points to deposit experience.");

            // Clean up the local input variables from the players chat.
            DeleteLocalInputInt(oPC, "xp");
            DeleteLocalInputString(oPC, "xp");

            // End the program.
            return;
        }

   }
   else // The player is not level 40. (Even if the player has 780,000 xp but hasn't leveled to 40 yet)
   {
        // Send a message to the player letting him know the conditions of storing xp.
        SendMessageToPC(oPC, "You must be level 40 and have over 780,000 experience points to deposit experience.");

        // Clean up the local input variables from the players chat.
        DeleteLocalInputInt(oPC, "xp");
        DeleteLocalInputString(oPC, "xp");

        // End the program.
        return;
   }
}

void WithdrawXp()
{
    // Get the player speaker in the conversation.
    object oPC = GetPCSpeaker();

    // Get the players public CD key.
    string sPlayerCdKey = GetPCPublicCDKey(oPC, TRUE);

    // Get the amount of xp stored in the database. (serialized to public cd key)
    int iGetStoredXp = GetCampaignInt("xp_bank", sPlayerCdKey);

    // Get the players input string to check if they're valid digits or not.
    string sWithdrawAmount = GetLocalInputString(oPC, "xp");

    // If the players input isn't digits only.
    if(IsDigit(sWithdrawAmount) == FALSE)
    {
        // Send a message to the player telling him to enter a valid number of xp to withdraw.
        SendMessageToPC(oPC, "Please enter a valid number of experience points to withdraw.");

        // Clean up the local input variables from the players chat.
        DeleteLocalInputInt(oPC, "xp");
        DeleteLocalInputString(oPC, "xp");

        // End the program.
        return;
    }

    // Get the amount to withdraw from the players chat input.
    int iWithdrawAmount = GetLocalInputInt(oPC, "xp");

    // If the withdraw amount equals 0.
    if(iWithdrawAmount == 0)
    {
        // Send a message to the player telling him to enter a valid number of xp to withdraw.
        SendMessageToPC(oPC, "Please enter a valid number of experience points to withdraw.");

        // Clean up the local input variables from the players chat.
        DeleteLocalInputInt(oPC, "xp");
        DeleteLocalInputString(oPC, "xp");

        // End the program.
        return;
    }

    // If the withdraw amount is less than or equal to the amount stored.
    if(iWithdrawAmount <= iGetStoredXp)
    {
        // Get the players total xp.
        int iPlayerXp = GetXP(oPC);

        // Get the players new xp after the withdraw is made.
        int iNewXp = iPlayerXp + iWithdrawAmount;

        // Set the players xp to the new xp value.
        SetXP(oPC, iNewXp);

        // Get the new amount of xp in the database.
        int iNewBankedXPAmount = iGetStoredXp - iWithdrawAmount;

        // Set the xp in the database to the new value.
        SetCampaignInt("xp_bank", sPlayerCdKey, iNewBankedXPAmount);
    }
    else // If the withdraw amount is not less than or equal to the amount stored.
    {
        // Send a message to the player letting him know how much xp he has to withdraw.
        PrintXpToWithdraw();

        // Clean up the local input variables from the players chat.
        DeleteLocalInputInt(oPC, "xp");
        DeleteLocalInputString(oPC, "xp");

        // End the program.
        return;
    }
}
