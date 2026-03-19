page 50134 "Transaction - Alaan Logs"
{
    PageType = List;
    ApplicationArea = All;
    Caption = 'Alaan Logs - Transaction';
    UsageCategory = Lists;
    SourceTable = "Transaction - Alaan Logs";
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
                field("Merchant Name"; Rec."Merchant Name")
                {

                }
                field("Billing Currency"; Rec."Billing Currency")
                {

                }

                field("Vendor Name"; Rec."Vendor Name")
                {

                }
                field("Billing Amount"; Rec."Billing Amount")
                {

                }
                field("VAT Amount"; Rec."VAT Amount")
                {

                }
                field(IsError; Rec.IsError)
                {

                }
                field("Error Message"; Rec."Error Message")
                {

                }
            }
        }
    }
}