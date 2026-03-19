table 50133 "Tax Code - Alaan Logs"
{
    DataClassification = ToBeClassified;
    Caption = 'Supplier - Alaan Logs';

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; TaxCodeID; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tax Code ID';
        }
        field(3; CorporateId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Corporate ID';
        }
        field(4; BC_Tax_Code; Code[45])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Tax Code';
        }
        field(5; Rate; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Rate';
        }
        field(6; Name; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Name';
        }
        field(7; IsDeleted; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Deleted';
        }
        field(8; PartnerTaxCodeId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Partner Tax Code ID';
        }
        field(9; partnerTaxRateStatus; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Partner Tax Rate Status';
        }
        field(10; accountingCompanyId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Accounting Company ID';
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