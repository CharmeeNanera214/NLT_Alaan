page 50130 "Exp. Tracking Tag - Alaan Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Exp. Tracking Tags - Alaan log";
    SourceTableView = sorting(EntryNo) order(descending);
    Caption = 'Alaan Logs - Expense Tracking Tags';
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
                    ToolTip = 'Specifies the unique entry number for the record.';
                }
                field("Sync Date & Time"; Rec."Sync Date & Time")
                {
                    ApplicationArea = All;
                    Caption = 'Sync Date & Time';
                    ToolTip = 'Specifies the date and time when the record was last synchronized.';
                }
                field(SyncType; Rec.SyncType)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Type';
                    ToolTip = 'Specifies whether the synchronization is to Alaan or from Alaan.';
                }
                field(ActionType; Rec.ActionType)
                {
                    ApplicationArea = All;
                    Caption = 'Action Type';
                    ToolTip = 'Specifies the type of action, such as Create or Update, for this record.';
                }
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = All;
                    Caption = 'Tag Code';
                    ToolTip = 'Specifies the Business Central Expense tracking tag code.';
                }
                field(TagName; Rec.TagName)
                {
                    ApplicationArea = All;
                    Caption = 'Tag Name';
                    ToolTip = 'Specifies the Business Central Expense tracking tag Name.';
                }

                field(ExpTracTagID; Rec.ExpTracTagID)
                {
                    ApplicationArea = All;
                    Caption = 'Expense Tracking Tag Id';
                    ToolTip = 'Specifies the unique identifier of the expense Tracking tag.';
                }
                field(IsActive; Rec.IsActive)
                {
                    ApplicationArea = All;
                    Caption = 'Is Active';
                    ToolTip = 'Specifies whether the expense category is active.';
                }
                field(IsError; Rec.IsError)
                {
                    ApplicationArea = All;
                    Caption = 'Is Error';
                    ToolTip = 'Indicates whether the record contains an error.';
                }
                field("Error Type"; Rec."Error Type")
                {
                    ApplicationArea = All;
                    Caption = 'Error Type';
                    ToolTip = 'Specifies the type of error encountered for this record.';
                    Style = Unfavorable;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    Style = Unfavorable;
                    ToolTip = 'Specifies the error message associated with this record.';
                }
            }
        }
    }
}