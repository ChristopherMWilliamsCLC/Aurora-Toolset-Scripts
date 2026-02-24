///////////////////////////////////////
/// Created By: Christopher Williams //
/// Date: 7/19/2025 ///////////////////
/// Email: cw174531@gmail.com//////////
///////////////////////////////////////

// Deposits gold inside a database.
void DepositGold(object oPC, int iDepositAmount);

// Withdraws gold from a database.
void WithdrawGold(object oPC, int iWithdrawAmount);

// Prints the gold balance from the database.
void PrintBalance(object oPC);

// Formats a string with comma's every 3 decimal places.
string FormatGold(string sBalance);

void DepositGold(object oPC, int iDepositAmount)
{
    // Get the cd key of the player.
    string sPlayerCdKey = GetPCPublicCDKey(oPC, TRUE);

    // Get the amount of gold that the player is holding.
    int iPlayerGold = GetGold(oPC);

    // Get the amount of gold stored in the database.
    int iStoredAmount = GetCampaignInt("bank", sPlayerCdKey);

    // Maximum amount of gold that NWN allows a player to hold.
    int iMaxCapacity = 999999999;

    // If the players deposit amount goes beyond the max capacity don't allow the deposit.
    if(iDepositAmount + iStoredAmount > iMaxCapacity)
    {
        SpeakString("Sorry, we actually don't have enough room in our vaults for that much gold.");
        SendMessageToPC(oPC, "In Neverwinter Nights you can't hold more than 999,999,999 gold. For protection this bank can only hold up to 999,999,999.");
        return;
    }

    // If the players held gold equals the amount to deposit.
    if(iPlayerGold >= iDepositAmount) {
        // Get the new amount amount of gold to store in the database.
        int iNewStoredAmount = iStoredAmount + iDepositAmount;

        // Update the database with the new amount.
        SetCampaignInt("bank", sPlayerCdKey, iNewStoredAmount);

        // Take the deposited gold from the player.
        TakeGoldFromCreature(iDepositAmount, oPC, TRUE);

        // Tell the player how much he has stored.
        SendMessageToPC(oPC, "You have " + FormatGold(IntToString(GetCampaignInt("bank", sPlayerCdKey))) + " in the bank.");
    }
}

void WithdrawGold(object oPC, int iWithdrawAmount)
{
    // Get the cd key of the player.
    string sPlayerCdKey = GetPCPublicCDKey(oPC, TRUE);

    // Get the amount of gold that the player is holding.
    int iPlayerGold = GetGold(oPC);

    // Get the amount of gold stored in the database.
    int iStoredAmount = GetCampaignInt("bank", sPlayerCdKey);

    // Maximum amount of gold that NWN allows a player to hold.
    int iMaxCapacity = 999999999;

    // If the players withdraw amount goes beyond the max capacity don't allow the withdraw.
    if(iWithdrawAmount + iPlayerGold > iMaxCapacity)
    {
        SpeakString("You're the richest man i've ever seen. We're holding on to this money for your own good.");
        SendMessageToPC(oPC, "In Neverwinter Nights you can't hold more than 999,999,999 gold. If you withdrew any gold past this cap you would lose the gold.");
        return;
    }

    // If the amount to withdraw is less than or equal too the gold in the database.
    if(iWithdrawAmount <= iStoredAmount) {

        // Give the player the gold.
        GiveGoldToCreature(oPC, iWithdrawAmount);

        // If the gold from the database isn't 0 then update the gold amount in the database.
        if(iStoredAmount != 0) {
            // Get the absolute value so that it can't be a negative number.
            int iNewAmount = abs(iWithdrawAmount - iStoredAmount);

            // Store the new amount value in the database.
            SetCampaignInt("bank", sPlayerCdKey, iNewAmount);

            // Tell the player how much left he has stored.
            SendMessageToPC(oPC, "You have " + FormatGold(IntToString(GetCampaignInt("bank", sPlayerCdKey))) + " left in the bank.");
        }

        // If the gold from the database is 0 then delete it from the database.
        if(GetCampaignInt("bank", sPlayerCdKey) == 0){
            // Delete data.
            DeleteCampaignVariable("bank", sPlayerCdKey);
        }
    }
    else
    {   // If the player doesn't have the money he's trying to withdraw.
        SpeakString("Sorry! You only have " + FormatGold(IntToString(iStoredAmount)) + " stored.");
    }

}

void PrintBalance(object oPC)
{
    // Get the cd key of the player.
    string sPlayerCdKey = GetPCPublicCDKey(oPC, TRUE);

    // Get the amount of gold stored in the database.
    int iStoredAmount = GetCampaignInt("bank", sPlayerCdKey);

    // Get the balance from the database in the form of a string.
    string sBalance = IntToString(GetCampaignInt("bank", sPlayerCdKey));

    // Format the balance string with comma's
    string sFormattedBalance = FormatGold(sBalance);

    // If the stored amount from the database is 0 the formatted balance string is '0'.
    if(iStoredAmount == 0) sFormattedBalance = "0";

    // Tell the player how much he has stored.
    SendMessageToPC(oPC, "You have " + sFormattedBalance + " in the bank.");
}

string FormatGold(string sBalance)
{
    // Get the string length of the total balance.
    int iDigitAmount = GetStringLength(sBalance);

    // Initialize the formatted string with the balance string.
    string sFormattedBalance = sBalance;

    // Initialize an integer with the total length of the balance string.
    int i = iDigitAmount;

    // While the total length of the string is greater than 0.
    while(i > 0)
    {
        // Decrement the total length by 3 for every place where you need a comma.
        i-=3;

        // If i is greater than 0, because you don't need a comma before the first digit.
        if(i > 0) {
        // For every iteration insert a comma 3 decimal places to the left and set the formatted string to equal the string with the newly inserted comma.
            sFormattedBalance = InsertString(sFormattedBalance, ",", i);
            /*
                Before Loop: sFormattedBalance = 1000000
                1st Iteration: sForattedBalance = 1000,000
                2nd Iteration: sFormattedBalance = 1,000,000
            */
        }
    }
    return sFormattedBalance;
}
