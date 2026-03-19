tableextension 50134 "Bank Recon. Line" extends "Bank Acc. Reconciliation Line"
{
    fields
    {
        field(50100; "Debit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Debit Amount';
            trigger OnValidate()
            begin
                "Statement Amount" := "Debit Amount" - "Credit Amount";
            end;
        }
        field(50101; "Credit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Credit Amount';
            trigger OnValidate()
            begin
                "Statement Amount" := "Debit Amount" - "Credit Amount";
            end;
        }
        field(50102; "External Doc no."; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'External Doc No';
        }
    }
}