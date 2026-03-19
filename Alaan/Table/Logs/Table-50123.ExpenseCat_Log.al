table 50123 "Expense Cat - Alaan Logs"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Expense Category Id"; Guid)
        {
            Caption = 'Expense Category Id';
            DataClassification = ToBeClassified;
        }

        field(3; "Name"; Text[100])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(4; CorporateId; Guid)
        {
            Caption = 'Corporate ID';
            DataClassification = ToBeClassified;
        }
        field(5; "Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = ToBeClassified;
        }
        field(6; "partnerExpenseAccountId"; Guid)
        {
            Caption = 'Patner Expense Account ID';
            DataClassification = ToBeClassified;
        }

        field(7; "CorporateTaxCode_Id"; Guid)
        {
            Caption = 'Corporate Tax Code Id';
            DataClassification = ToBeClassified;
        }

        field(8; "CorporateTaxCode_Code"; Code[20])
        {
            Caption = 'Corporate Tax Code';
            DataClassification = ToBeClassified;
        }
        field(9; BC_GLAcc_NO; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC GL Account No';
        }
        field(10; BC_EXPCAT_CODE; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Expense category Code';
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
        key(Pk; EntryNo)
        {
            Clustered = true;
        }
    }
}