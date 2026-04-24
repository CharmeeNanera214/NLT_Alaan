/*CREATE PAYMENT JOURNAL ENTRIES FROM TRANSACTION LINES */
codeunit 50148 "Sync Transactions Test"
{
    procedure SyncTransaction(TxnId: Guid)
    begin
        Clear(TransactionID);
        Clear(Transaction);
        Clear(TransactionLine);
        Clear(IsBankLine);
        Clear(JourLineDocNo);
        Clear(TXNHeaderError);

        IsBankLine := false;
        if not Transaction.Get(TxnId) then
            Error('No Transaction found with Txn ID : %1', TxnId.ToText());
        TransactionID := TxnId;

        checkErrors();
        GetSetup();
        GetJournalAccountType();

        case Transaction."Payment Journal Terms" of
            Transaction."Payment Journal Terms"::"Single GL", Transaction."Payment Journal Terms"::"Single Vendor":
                if not CreateSinglePaymentJournalLine() then
                    TXNHeaderError := GetLastErrorText;
            Transaction."Payment Journal Terms"::"Multiple GL", Transaction."Payment Journal Terms"::"Multiple Vendor":
                if not CreateMultiplePaymentJournalLine() then
                    TXNHeaderError := GetLastErrorText;
        end;
        Transaction."Error Message" := TXNHeaderError;
        Transaction.SyncStatus := TxnHeaderSync;
        Transaction.JournalDocNo := JourLineDocNo;

        /*Make it enable for some time
        if not SyncCashback() then begin
            Transaction."Error Message" := GetLastErrorText;
        end;
        */
        if Transaction.Modify(true) and GuiAllowed then
            Message('Journal Line Created');
    end;

    [TryFunction]
    local procedure CreateSinglePaymentJournalLine()
    begin
        TransactionLine.SetFilter("Header ID", TransactionID);
        TransactionLine.SetRange(LineType, TransactionLine.LineType::"Actual Line");
        if TransactionLine.FindFirst() then begin
            if (TransactionLine.Status <> TransactionLine.Status::Posted) then begin
                GetAccountNoforLine();
                Clear(Amount);

                //Code added on 13-4-26 to replace the billing amount with amount exculdding fees
                // Amount := Transaction."Billing Amount";
                Amount := Transaction."Transaction Amount";

                GetNewDocNo := true;
                SyncLine();
            end;
        end
        else
            Error('No Transaction Lines Found');
    end;

    [TryFunction]
    local procedure CreateMultiplePaymentJournalLine()
    begin
        TransactionLine.SetFilter("Header ID", TransactionID);
        TransactionLine.SetRange(LineType, TransactionLine.LineType::"Actual Line");
        if TransactionLine.FindFirst() then begin
            GetNewDocNo := true;
            repeat
                if (TransactionLine.Status <> TransactionLine.Status::Posted) then begin
                    GetAccountNoforLine();
                    Clear(Amount);
                    // Amount := TransactionLine.Amount;
                    Amount := GetBalance();
                    SyncLine();
                    GetNewDocNo := false;
                end;
            until TransactionLine.Next() = 0;

            SyncBankLine();
        end
        else
            Error('No Transaction Lines Found');
    end;

    local procedure SyncLine()
    begin
        Clear(TxnHeaderSync);
        if SyncTxnByLine(TransactionLine) then begin
            TransactionLine.JournalLineDocNo := GenJourLine."Document No.";
            TransactionLine.JournalLineLineNo := GenJourLine."Line No.";
            TransactionLine.Status := TransactionLine.Status::Created;
            TransactionLine."Error Message" := '';
        end
        else
            TransactionLine."Error Message" := GetLastErrorText;
        TxnHeaderSync := TransactionLine.Status;
        TransactionLine.Modify(true);
    end;

    [TryFunction]
    local procedure SyncTxnByLine(TxnLine: Record "Transaction Line - Alaan")
    var
        Txndate: Date;
        DimensionSetID: Integer;
        NewDocNo: Code[20];
        NoSeriesMGT: Codeunit "No. Series";
        GenBatch: Record "Gen. Journal Batch";
        PMTDocumentNo: Code[20];
        PMTLineNo: Integer;
        feeLine: Record "Gen. Journal Line";
    begin
        JourLineDocNo := Transaction.JournalDocNo;
        InitNewTXNLogRecord(TxnLine, AccountType);
        TxnJurLogs."Currency Code" := Transaction."Billing Currency";
        TxnJurLogs."Ext. Doc no" := Transaction."Reference Number";
        Txndate := Transaction."Txn Clearing Date".Date;
        TxnJurLogs.BCPostingDate := Txndate;

        //check that line exist or not
        Clear(GenJourLine);
        GenJourLine.SetFilter("Journal Template Name", GenTempName);
        GenJourLine.SetFilter("Journal Batch Name", GenBatchName);
        GenJourLine.SetFilter(TxnId, TxnLine."Header ID");
        GenJourLine.SetFilter(TxnLineId, TxnLine."Line ID");
        GenJourLine.SetFilter("Document No.", TxnLine.JournalLineDocNo);
        GenJourLine.SetRange("Line No.", TxnLine.JournalLineLineNo);

        if not GenJourLine.FindFirst() then begin
            TxnJurLogs.ActionType := TxnJurLogs.ActionType::Create;
            //get Document NO
            Clear(GenBatch);
            if GenBatch.Get(GenTempName, GenBatchName) and GetNewDocNo then begin
                GenBatch.TestField("No. Series");
                NewDocNo := NoSeriesMGT.GetNextNo(GenBatch."No. Series");
                JourLineDocNo := NewDocNo;
            end;
            if not CreateNewGenLine(Txndate, JourLineDocNo, AccountNo, BankAccount, Amount, TxnLine."Header ID", TxnLine."Line ID") then
                Error('Error while creating new line on Payment Journal');
        end
        else
            TxnJurLogs.ActionType := TxnJurLogs.ActionType::Update;

        TxnJurLogs.JurBatch := GenJourLine."Journal Batch Name";
        TxnJurLogs.JurLineNo := GenJourLine."Line No.";
        TxnJurLogs.JurLineDocNo := GenJourLine."Document No.";
        if UpdateGenLine(TxnLine) then begin
            Transaction.JournalDocNo := GenJourLine."Document No.";
            Transaction.Modify();
            TxnJurLogs."Ext. Doc no" := GenJourLine."External Document No.";
        end
        else begin
            TxnJurLogs."Error Message" := GetLastErrorText;
            TxnJurLogs.IsError := true;
        end;
        TxnJurLogs.Modify();

        //SET Dimension and add log entry
        DimensionSetID := SetDimension.SetDimension(TxnLine, AccountType);
        if DimensionSetID <> 0 then begin
            GenJourLine.Validate("Dimension Set ID", DimensionSetID);
            if GenJourLine.Modify(true) then begin
                TxnJurLogs.DimensionID := DimensionSetID;
                TxnJurLogs.Modify();
            end;
        end;

        //Code added on 13-4-26 for adding Transaction fee line on payment journal
        if Transaction."Fee Amount" <> 0 then begin
            Clear(feeLine);
            feeLine.SetFilter("Journal Template Name", GenTempName);
            feeLine.SetFilter("Journal Batch Name", GenBatchName);
            feeLine.SetFilter(TxnId, TxnLine."Header ID");
            feeLine.SetFilter(TxnLineId, TxnLine."Line ID");
            feeLine.SetFilter("Document No.", TxnLine.JournalLineDocNo);
            feeLine.SetRange("Account No.", NLTSetup."Alaan Trans. Fees Account");
            if not feeLine.FindFirst() then begin
                // Clear(GenJourLine);
                // GenJourLine.SetFilter("Journal Template Name", GenTempName);
                // GenJourLine.SetFilter("Journal Batch Name", GenBatchName);
                // GenJourLine.SetFilter(TxnId, TxnLine."Header ID");
                // GenJourLine.SetFilter(TxnLineId, TxnLine."Line ID");
                // GenJourLine.SetFilter("Document No.", TxnLine.JournalLineDocNo);
                // GenJourLine.SetRange("Line No.", TxnLine.JournalLineLineNo);
                // if GenJourLine.FindFirst() then
                if not CreateAlaanTransFeeLine(Txndate, JourLineDocNo, AccountNo, BankAccount, Amount, TxnLine."Header ID", TxnLine."Line ID", TxnLine) then
                    Error('Error while creating new line on Payment Journal');
            end;
        end;
    end;
    //Process neeeds to handle cashback of transaction, currently not useful
    // [TryFunction]
    // local procedure SyncCashback()
    // begin
    //     Clear(TransactionLine);
    //     IsBankLine := true;
    //     GetNewDocNo := false;
    //     Amount := Transaction."Cashback amount";
    //     AccountType := AccountType::"Bank Account";
    //     GetAccountNoforLine();
    //     TransactionLine.SetFilter("Header ID", Transaction.TransactionId);
    //     TransactionLine.SetRange(LineType, TransactionLine.LineType::"Cashback Line");
    //     if (not TransactionLine.FindFirst()) and (Transaction."Cashback amount" <> 0) then
    //         CreateNewTxnLine(false);

    //     IsBankLine := false;

    //     if TransactionLine.Status = TransactionLine.Status::Posted then exit;

    //     if Transaction."Cashback amount" = 0 then begin
    //         if not DeleteCashBackLine() then
    //             TransactionLine."Error Message" := GetLastErrorText;
    //         exit;
    //     end;
    //     if SyncTxnByLine(TransactionLine) then begin
    //         TransactionLine.JournalLineDocNo := GenJourLine."Document No.";
    //         TransactionLine.JournalLineLineNo := GenJourLine."Line No.";
    //         TransactionLine.Amount := Amount;
    //         TransactionLine.Status := TransactionLine.Status::Created;
    //         TransactionLine."Error Message" := '';
    //     end
    //     else begin
    //         TransactionLine."Error Message" := GetLastErrorText;
    //     end;
    //     TxnHeaderSync := TransactionLine.Status;
    //     TransactionLine.Modify(true);
    // end;

    local procedure CreateNewGenLine(Txndate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; BalAccNo: Code[20]; Amount: Decimal; TxnID: Guid; TxnLineID: Guid): Boolean
    var
        PAYJourLine: Record "Gen. Journal Line";
        NewLineNo: Integer;
    begin
        Clear(PAYJourLine);
        PAYJourLine.SetFilter("Journal Batch Name", GenBatchName);
        PAYJourLine.SetFilter("Journal Template Name", GenTempName);
        if PAYJourLine.FindLast() then
            NewLineNo := PAYJourLine."Line No." + 10000
        else
            NewLineNo := 10000;

        GenJourLine.Init();
        GenJourLine.Validate("Journal Template Name", GenTempName);
        GenJourLine.Validate("Journal Batch Name", GenBatchName);
        GenJourLine.Validate("Line No.", NewLineNo);
        GenJourLine.Validate("Posting Date", Txndate);
        GenJourLine.Validate("Document Type", GenJourLine."Document Type"::Payment);
        GenJourLine.Validate("Document No.", DocumentNo);
        case AccountType of
            AccountType::Vendor:
                GenJourLine.Validate("Account Type", GenJourLine."Account Type"::Vendor);
            AccountType::"GL Account":
                GenJourLine.Validate("Account Type", GenJourLine."Account Type"::"G/L Account");
            AccountType::"Bank Account":
                GenJourLine.Validate("Account Type", GenJourLine."Account Type"::"Bank Account");
        end;
        GenJourLine.Validate(TxnId, TxnID);
        GenJourLine.Validate(TxnLineId, TxnLineID);
        if GenJourLine.Insert(true) then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreateAlaanTransFeeLine(Txndate: Date; DocumentNo: Code[20]; AccountNo: Code[20]; BalAccNo: Code[20]; Amount: Decimal; TxnID: Guid; TxnLineID: Guid; TLine: Record "Transaction Line - Alaan"): Boolean
    var
        PAYJourLine: Record "Gen. Journal Line";
        NewLineNo: Integer;
    begin
        Clear(PAYJourLine);
        PAYJourLine.SetFilter("Journal Batch Name", GenBatchName);
        PAYJourLine.SetFilter("Journal Template Name", GenTempName);
        if PAYJourLine.FindLast() then
            NewLineNo := PAYJourLine."Line No." + 10000
        else
            NewLineNo := 10000;

        GenJourLine.Init();
        GenJourLine.Validate("Journal Template Name", GenTempName);
        GenJourLine.Validate("Journal Batch Name", GenBatchName);
        GenJourLine.Validate("Line No.", NewLineNo);
        GenJourLine.Validate("Posting Date", Txndate);
        GenJourLine.Validate("Document Type", GenJourLine."Document Type"::Payment);
        GenJourLine.Validate("Document No.", DocumentNo);
        // case AccountType of
        //     AccountType::Vendor:
        //         GenJourLine.Validate("Account Type", GenJourLine."Account Type"::Vendor);
        //     AccountType::"GL Account":
        //         GenJourLine.Validate("Account Type", GenJourLine."Account Type"::"G/L Account");
        //     AccountType::"Bank Account":
        //         GenJourLine.Validate("Account Type", GenJourLine."Account Type"::"Bank Account");
        // end;
        GenJourLine.Validate("Account Type", GenJourLine."Account Type"::"G/L Account");
        GenJourLine.Validate(TxnId, TxnID);
        GenJourLine.Validate(TxnLineId, TxnLineID);
        //////////////////////////////////////////////////////////////////////////////////////////////////////////

        GenJourLine.Validate("Account No.", NLTSetup."Alaan Trans. Fees Account");

        GenJourLine.Validate("Debit Amount", Transaction."Fee Amount");

        GenJourLine.Validate(Description, Transaction."Spender Comments");
        GenJourLine.Validate("External Document No.", Transaction."Reference Number");
        GenJourLine.Validate("Payment Method Code", PaymentMethod);

        // Added on 10-4-26
        GenJourLine.Validate(Memo, Transaction."Spender Comments");

        if TLine.LineType = TLine.LineType::"Cashback Line" then begin
            GenJourLine.Validate("Bal. Account Type", GenJourLine."Bal. Account Type"::"G/L Account");
            GenJourLine.Validate("Bal. Account No.", NLTSetup."Cashback Account");
        end
        else begin
            if Transaction."Payment Journal Terms" in [Transaction."Payment Journal Terms"::"Single GL", Transaction."Payment Journal Terms"::"Single Vendor"] then begin
                GenJourLine.Validate("Bal. Account Type", GenJourLine."Bal. Account Type"::"Bank Account");
                GenJourLine.Validate("Bal. Account No.", BankAccount);
            end;
        end;

        if AccountType = AccountType::"GL Account" then begin
            GenJourLine.Validate("Gen. Posting Type", GenJourLine."Gen. Posting Type"::Purchase);
        end;
        if Transaction.IsForeignVendor then
            GenJourLine.Validate("Amount (LCY)", Transaction."Fee Amount");


        ////////////////////////////////////////////////////////    

        if GenJourLine.Insert(true) then
            exit(true)
        else
            exit(false);
    end;

    local procedure UpdateGenLine(TLine: Record "Transaction Line - Alaan"): Boolean
    begin
        GenJourLine.Validate("Account No.", AccountNo);
        if not IsBankLine then
            GenJourLine.Validate("Debit Amount", Amount)
        else
            GenJourLine.Validate("Credit Amount", Amount);

        GenJourLine.Validate(Description, Transaction."Spender Comments");
        GenJourLine.Validate("External Document No.", Transaction."Reference Number");
        GenJourLine.Validate("Payment Method Code", PaymentMethod);

        // Added on 10-4-26
        GenJourLine.Validate(Memo, Transaction."Spender Comments");


        if (Transaction."Transaction Type" = Transaction."Transaction Type"::Expense) and (TLine.LineType = TLine.LineType::"Actual Line") then begin
            // if (TLine.LineType = TLine.LineType::"Actual Line") then begin
            GenJourLine.Validate("VAT Bus. Posting Group", TLine."VAT Bus. posting Group");
            GenJourLine.Validate("VAT Prod. Posting Group", TLine."VAT Prod. posting Group");
            // GenJourLine.Validate("VAT %", TLine."Tax Rate");
            // GenJourLine.Validate("VAT Amount", Transaction."VAT Amount");
        end;

        if TLine.LineType = TLine.LineType::"Cashback Line" then begin
            GenJourLine.Validate("Bal. Account Type", GenJourLine."Bal. Account Type"::"G/L Account");
            GenJourLine.Validate("Bal. Account No.", NLTSetup."Cashback Account");
        end
        else begin
            if Transaction."Payment Journal Terms" in [Transaction."Payment Journal Terms"::"Single GL", Transaction."Payment Journal Terms"::"Single Vendor"] then begin
                GenJourLine.Validate("Bal. Account Type", GenJourLine."Bal. Account Type"::"Bank Account");
                GenJourLine.Validate("Bal. Account No.", BankAccount);
            end;
        end;

        if AccountType = AccountType::"GL Account" then begin
            GenJourLine.Validate("Gen. Posting Type", GenJourLine."Gen. Posting Type"::Purchase);
        end;
        if Transaction.IsForeignVendor then
            GenJourLine.Validate("Amount (LCY)", TransactionLine.Amount);
        if GenJourLine.Modify(true) then
            exit(true)
        else
            exit(false);
    end;

    local procedure SyncBankLine()
    begin
        Clear(TransactionLine);
        IsBankLine := true;
        Amount := GetLineTotalAmount();
        AccountType := AccountType::"Bank Account";
        GetAccountNoforLine();

        TransactionLine.SetFilter("Header ID", Transaction.TransactionId);
        TransactionLine.SetRange(LineType, TransactionLine.LineType::"Bank Line");
        if not TransactionLine.FindFirst() then
            CreateNewTxnLine(true);

        if TransactionLine.Status = TransactionLine.Status::Posted then
            exit;

        if SyncTxnByLine(TransactionLine) then begin
            TransactionLine.JournalLineDocNo := GenJourLine."Document No.";
            TransactionLine.JournalLineLineNo := GenJourLine."Line No.";
            TransactionLine.Amount := Amount * -1;
            TransactionLine.Status := TransactionLine.Status::Created;
            TransactionLine."Error Message" := '';
        end
        else begin
            TransactionLine."Error Message" := GetLastErrorText;
        end;
        TxnHeaderSync := TransactionLine.Status;
        TransactionLine.Modify(true);
    end;

    local procedure CreateNewTxnLine(IsBank: Boolean)
    begin
        Clear(TxnHeaderSync);
        TransactionLine.Init();
        TransactionLine."Header ID" := Transaction.TransactionId;
        TransactionLine."Line ID" := CreateGuid();
        if IsBank then
            TransactionLine.LineType := TransactionLine.LineType::"Bank Line"
        else
            TransactionLine.LineType := TransactionLine.LineType::"Cashback Line";

        TransactionLine.Status := TransactionLine.Status::Synced;
        TransactionLine.Insert();
    end;

    local procedure InitNewTXNLogRecord(TranLine: Record "Transaction Line - Alaan"; AccountType: Integer): Boolean
    var
        EntryNo: Integer;
    begin

        EntryNo := GetLastEntryNo(Database::"Txn Jur. - Alaan Logs");
        TxnJurLogs.Init();
        TxnJurLogs.EntryNo := EntryNo + 1;
        TxnJurLogs.TxnId := TranLine."Header ID";
        TxnJurLogs.TxnLineId := TranLine."Line ID";
        TxnJurLogs.SyncType := TxnJurLogs.SyncType::"From Alaan";
        TxnJurLogs."Account Type" := AccountType;
        TxnJurLogs.ActionType := TxnJurLogs.ActionType::Create;
        TxnJurLogs."Sync Date & Time" := CurrentDateTime;
        TxnJurLogs.VendorAlaanID := Transaction.SupplierID;
        TxnJurLogs.VendorNo := Transaction."Vendor No";
        TxnJurLogs.TxnClearingDate := Transaction."Txn Clearing Date";
        TxnJurLogs."Debit Amount" := TranLine.Amount;
        TxnJurLogs.Insert(true)
    end;

    local procedure GetSetup()
    begin
        Clear(NLTSetup);
        Clear(GenBatchName);
        Clear(BankAccount);
        Clear(PaymentMethod);
        NLTSetup.Get(CompanyProperty.ID());
        NLTSetup.TestField(AlaanVendorJurBatch);
        NLTSetup.TestField(AlaanExpenseJurBatch);
        NLTSetup.TestField("Employee Bank");
        NLTSetup.TestField("Payment Method");
        // NLTSetup.TestField("Cashback Account");

        PaymentMethod := NLTSetup."Payment Method";
        BankAccount := NLTSetup."Employee Bank";

        case Transaction."Transaction Type" of
            Transaction."Transaction Type"::Vendor:
                GenBatchName := NLTSetup.AlaanVendorJurBatch;
            Transaction."Transaction Type"::Expense:
                GenBatchName := NLTSetup.AlaanExpenseJurBatch;
        end;
    end;

    local procedure GetJournalAccountType()
    begin
        Clear(AccountType);
        // if IsBankLine then begin
        //     AccountType := AccountType::"Bank Account";
        //     exit;
        // end;

        case Transaction."Transaction Type" of
            Transaction."Transaction Type"::Vendor:
                AccountType := AccountType::Vendor;

            Transaction."Transaction Type"::Expense:
                AccountType := AccountType::"GL Account";
        end;
    end;

    local procedure GetAccountNoforLine()
    begin
        Clear(AccountNo);
        case AccountType of
            AccountType::Vendor:
                AccountNo := Transaction."Vendor No";
            AccountType::"GL Account":
                AccountNo := TransactionLine."Expense Category GL Account";
            AccountType::"Bank Account":
                AccountNo := BankAccount;
        end;
    end;

    procedure GetAccountType(): Option "Vendor","GL Account","Bank Account"
    begin
        exit(AccountType);
    end;

    local procedure GetLastEntryNo(RecordID: Integer) EntryNo: Integer
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.Open(RecordID);
        if RecordRef.FindLast() then begin
            FieldRef := RecordRef.Field(1);
            EntryNo := FieldRef.Value();
        end;
        RecordRef.Close();
        exit(EntryNo);
    end;

    local procedure GetLineTotalAmount() Amount: Decimal
    var
        BankLineTxnLine: Record "Transaction Line - Alaan";
    begin
        BankLineTxnLine.SetFilter("Header ID", Transaction.TransactionId);
        BankLineTxnLine.SetRange(LineType, BankLineTxnLine.LineType::"Actual Line");
        BankLineTxnLine.CalcSums(Amount);
        Amount := BankLineTxnLine.Amount;
        exit(Amount);
    end;

    [TryFunction]
    local procedure DeleteCashBackLine()
    begin
        Clear(GenJourLine);
        GenJourLine.SetFilter(TxnId, TransactionLine."Header ID");
        GenJourLine.SetFilter(TxnLineId, TransactionLine."Line ID");
        if GenJourLine.FindFirst() then
            GenJourLine.Delete();

        TransactionLine.Delete();
    end;


    local procedure GetBalance(): Decimal
    begin
        if (Transaction."Transaction Type" = Transaction."Transaction Type"::Vendor) and (Transaction.IsForeignVendor) then
            exit(TransactionLine."Amount (FCY)")
        else
            exit(TransactionLine.Amount);
    end;

    local procedure CheckErrors()
    var
        TxnLine: Record "Transaction Line - Alaan";
    begin
        if Transaction."Error Message" <> '' then
            Error('Transaction have error. Resolve them first');
        //check Txn type
        if not (Transaction."Transaction Type" in [Transaction."Transaction Type"::Expense, Transaction."Transaction Type"::Vendor]) then
            Error('Transaction Type is not defined. Please Resync Transaction again with Alaan');

        //check lines
        TxnLine.SetFilter("Header ID", TransactionID);
        if not TxnLine.FindSet() then
            Error('No Transaction Line Found');

        //Check PAYMENT JOURNAL TERM : Single Vendor/ Single G/L, Multiple G/L
        if Transaction."Payment Journal Terms" = Transaction."Payment Journal Terms"::"-1" then
            Error('Transaction Syncing Method is not defined');

        //check Lines ERROR
        repeat
            if TxnLine."Error Message" <> '' then
                Error('Transaction Line have error. Resolve them first');
        until TxnLine.Next() = 0
    end;



    var
        SetDimension: Codeunit "Set Dimension On Gen Line";
        Transaction: Record "Transactions - Alaan";
        TransactionLine: Record "Transaction Line - Alaan";
        TxnJurLogs: Record "Txn Jur. - Alaan Logs";
        GenJourLine: Record "Gen. Journal Line";
        NLTSetup: Record "NLT - Alaan Setup";
        TxnHeaderSync: Enum "Sync Status";
        GenBatchName: Code[20];
        GenTempName: Label 'PAYMENTS';
        AccountType: Option "Vendor","GL Account","Bank Account";
        AccountNo: Code[20];
        TransactionID: Guid;
        GetNewDocNo: Boolean;
        JourLineDocNo: Code[20];
        Amount: Decimal;
        BankAccount: Code[20];
        IsBankLine: Boolean;
        PaymentMethod: Code[20];
        TXNHeaderError: Text;

}
