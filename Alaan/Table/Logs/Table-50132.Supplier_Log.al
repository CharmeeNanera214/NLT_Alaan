table 50132 "Supplier - Alaan Logs"
{
    DataClassification = ToBeClassified;
    Caption = 'Alaan Supplier Buffer';
    fields
    {
        field(1; No; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Caption = 'Entry No';
        }
        field(2; SupplierId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Alaan ID';
        }
        field(3; corporateId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Corporate ID';
        }
        field(4; status; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Status';
        }
        field(5; companyId; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Company ID';
        }
        field(6; partnerSupplierName; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Partner Supplier Name';
        }
        field(7; creationType; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Creation Type';
        }
        field(8; BC_Vendor_NO; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Vendor No';
        }
        field(9; SyncType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sync Type';
            OptionMembers = "To Alaan","From Alaan";
            OptionCaption = 'To Alaan,From Alaan';
        }
        field(10; IsError; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Error';
        }
        field(11; "Error Type"; Text[20])
        {

            DataClassification = ToBeClassified;
            Caption = 'Error Type';
        }
        field(12; "Error Message"; Text[1000])
        {
            DataClassification = ToBeClassified;
            Caption = 'Error Message';
        }
        field(13; ActionType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Action Type';
            OptionMembers = "","Create","Update","Delete";
            OptionCaption = ',Create,Update,Disconnect';
        }
        field(14; "Sync Date & Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sync Date & Time';
        }
    }


    keys
    {
        key(PK; No)
        {
            Clustered = true;
        }
    }
}