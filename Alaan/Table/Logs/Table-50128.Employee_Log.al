table 50128 "NLT Employee - Alaan Logs"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; NLTEmployeeId; Guid)
        {
            Caption = 'Alaan User Id';
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
        field(5; "IsActive"; Boolean)
        {
            Caption = 'Is Active';
            DataClassification = ToBeClassified;
        }
        field(6; "TaxGroupId"; Guid)
        {
            Caption = 'Tax Group ID';
            DataClassification = ToBeClassified;
        }

        field(8; "Accounting Reference"; Code[100])
        {
            Caption = 'Accounting Reference';
            DataClassification = ToBeClassified;
        }
        field(9; BC_Emp_Dim_Code; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Employee Dimension Code';
        }
        field(10; NLT_Emp_Code; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Alaan User Code';
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