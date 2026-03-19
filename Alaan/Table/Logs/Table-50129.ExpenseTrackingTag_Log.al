table 50129 "Exp. Tracking Tags - Alaan log"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Dimension Code"; Code[20])
        {
            Caption = 'Dimession Code';
            DataClassification = ToBeClassified;
        }
        field(3; TagName; Text[30])
        {
            Caption = 'Expense Tracking Tag Name';
            DataClassification = ToBeClassified;
        }
        field(4; FieldType; Code[20])
        {
            Caption = 'Field Type';
            DataClassification = ToBeClassified;
        }
        field(5; ExpTracTagID; Guid)
        {
            Caption = 'Expense Tracking Tag ID';
            DataClassification = ToBeClassified;
        }
        field(6; IsActive; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = ToBeClassified;
        }
        field(7; IsEmployeeLevel; Boolean)
        {
            Caption = 'Is Employee Level';
            DataClassification = ToBeClassified;
        }
        field(8; CorporateId; Guid)
        {
            Caption = 'Corporate Id';
            DataClassification = ToBeClassified;
        }
        field(11; SyncType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sync Type';
            OptionMembers = "To Alaan","From Alaan";
            OptionCaption = 'To Alaan,From Alaan';
        }
        field(12; IsError; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Error';
        }
        field(13; "Error Type"; Text[20])
        {

            DataClassification = ToBeClassified;
            Caption = 'Error Type';
        }
        field(14; "Error Message"; Text[1000])
        {
            DataClassification = ToBeClassified;
            Caption = 'Error Message';
        }
        field(15; ActionType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Action Type';
            OptionMembers = "","Create","Update","Delete";
            OptionCaption = ',Create,Update,Disconnect';
        }
        field(16; "Sync Date & Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sync Date & Time';
        }


    }

    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
    }
}