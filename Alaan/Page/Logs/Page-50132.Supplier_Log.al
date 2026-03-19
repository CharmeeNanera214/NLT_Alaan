page 50132 "Supplier - Alaan Logs"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Supplier - Alaan Logs";
    SourceTableView = sorting(No) order(descending);
    Caption = 'Alaan Logs - Supplier';
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
                field(No; Rec.No)
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the unique number for this record.';
                }
                field("Sync Date & Time"; Rec."Sync Date & Time")
                {
                    ApplicationArea = All;
                    Caption = 'Sync Date and Time';
                    ToolTip = 'Specifies the sync date and time for this record.';
                }
                field(SyncType; Rec.SyncType)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Type';
                    ToolTip = 'Specifies the type of synchronization performed for this record.';
                }
                field(ActionType; Rec.ActionType)
                {
                    ApplicationArea = All;
                    Caption = 'Action Type';
                    ToolTip = 'Specifies the action type (e.g., Create, Update) for this record.';
                }
                field(id; Rec.SupplierId)
                {
                    ApplicationArea = All;
                    Caption = 'Supplier ID';
                    ToolTip = 'Specifies the unique identifier of the supplier.';
                }
                field(partnerSupplierName; Rec.partnerSupplierName)
                {
                    ApplicationArea = All;
                    Caption = 'Supplier Name';
                    ToolTip = 'Specifies the name of the partner supplier.';
                }
                field(status; Rec.status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies the current status of the record.';
                }
                field(creationType; Rec.creationType)
                {
                    ApplicationArea = All;
                    Caption = 'Creation Type';
                    ToolTip = 'Specifies how the record was created.';
                }
                field(BC_Vendor_NO; Rec.BC_Vendor_NO)
                {
                    ApplicationArea = All;
                    Caption = 'BC Vendor No.';
                    ToolTip = 'Specifies the vendor number in Business Central linked to this record.';
                }
                field(IsError; Rec.IsError)
                {
                    ApplicationArea = All;
                    Caption = 'Is Error';
                    ToolTip = 'Indicates whether this record contains an error.';
                }
                field("Error Type"; Rec."Error Type")
                {
                    ApplicationArea = All;
                    Caption = 'Error Type';
                    ToolTip = 'Specifies the type of error found in this record.';
                    Style = Unfavorable;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    ToolTip = 'Provides details about the error found in this record.';
                    Style = Unfavorable;
                }

            }
        }
    }
}