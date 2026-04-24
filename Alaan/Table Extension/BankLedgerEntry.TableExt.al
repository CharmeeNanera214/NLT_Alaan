tableextension 50127 "Bank Ledger Ext" extends "Bank Account Ledger Entry"
{
    fields
    {
        field(50100; Memo; Text[1028])
        {
            DataClassification = ToBeClassified;
            Caption = 'Memo';
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}