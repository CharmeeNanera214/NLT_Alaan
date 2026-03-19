table 50112 "Bank Import Statement Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; EntryNo; Code[5])
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No';
        }
        field(2; "General Journal Template"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'General Journal Template';
            TableRelation = "Gen. Journal Template".Name where(Type = filter('General'));

            trigger OnValidate()
            begin
                if (Rec."General Journal Template" <> xRec."General Journal Template") or (Rec."General Journal Template" = '') then
                    ChangeBankBatches(Rec."General Journal Template");
            end;
        }
    }

    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    local procedure ChangeBankBatches(TempCode: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        if not BankAccount.IsEmpty then
            BankAccount.ModifyAll("General Batch", '');
    end;

}