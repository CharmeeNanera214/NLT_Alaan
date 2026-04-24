tableextension 50126 "GL Entry Ext" extends "G/L Entry"
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