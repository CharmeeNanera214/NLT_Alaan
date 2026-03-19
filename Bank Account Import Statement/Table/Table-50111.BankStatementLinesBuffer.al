table 50111 "Bank Statement Lines Buffer"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(50105; EntryNo; Integer)
        {
            AutoIncrement = true;
        }
        field(1; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";
        }
        field(2; "Statement No."; Code[20])
        {
            Caption = 'Statement No.';
            TableRelation = "Bank Acc. Reconciliation"."Statement No." where("Bank Account No." = field("Bank Account No."));
        }
        field(3; "Statement Line No."; Integer)
        {
            Caption = 'Statement Line No.';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; "Statement Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            Caption = 'Statement Amount';

            trigger OnValidate()
            begin
                Difference := "Statement Amount" - "Applied Amount";
            end;
        }
        field(8; Difference; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Difference';

            trigger OnValidate()
            begin
                "Statement Amount" := "Applied Amount" + Difference;
            end;
        }
        field(9; "Applied Amount"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Applied Amount';
            Editable = false;

            trigger OnValidate()
            begin
                Difference := "Statement Amount" - "Applied Amount";
            end;
        }
        field(11; "Applied Entries"; Integer)
        {
            Caption = 'Applied Entries';
            Editable = false;
        }
        field(12; "Value Date"; Date)
        {
            Caption = 'Value Date';
        }
        field(13; "Ready for Application"; Boolean)
        {
            Caption = 'Ready for Application';
        }
        field(14; "Check No."; Code[20])
        {
            Caption = 'Check No.';
        }
        field(15; "Related-Party Name"; Text[250])
        {
            Caption = 'Related-Party Name';
        }
        field(16; "Additional Transaction Info"; Text[100])
        {
            Caption = 'Additional Transaction Info';
        }
        field(17; "Data Exch. Entry No."; Integer)
        {
            Caption = 'Data Exch. Entry No.';
            Editable = false;
            TableRelation = "Data Exch.";
        }
        field(18; "Data Exch. Line No."; Integer)
        {
            Caption = 'Data Exch. Line No.';
            Editable = false;
        }
        field(20; "Statement Type"; Enum "Bank Acc. Rec. Stmt. Type")
        {
            Caption = 'Statement Type';
        }
        field(21; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
        }
        field(22; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account" where("Account Type" = const(Posting),
                                                                                          Blocked = const(false))
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Account Type" = const("IC Partner")) "IC Partner"
            else
            if ("Account Type" = const(Employee)) Employee;
        }
        field(23; "Transaction Text"; Text[140])
        {
            Caption = 'Transaction Text';

            trigger OnValidate()
            begin
                if ("Statement Type" = "Statement Type"::"Payment Application") or (Description = '') then
                    Description := CopyStr("Transaction Text", 1, MaxStrLen(Description));
            end;
        }
        field(24; "Related-Party Bank Acc. No."; Text[100])
        {
            Caption = 'Related-Party Bank Acc. No.';
        }
        field(25; "Related-Party Address"; Text[100])
        {
            Caption = 'Related-Party Address';
        }
        field(26; "Related-Party City"; Text[50])
        {
            Caption = 'Related-Party City';
        }
        field(27; "Payment Reference No."; Code[50])
        {
            Caption = 'Payment Reference';
        }
        field(31; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          Blocked = const(false));
        }
        field(32; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          Blocked = const(false));

        }
        field(50; "Match Confidence"; Enum "Bank Rec. Match Confidence")
        {
            CalcFormula = max("Applied Payment Entry"."Match Confidence" where("Statement Type" = field("Statement Type"),
                                                                                "Bank Account No." = field("Bank Account No."),
                                                                                "Statement No." = field("Statement No."),
                                                                                "Statement Line No." = field("Statement Line No.")));
            Caption = 'Match Confidence';
            Editable = false;
            FieldClass = FlowField;
            InitValue = "None";
        }
        field(51; "Match Quality"; Integer)
        {
            CalcFormula = max("Applied Payment Entry".Quality where("Bank Account No." = field("Bank Account No."),
                                                                     "Statement No." = field("Statement No."),
                                                                     "Statement Line No." = field("Statement Line No."),
                                                                     "Statement Type" = field("Statement Type")));
            Caption = 'Match Quality';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Sorting Order"; Integer)
        {
            Caption = 'Sorting Order';
        }
        field(61; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            Editable = false;
        }
        field(70; "Transaction ID"; Text[50])
        {
            Caption = 'Transaction ID';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
        field(50100; "Debit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Debit Amount';
        }
        field(50101; "Credit Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
            Caption = 'Credit Amount';
        }
        field(50102; "External Doc no."; Code[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'External Doc No';
        }
        field(50103; "Line Transfered"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Line Transfered';
        }
        field(50104; LinePosted; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Line Posted';
        }
        field(50106; TxnId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Txn id';
        }
        field(50107; JournalDocNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Document No';
        }
        field(50108; JournalDocLineNo; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Document Line No';
        }
        field(50109; IsBalanceLine; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Is Balance Line';
        }
        field(50110; JournalLineAccType; Enum "Gen. Journal Account Type")
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Line Account Type';
        }
        field(50111; JournalLineAccNo; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Line Account No';
        }
        field(50112; Reversed; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Reversed';
        }
        field(50113; JournalAccName; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Journal Account Name';
        }
    }

    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
        key(Key1; "Statement Type", "Bank Account No.", "Statement No.", "Statement Line No.")
        {
        }
        key(Key2; "Account Type", "Statement Amount")
        {
        }
        key(ExtDoc; "External Doc no.")
        {
            Enabled = true;
        }
    }

    fieldgroups
    {
    }

    procedure GetCurrencyCode(): Code[10]
    var
        BankAccount: Record "Bank Account";
    begin
        if "Bank Account No." = BankAccount."No." then
            exit(BankAccount."Currency Code");

        if BankAccount.Get("Bank Account No.") then
            exit(BankAccount."Currency Code");

        exit('');
    end;
}