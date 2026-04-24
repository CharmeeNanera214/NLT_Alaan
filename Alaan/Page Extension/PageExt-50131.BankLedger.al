pageextension 50133 "Bank Ledger Ext" extends "Bank Account Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field(Memo; Rec.Memo)
            {
                ApplicationArea = All;
                Caption = 'Memo';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}