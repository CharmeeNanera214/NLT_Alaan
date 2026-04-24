table 50121 "Transaction - Alaan Logs"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(50000; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }

        // --- Fields from main table (IDs aligned) ---
        field(1; "TransactionId"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Id';
        }
        field(2; "Corporate Id"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Corporate Id';
        }
        field(3; "Billing Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Billing Amount';
        }
        field(4; "VAT Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'VAT Amount';
        }
        field(5; "Billing Currency"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Billing Currency';
        }
        field(6; "Merchant Id"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Merchant Id';
        }
        field(7; "Merchant Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Merchant Name';
        }
        field(8; "Txn Time"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Time';
        }
        field(9; "Txn Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Type';
            OptionMembers = DEBIT,CREDIT;
            OptionCaption = 'DEBIT,CREDIT';
        }
        field(10; "Admin Status"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Admin Status';
            OptionMembers = pending_review,approved,rejected;
        }
        field(11; "Txn Event Type"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Event Type';
            OptionMembers = PURCHASE,REFUND,CASH;
            OptionCaption = 'PURCHASE,REFUND,CASH';
        }
        field(12; "Transaction Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Amount';
        }
        field(13; "Transaction Currency"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Currency';
        }
        field(14; "Pos Environment"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'POS Environment';
        }
        field(15; "Txn Clearing Status"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Clearing Status';
            OptionMembers = NOT_SETTLED,SETTLED;
            OptionCaption = 'NOT SETTLED,SETTLED';
        }
        field(16; "Txn Clearing Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Clearing Date';
        }
        field(17; "Export Status"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Export Status';
            OptionMembers = PENDING,EXPORTED,FAILED,SYNC_IN_PROGRESS,READY_TO_EXPORT;
            OptionCaption = 'PENDING,EXPORTED,FAILED,SYNC IN PROGRESS,READY TO EXPORT';
        }
        field(18; "Settlement Status"; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Settlement Status';
            OptionMembers = NOT_SETTLED,SETTLED;
            OptionCaption = 'NOT SETTLED,SETTLED';
        }
        field(19; "Network Txn Id"; Code[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Network Transaction Id';
        }
        field(20; "Partner Txn Id"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Partner Transaction Id';
        }
        field(21; "Created At"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Created At';
        }
        field(22; "Updated At"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Updated At';
        }
        field(23; "Reference Number"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Reference Number';
        }
        field(24; "Idempotency Key"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Idempotency Key';
        }
        field(25; "Spender Id"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Spender Id';
        }
        field(26; "Spender Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Spender Name';
        }
        field(27; "Spender Email"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Spender Email';
            ExtendedDatatype = EMail;
        }
        field(28; "SupplierID"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Supplier';
        }
        field(29; "Card Id"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Card Id';
        }
        field(30; "Card No"; Text[25])
        {
            DataClassification = ToBeClassified;
            Caption = 'Card Number';
        }
        field(31; "CorpCard Config Id"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Corporate Card Config Id';
        }
        field(32; "TRN"; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'TRN';
        }
        field(33; "Spender Comments"; Text[1048])
        {
            Caption = 'Memo Comments';
            DataClassification = ToBeClassified;
        }
        field(34; "Admin Comments"; Text[1048])
        {
            Caption = 'Admin Comments';
            DataClassification = ToBeClassified;
        }
        field(35; "Cashback amount"; Decimal)
        {
            Caption = 'Cashback Amount';
            DataClassification = ToBeClassified;
        }
        field(36; "Merchant Country Code"; Code[10])
        {
            Caption = 'Merchant Country Code';
            DataClassification = ToBeClassified;
        }

        field(37; "Fee Amount"; Decimal)
        {
            Caption = 'Fee Amount';
            DataClassification = ToBeClassified;
        }

        field(38; "Exchange Rate"; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = ToBeClassified;
        }
        field(39; "Tag Group ID"; Guid)
        {
            Caption = 'Tag Group ID';
            DataClassification = ToBeClassified;
        }
        field(40; "Tag Group Name"; Text[100])
        {
            Caption = 'Tag Group Name';
            DataClassification = ToBeClassified;
        }
        field(41; "Tag Group Item ID"; Guid)
        {
            Caption = 'Tag Group Item ID';
            DataClassification = ToBeClassified;
        }
        field(42; "Tag Group Item Name"; Text[100])
        {
            Caption = 'Tag Group Item Name';
            DataClassification = ToBeClassified;
        }
        field(43; "Accounting Reference"; Text[50])
        {
            Caption = 'Accounting Reference';
            DataClassification = ToBeClassified;
        }

        field(45; "Vendor No"; Code[20])
        {
            Caption = 'Vendor No';
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";
        }

        field(46; "Vendor Name"; Code[250])
        {
            Caption = 'Vendor Name';
            DataClassification = ToBeClassified;
            TableRelation = Vendor.Name;
        }
        field(47; "Receipt URL"; Text[1048])
        {
            Caption = 'Receipt URL';
            DataClassification = ToBeClassified;
        }
        field(5010; SyncType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Sync Type';
            OptionMembers = "To Alaan","From Alaan";
            OptionCaption = 'To Alaan,From Alaan';
        }
        field(5011; IsError; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Error';
        }
        field(5012; "Error Type"; Text[20])
        {

            DataClassification = ToBeClassified;
            Caption = 'Error Type';
        }
        field(5013; "Error Message"; Text[1000])
        {
            DataClassification = ToBeClassified;
            Caption = 'Error Message';
        }
        field(5014; ActionType; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Action Type';
            OptionMembers = "","Create","Update","Delete","Export";
            OptionCaption = ',Create,Update,Disconnect,Export';
        }
        field(5015; "Sync Date & Time"; DateTime)
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

    trigger OnInsert()
    begin
        EntryNo := getlastentryno()
    end;

    local procedure getlastentryno(): Integer
    var
        log: Record "Transaction - Alaan Logs";
    begin
        log.SetCurrentKey(EntryNo);
        if log.FindLast() then
            exit(log.EntryNo + 1)
        else
            exit(1);
    end;
}
