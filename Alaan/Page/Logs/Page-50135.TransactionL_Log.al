page 50135 "Transaction Line - Alaan Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Alaan Logs - Transaction Line';
    SourceTable = "Transaction Line - Alaan Logs";
    InsertAllowed = false;
    Editable = false;
    ModifyAllowed = true;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(EntryNo; Rec.EntryNo)
                {

                }
                field("Sync Date & Time"; Rec."Sync Date & Time")
                {

                }
                field(SyncType; Rec.SyncType)
                {

                }
                field(ActionType; Rec.ActionType)
                {

                }
                field("Account Details GL Account"; Rec."Account Details GL Account")
                {

                }
                field("Account Details Name"; Rec."Account Details Name")
                {

                }
                field(Amount; Rec.Amount)
                {

                }
                field("Spender Comments"; Rec."Spender Comments")
                {
                    Caption = 'Memo Comment';
                }
                field("Error Message"; Rec."Error Message")
                {

                }

            }
        }
    }
}