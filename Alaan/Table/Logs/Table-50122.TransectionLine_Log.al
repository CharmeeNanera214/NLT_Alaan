table 50122 "Transaction Line - Alaan Logs"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(50000; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(1; "Line ID"; Guid)
        {
            Caption = 'Line ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Header ID"; Guid)
        {
            Caption = 'Header ID';
            DataClassification = SystemMetadata;
            TableRelation = "Transactions - Alaan".TransactionId;
        }

        // Amounts
        field(3; "Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = AccountData;
        }
        field(4; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = AccountData;
        }

        // Expense Category (flattened)
        field(5; "Expense Category ID"; Guid)
        {
            Caption = 'Expense Category ID';
            DataClassification = SystemMetadata;
        }
        field(6; "Expense Category Name"; Text[100])
        {
            Caption = 'Expense Category Name';
            DataClassification = AccountData;
        }
        field(7; "Expense Category GL Account"; Code[20])
        {
            Caption = 'Expense Category GL Account';
            DataClassification = AccountData;
        }
        field(8; "Partner Expense Account ID"; Integer)
        {
            Caption = 'Partner Expense Account ID';
            DataClassification = SystemMetadata;
        }
        field(9; "Partner Expense Account Name"; Text[100])
        {
            Caption = 'Partner Expense Account Name';
            DataClassification = AccountData;
        }
        field(10; "Account Details Name"; Text[100])
        {
            Caption = 'Account Details Name';
            DataClassification = AccountData;
        }
        field(11; "Account Details GL Account"; Code[20])
        {
            Caption = 'Account Details GL Account';
            DataClassification = AccountData;
        }

        // Corporate Tax Code
        field(12; "Tax Code ID"; Guid)
        {
            Caption = 'Tax Code ID';
            DataClassification = SystemMetadata;
        }
        field(13; "Tax Code"; Code[50])
        {
            Caption = 'Tax Code';
            DataClassification = AccountData;
            TableRelation = "VAT Posting Setup"."Alaan Tax Code";
        }
        field(14; "Tax Rate"; Decimal)
        {
            Caption = 'Tax Rate';
            DataClassification = AccountData;
        }
        field(15; "Tax Name"; Text[100])
        {
            Caption = 'Tax Name';
            DataClassification = AccountData;
        }
        field(16; "Partner Tax Code ID"; Guid)
        {
            Caption = 'Partner Tax Code ID';
            DataClassification = SystemMetadata;
        }

        // Tag Group (flattened)
        field(17; "Tag Group ID"; Guid)
        {
            Caption = 'Tag Group ID';
            DataClassification = SystemMetadata;
            TableRelation = Dimension.AlaanID;
        }
        field(18; "Tag Group Name"; Text[100])
        {
            Caption = 'Tag Group Name';
            DataClassification = AccountData;
            TableRelation = Dimension.Name;
        }
        field(19; "Tag Group Field Type"; Text[30])
        {
            Caption = 'Tag Group Field Type';
            DataClassification = SystemMetadata;
        }
        field(20; "Tag Group Value"; Text[250])
        {
            Caption = 'Tag Group Value';
            DataClassification = AccountData;
        }
        field(21; "Tracking Category Type"; Text[50])
        {
            Caption = 'Tracking Category Type';
            DataClassification = AccountData;
        }

        // Tag Group Item (flattened)
        field(22; "Tag Group Item ID"; Guid)
        {
            Caption = 'Tag Group Item ID';
            DataClassification = SystemMetadata;
            TableRelation = NLTEmployee."Employee ID";
        }
        field(23; "Tag Group Item Name"; Text[100])
        {
            Caption = 'Tag Group Item Name';
            DataClassification = AccountData;
            TableRelation = NLTEmployee.Name;
        }
        field(24; "Tag Group Item Accounting Ref"; Text[50])
        {
            Caption = 'Tag Group Item Accounting Reference';
            DataClassification = AccountData;
        }
        field(25; "Partner Name"; Text[100])
        {
            Caption = 'Partner Name';
            DataClassification = CustomerContent;
        }
        field(26; "Partner Tag Group Item ID"; Guid)
        {
            Caption = 'Partner Tag Group Item ID';
            DataClassification = SystemMetadata;
        }
        field(27; "Partner Parent ID"; Guid)
        {
            Caption = 'Partner Parent ID';
            DataClassification = SystemMetadata;
        }
        field(28; "Tag Info"; Text[250])
        {
            Caption = 'Tag Info';
            DataClassification = AccountData;
        }

        // Comments
        field(29; "Spender Comments"; Text[250])
        {
            Caption = 'Memo Comments';
            DataClassification = CustomerContent;
        }

        field(30; JournalLineLineNo; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Line Line No';
        }
        field(31; JournalLineDocNo; Code[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal line Doc No';
        }
        field(33; Status; Enum "Sync Status")
        {
            Caption = 'Sync Status';
            DataClassification = ToBeClassified;
        }
        field(1010; "VAT Bus. posting Group"; Code[20])
        {
            Caption = 'Vat Bus. Posting Group';
            DataClassification = ToBeClassified;
        }
        field(1011; "VAT Prod. posting Group"; Code[20])
        {
            Caption = 'Vat Prod. Posting Group';
            DataClassification = ToBeClassified;
        }
        field(50100; SyncType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sync Type';
            OptionMembers = "To Alaan","From Alaan";
            OptionCaption = 'To Alaan,From Alaan';
        }
        field(50101; IsError; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Error';
        }
        field(50102; "Error Type"; Text[20])
        {

            DataClassification = ToBeClassified;
            Caption = 'Error Type';
        }
        field(50103; "Error Message"; Text[1000])
        {
            DataClassification = ToBeClassified;
            Caption = 'Error Message';
        }
        field(50104; ActionType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Action Type';
            OptionMembers = "","Create","Update","Delete";
            OptionCaption = ',Create,Update,Disconnect';
        }
        field(50105; "Sync Date & Time"; DateTime)
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