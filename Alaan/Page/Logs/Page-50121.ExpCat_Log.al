page 50121 "Expense Cat - Alaan Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Expense Cat - Alaan Logs";
    SourceTableView = sorting(EntryNo) order(descending);
    Caption = 'Alaan Logs - Expense Category';
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
                field(BC_GLAcc_NO; Rec.BC_GLAcc_NO)
                {
                    ApplicationArea = All;
                    Caption = 'BC GL Account No';
                    ToolTip = 'Specifies the Business Central general ledger account number associated with the expense category.';
                }

                field("Expense Category Id"; Rec."Expense Category Id")
                {
                    ApplicationArea = All;
                    Caption = 'Expense Category Id';
                    ToolTip = 'Specifies the unique identifier of the expense category.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the expense category.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    Caption = 'Active';
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