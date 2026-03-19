page 50124 "NLT Employee - Alaan Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NLT Employee - Alaan Logs";
    SourceTableView = sorting(EntryNo) order(descending);
    Caption = 'Alaan Logs - Alaan User';
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
                field(NLT_Emp_Code; Rec.NLT_Emp_Code)
                {
                    ApplicationArea = All;
                    Caption = 'BC Alaan User Code';
                    ToolTip = 'Specifies the Business Central Alaan User Code.';
                }
                field(BC_Emp_Dim_Code; Rec.BC_Emp_Dim_Code)
                {
                    ApplicationArea = All;
                    Caption = 'BC Employee  Dimension Code';
                    ToolTip = 'Specifies the Business Central Employee Dimession Code.';
                }

                field(NLTEmployeeId; Rec.NLTEmployeeId)
                {
                    ApplicationArea = All;
                    Caption = 'Alaan User Id';
                    ToolTip = 'Specifies the unique identifier of the Alaan User.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the expense category.';
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