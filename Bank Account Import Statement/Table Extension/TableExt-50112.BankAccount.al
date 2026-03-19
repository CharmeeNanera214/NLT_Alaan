tableextension 50112 "Bank Account EXT" extends "Bank Account"
{
    fields
    {
        field(50100; "General Batch"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'General Batch';
        }
    }
}