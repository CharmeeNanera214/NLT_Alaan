page 50122 "Tax Codes - Alaan Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Tax Code - Alaan Logs";
    SourceTableView = sorting(EntryNo) order(descending);
    Caption = 'Alaan Logs - Tax Code';
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
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the unique entry number.';
                }
                field("Sync Date & Time"; Rec."Sync Date & Time")
                {
                    ApplicationArea = All;
                    Caption = 'Sync Date & Time';
                    ToolTip = 'Specifies the date and time of synchronization.';
                }
                field(SyncType; Rec.SyncType)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Type';
                    ToolTip = 'Specifies the synchronization type (To Alaan or From Alaan).';
                }
                field(ActionType; Rec.ActionType)
                {
                    ApplicationArea = All;
                    Caption = 'Action Type';
                    ToolTip = 'Specifies whether the action is Create or Update.';
                }
                field(BC_Tax_Code; Rec.BC_Tax_Code)
                {
                    ApplicationArea = All;
                    Caption = 'BC Tax Code';
                    ToolTip = 'Specifies the Business Central tax code.';
                }
                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                    Caption = 'Rate';
                    ToolTip = 'Specifies the tax rate percentage.';
                    DecimalPlaces = 2 : 2;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the tax code.';
                }

                field(TaxCodeID; Rec.TaxCodeID)
                {
                    ApplicationArea = All;
                    Caption = 'Tax Code ID';
                    ToolTip = 'Specifies the GUID identifier for the tax code.';
                }
                field(IsDeleted; Rec.IsDeleted)
                {
                    ApplicationArea = All;
                    Caption = 'Is Deleted';
                    ToolTip = 'Specifies whether the tax code has been deleted.';
                }
                field(IsError; Rec.IsError)
                {
                    ApplicationArea = All;
                    Caption = 'Is Error';
                    ToolTip = 'Specifies whether an error occurred during synchronization.';
                }
                field("Error Type"; Rec."Error Type")
                {
                    ApplicationArea = All;
                    Caption = 'Error Type';
                    ToolTip = 'Specifies the type of error, if any.';
                    Style = Unfavorable;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    ToolTip = 'Specifies the error message if synchronization failed.';
                    Style = Unfavorable;
                }


            }
        }
    }
}