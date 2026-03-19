table 50130 "Txn Jur. - Alaan Logs"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Entry No';
            AutoIncrement = true;
        }
        field(2; TxnId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction ID';
        }
        field(3; JurLineDocNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Line Document No';
        }
        field(4; JurLineNo; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Line No';
        }
        field(5; JurBatch; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Batch';
        }
        field(6; "Account Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Account Type';
            OptionMembers = "Vendor","GL Account","Bank Account";
            OptionCaption = 'Vendor,GL Account,Bank Account';
        }
        field(7; VendorNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'VendorNo';
        }
        field(8; VendorAlaanID; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Vendor Alaan ID';
        }
        field(9; GLAccountNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'GLAccount No';
        }
        field(10; BCPostingDate; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'BC Posting date';
        }
        field(11; TxnClearingDate; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Clearing date';
        }
        field(12; "Currency Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Currency Code';
        }
        field(13; "Debit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Debit Amount';
        }
        field(14; "Credit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Credit Amount';
        }
        field(15; "Employee Dimension Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Employee Dimension Code';
        }
        field(16; "Employee Dimension Value"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Employee Dimension Value';
        }
        field(17; "Account Dimension Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Account Dimension Code';
        }
        field(18; "Account Dimension Value"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Account Dimension Value';
        }

        field(19; DimensionID; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Dimension ID';
            TableRelation = "Dimension Set Entry"."Dimension Set ID";
        }
        field(20; "Ext. Doc no"; Code[35])
        {
            DataClassification = ToBeClassified;
            Caption = 'External Doc No';
        }
        field(21; TxnLineId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Line Id';
        }
        field(5010; SyncType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sync Type';
            OptionMembers = "To Alaan","From Alaan";
            OptionCaption = 'To Alaan,From Alaan';
        }
        field(5020; IsError; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Error';
        }
        field(5040; "Error Message"; Text[1000])
        {
            DataClassification = ToBeClassified;
            Caption = 'Error Message';
        }
        field(5050; ActionType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Action Type';
            OptionMembers = "","Create","Update","Delete";
            OptionCaption = ',Create,Update,Disconnect';
        }
        field(5060; "Sync Date & Time"; DateTime)
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