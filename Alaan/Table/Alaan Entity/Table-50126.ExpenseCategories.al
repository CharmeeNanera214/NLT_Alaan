table 50126 "Expense Categories"
{
    DataClassification = ToBeClassified;
    Caption = 'Expense Categories';
    fields
    {
        field(1; "EXP. CAT."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Expense Category';
        }
        field(2; "GL Acc"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'G/L Account';
            NotBlank = true;
        }
        field(3; "Expense category Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(4; "EXP CAT DIM CODE"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Expense Category';
            TableRelation = Dimension.Code;
        }
        field(50100; "Expense ID"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Expense ID';
            trigger OnValidate()
            begin
                if IsNullGuid("Expense ID") then
                    "Synced With Alaan" := false
                else
                    "Synced With Alaan" := true;
            end;
        }
        field(50101; "Synced With Alaan"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Connected With Alaan';
        }
        field(50102; "Sync With Alaan"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Connect with Alaan';
        }
        field(50103; "Last Synced with Alaan"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Last Synced with Alaan';
        }
    }

    keys
    {
        key(PK; "EXP. CAT.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        GetExpenseCategoryDimensionCode();
    end;

    trigger OnModify()
    begin
        TestField("GL Acc");
        GetExpenseCategoryDimensionCode();


    end;

    trigger OnRename()
    begin
        GetExpenseCategoryDimensionCode();
        TestField("GL Acc");
        if (Rec."EXP. CAT." <> xRec."EXP. CAT.") or (Rec."GL Acc" <> xRec."GL Acc") then
            if "Synced With Alaan" then
                "Synced With Alaan" := false;
    end;

    trigger OnDelete()
    begin
        if not IsNullGuid("Expense ID") then
            Error('Category is Connected with Alaan. First Delete it from Alaan');
    end;


    local procedure GetExpenseCategoryDimensionCode()
    var
        NLTSetup: Record "NLT - Alaan Setup";
    begin
        if NLTSetup.Get(CompanyProperty.ID()) then
            "EXP CAT DIM CODE" := NLTSetup."Exp. Cat. DIM";
    end;
}