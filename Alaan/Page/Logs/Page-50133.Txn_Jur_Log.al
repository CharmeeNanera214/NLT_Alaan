page 50133 "Txn Jur. - Alaan Logs"
{
    PageType = List;
    Caption = 'Alaan Logs - Transaction Journal';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Txn Jur. - Alaan Logs";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    Caption = 'Entry No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TxnId; Rec.TxnId)
                {
                    Caption = 'Transaction ID';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(JurLineDocNo; Rec.JurLineDocNo)
                {
                    Caption = 'Journal Line Document No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sync Date & Time"; Rec."Sync Date & Time")
                {
                    Caption = 'Sync Date & Time';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(SyncType; Rec.SyncType)
                {
                    Caption = 'Sync Type';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ActionType; Rec.ActionType)
                {
                    Caption = 'Action Type';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    Caption = 'Account Type';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(VendorNo; Rec.VendorNo)
                {
                    Caption = 'Vendor No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(GLAccountNo; Rec.GLAccountNo)
                {
                    Caption = 'G/L Account No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(TxnClearingDate; Rec.TxnClearingDate)
                {
                    Caption = 'Transaction Clearing Date';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    Caption = 'Debit Amount';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    Caption = 'Credit Amount';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(IsError; Rec.IsError)
                {
                    Caption = 'Is Error';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Error Message"; Rec."Error Message")
                {
                    Caption = 'Error Message';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DimensionID; Rec.DimensionID)
                {
                    Caption = 'Dimension ID';
                    ApplicationArea = All;
                }
                // field(ACCDIMCODE; ACCDIMCODE)
                // {
                //     ApplicationArea = All;
                // }
                // field(ACCDIMVALUE; ACCDIMVALUE)
                // {
                //     ApplicationArea = All;

                // }
                // field(EMPDIMCODE; EMPDIMCODE)
                // {
                //     ApplicationArea = All;

                // }
                // field(EMPDIMVALUE; EMPDIMVALUE)
                // {
                //     ApplicationArea = All;

                // }
            }
        }
    }

    // trigger OnAfterGetRecord()
    // var
    //     DimSetEntry: Record "Dimension Set Entry";
    // begin
    //     Clear(DimSetEntry);
    //     DimSetEntry.SetRange("Dimension Set ID", Rec.DimensionID);
    //     DimSetEntry.FindSet();
    //     if DimSetEntry.Count = 2 then begin
    //         DimSetEntry.FindFirst();
    //         EMPDIMCODE := DimSetEntry."Dimension Code";
    //         EMPDIMVALUE := DimSetEntry."Dimension Value Code";

    //         if DimSetEntry.Next() <> 0 then begin
    //             ACCDIMCODE := DimSetEntry."Dimension Code";
    //             ACCDIMVALUE := DimSetEntry."Dimension Value Code";
    //         end;
    //     end;
    // end;




    var
        ACCDIMCODE: Code[20];
        ACCDIMVALUE: Code[20];
        EMPDIMCODE: Code[20];
        EMPDIMVALUE: Code[20];
}