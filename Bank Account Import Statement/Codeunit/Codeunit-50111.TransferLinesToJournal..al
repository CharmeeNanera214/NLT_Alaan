codeunit 50111 "Bank Import Statement MGT"
{
    /*
        If the General Journal Worksheet Lines are created through the Bank Statement Import functionality, 
        and the Document Number is later changed using the Renumber Document Number action, 
        then the updated Document Number should also be reflected in the Bank Statement Buffer Lines. 
    */
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnRenumberDocNoOnLinesOnAfterModifyGenJnlLine3, '', false, false)]
    local procedure OnRenumberDocNoOnLinesOnAfterModifyGenJnlLine3(var DocNo: Code[20]; var GenJournalLine3: Record "Gen. Journal Line")
    var
        TXNLine: Record "Transaction Line - Alaan";
        BankStmBufferLines: Record "Bank Statement Lines Buffer";
        TxnId: Guid;
    begin
        if (not IsNullGuid(GenJournalLine3.TxnId)) and (not IsNullGuid(GenJournalLine3.TxnLineId)) then begin
            TXNLine.SetFilter("Header ID", GenJournalLine3.TxnId);
            TXNLine.SetFilter("Line ID", GenJournalLine3.TxnLineId);
            if TXNLine.FindSet() then begin
                TXNLine.JournalLineDocNo := DocNo;
                TXNLine.JournalLineLineNo := GenJournalLine3."Line No.";
                TXNLine.Modify();
            end;
        end;

        if (not IsNullGuid(GenJournalLine3.TxnId)) and (IsNullGuid(GenJournalLine3.TxnLineId)) then begin
            TxnId := GenJournalLine3.TxnId;
            BankStmBufferLines.SetFilter(TxnId, TxnId);
            if BankStmBufferLines.FindSet() then begin
                BankStmBufferLines.JournalDocNo := DocNo;
                BankStmBufferLines.Modify();
            end;
        end;
    end;

    // Updates the status on the buffer line as part of the transaction reversal process.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reversal-Post", OnRunOnBeforeDeleteAll, '', false, false)]
    local procedure OnRunOnBeforeDeleteAll(var ReversalEntry: Record "Reversal Entry"; Number: Integer)
    var
        BankStmBufferLines: Record "Bank Statement Lines Buffer";
        DocNo: Code[20];
    begin
        DocNo := ReversalEntry."Document No.";
        BankStmBufferLines.SetFilter(JournalDocNo, DocNo);
        BankStmBufferLines.SetRange(LinePosted, true);
        if BankStmBufferLines.FindSet() then
            BankStmBufferLines.ModifyAll(Reversed, true);
    end;

    /*
        Creates General Journal actual and balancing lines from Bank Import Statement lines 
        and inserts corresponding records into the buffer table.
    */
    procedure TransferLinesToGeneralJournal(Rec: Record "Bank Acc. Reconciliation"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        GetSetup(Rec);
        Clear(NeedNewJournalDocNo);
        Clear(BankStatementLines);
        Clear(BankStatementLinesBuffer);
        NeedNewJournalDocNo := true;
        GetLastLineNo();
        GetLastUsedDocNo();
        Clear(TxnId);
        BankStatementLines.Get(BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.", BankAccReconciliationLine."Statement No.", BankAccReconciliationLine."Statement Line No.");
        TxnId := TransferLinesToBuffer(false);  //If Txn Id is null means there is no line exist in Buffer with this doc no.
        if not IsNullGuid(TxnId) then begin
            //buffer line is not posted or reverse.
            if not (BankStatementLinesBuffer.LinePosted or BankStatementLinesBuffer.Reversed or BankStatementLinesBuffer."Line Transfered") then begin
                CreateNewGenjournalLine(false, BankStatementLines."Transaction Date", BankStatementLines.Description, BankStatementLines."External Doc no.", (BankStatementLines."Statement Amount" * -1), TxnId);
                BankStatementLinesBuffer.JournalDocNo := JourLineDocNo;
                BankStatementLinesBuffer."Line Transfered" := true;
                BankStatementLinesBuffer.JournalDocLineNo := GenJouLines."Line No.";
                BankStatementLinesBuffer.JournalLineAccType := GenJouLines."Account Type";
                BankStatementLinesBuffer.JournalLineAccNo := GenJouLines."Account No.";
                BankStatementLinesBuffer.JournalAccName := GetJournaAccountName(GenJouLines."Account Type", GenJouLines."Account No.");
            end
            else begin
                JourLineDocNo := BankStatementLinesBuffer.JournalDocNo;
                BankStatementLinesBuffer."Line Transfered" := true;
            end;
            BankStatementLinesBuffer.Modify();
        end;

        //Create balance line for bank statement line
        TxnId := TransferLinesToBuffer(true);
        if not IsNullGuid(TxnId) then begin
            //buffer line is not posted or reverse.
            if not (BankStatementLinesBuffer.LinePosted or BankStatementLinesBuffer.Reversed or BankStatementLinesBuffer."Line Transfered") then begin
                CreateNewGenjournalLine(true, BankStatementLines."Transaction Date", BankStatementLines.Description, BankStatementLines."External Doc no.", BankStatementLines."Statement Amount", TxnId);
                // CreateNewGenjournalLine(true, BankStatementLines."Transaction Date", BankStatementLines.Description, BankStatementLines."External Doc no.", (BankStatementLines."Statement Amount" * -1), TxnId);
                BankStatementLinesBuffer.JournalDocNo := JourLineDocNo;
                BankStatementLinesBuffer."Line Transfered" := true;
                BankStatementLinesBuffer.JournalDocLineNo := GenJouLines."Line No.";
                BankStatementLinesBuffer.JournalLineAccType := GenJouLines."Account Type";
                BankStatementLinesBuffer.JournalLineAccNo := GenJouLines."Account No.";
                BankStatementLinesBuffer.JournalAccName := GetJournaAccountName(GenJouLines."Account Type", GenJouLines."Account No.");
            end
            else begin
                JourLineDocNo := BankStatementLinesBuffer.JournalDocNo;
                BankStatementLinesBuffer."Line Transfered" := true;
            end;
            BankStatementLinesBuffer.Modify();
        end;


        // ListofBankStatementLines.Add(BankAccReconciliationLine."External Doc no.");
        // DeleteImportedLines();
    end;


    // Creates General Journal lines from buffer records.
    procedure TransferLinesFromBuffer(Rec: Record "Bank Acc. Reconciliation"; ListOfSelectedRec: List of [Code[35]])
    begin
        GetSetup(Rec);
        GetLastLineNo();
        GetLastUsedDocNo();
        SelectedRecord := ListOfSelectedRec;

        Clear(NeedNewJournalDocNo);
        NeedNewJournalDocNo := false;
        TransferSTMLineToGeneralJournal();
        NeedNewJournalDocNo := false;
        TransferBalLineToGeneralJournal();
    end;

    //used to transfer lines from buffer actual lines 
    local procedure TransferSTMLineToGeneralJournal()
    var
        NotTransferedLines: Record "Bank Statement Lines Buffer";
        BalanceLines: Record "Bank Statement Lines Buffer";
    begin
        NotTransferedLines.SetRange(IsBalanceLine, false);
        NotTransferedLines.SetRange(LinePosted, false);
        NotTransferedLines.SetRange("Line Transfered", false);
        NotTransferedLines.SetRange(Reversed, false);
        NotTransferedLines.SetFilter("Bank Account No.", BankNo);
        NotTransferedLines.SetFilter("Statement No.", StatementNo);
        if NotTransferedLines.FindSet() then
            repeat
                //used to work only for selected actual lines.
                if not SelectedRecord.Contains(NotTransferedLines."External Doc no.") then
                    continue;

                Clear(TxnId);
                Clear(JourLineDocNo);
                TxnId := NotTransferedLines.TxnId;
                if not IsNullGuid(TxnId) then begin
                    JourLineDocNo := NotTransferedLines.JournalDocNo;
                    CreateNewGenjournalLine(false, NotTransferedLines."Transaction Date", NotTransferedLines.Description, NotTransferedLines."External Doc no.", NotTransferedLines."Statement Amount", TxnId);
                    NotTransferedLines."Line Transfered" := true;
                    NotTransferedLines.JournalDocNo := JourLineDocNo;
                    // NotTransferedLines.JournalDocNo := GenJouLines."Document No.";
                    NotTransferedLines.JournalDocLineNo := GenJouLines."Line No.";
                    NotTransferedLines.JournalLineAccType := GenJouLines."Account Type";
                    NotTransferedLines.JournalLineAccNo := GenJouLines."Account No.";
                    NotTransferedLines.JournalAccName := GetJournaAccountName(GenJouLines."Account Type", GenJouLines."Account No.");
                    NotTransferedLines.Modify();
                    JourLineDocNo := NotTransferedLines.JournalDocNo;
                end;

                Clear(BalanceLines);
                BalanceLines.SetRange(IsBalanceLine, true);
                BalanceLines.SetRange(LinePosted, false);
                BalanceLines.SetRange("Line Transfered", false);
                BalanceLines.SetRange(Reversed, false);
                BalanceLines.SetRange("External Doc no.", NotTransferedLines."External Doc no.");
                if BalanceLines.FindFirst() then begin
                    TxnId := BalanceLines.TxnId;
                    CreateNewGenjournalLine(true, BalanceLines."Transaction Date", BalanceLines.Description, BalanceLines."External Doc no.", BalanceLines."Statement Amount", TxnId);
                    BalanceLines."Line Transfered" := true;
                    BalanceLines.JournalDocNo := JourLineDocNo;
                    // BalanceLines.JournalDocNo := GenJouLines."Document No.";
                    BalanceLines.JournalDocLineNo := GenJouLines."Line No.";
                    BalanceLines.JournalLineAccType := GenJouLines."Account Type";
                    BalanceLines.JournalLineAccNo := GenJouLines."Account No.";
                    BalanceLines.JournalAccName := GetJournaAccountName(GenJouLines."Account Type", GenJouLines."Account No.");
                    BalanceLines.Modify();
                end;
            until NotTransferedLines.Next() = 0;
    end;

    //used to create balance lines from buffer
    local procedure TransferBalLineToGeneralJournal()
    var
        NotTransferedLines: Record "Bank Statement Lines Buffer";
        BalanceLines: Record "Bank Statement Lines Buffer";
    begin
        Clear(NotTransferedLines);
        NotTransferedLines.SetRange(IsBalanceLine, true);
        NotTransferedLines.SetRange(LinePosted, false);
        NotTransferedLines.SetRange("Line Transfered", false);
        NotTransferedLines.SetRange(Reversed, false);
        NotTransferedLines.SetFilter("Bank Account No.", BankNo);
        NotTransferedLines.SetFilter("Statement No.", StatementNo);
        if NotTransferedLines.FindSet() then
            repeat
                if not SelectedRecord.Contains(NotTransferedLines."External Doc no.") then
                    continue;
                Clear(TxnId);
                TxnId := NotTransferedLines.TxnId;
                JourLineDocNo := NotTransferedLines.JournalDocNo;
                if not IsNullGuid(TxnId) then begin
                    CreateNewGenjournalLine(true, NotTransferedLines."Transaction Date", NotTransferedLines.Description, NotTransferedLines."External Doc no.", (NotTransferedLines."Statement Amount"), TxnId);
                    NotTransferedLines."Line Transfered" := true;
                    NotTransferedLines.JournalDocNo := JourLineDocNo;
                    // NotTransferedLines.JournalDocNo := GenJouLines."Document No.";
                    NotTransferedLines.JournalDocLineNo := GenJouLines."Line No.";
                    NotTransferedLines.JournalLineAccType := GenJouLines."Account Type";
                    NotTransferedLines.JournalLineAccNo := GenJouLines."Account No.";
                    NotTransferedLines.JournalAccName := GetJournaAccountName(GenJouLines."Account Type", GenJouLines."Account No.");
                    NotTransferedLines.Modify();
                end;
            until NotTransferedLines.Next() = 0;
    end;

    var
        GenJouLines: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        BankImpSetup: Record "Bank Import Statement Setup";
        BankStatementLines: Record "Bank Acc. Reconciliation Line";
        BankStatementLinesBuffer: Record "Bank Statement Lines Buffer";
        GenBatch: Record "Gen. Journal Batch";
        NoSeriesMGT: Codeunit "No. Series";
        GeneralTemplate: Code[20];
        GeneralBatch: Code[20];
        BankNo: Code[20];
        Currency: Code[20];
        StatementNo: Code[20];
        JourLineDocNo: Code[20];
        LastUsedJourLineDocNo: Code[20];
        ListofBankStatementLines: List of [code[50]];
        SelectedRecord: List of [Code[35]];
        LastLineNo: Integer;
        LastEntryNO: Integer;
        TxnId: Guid;
        NeedNewJournalDocNo: Boolean;

    // Create record in Buffer table for actual line and balance line.
    local procedure TransferLinesToBuffer(IsBalanceLine: Boolean): Guid
    var
        EntryNo: Integer;
        StatementAmount: Decimal;
    begin
        Clear(StatementAmount);
        Clear(BankStatementLinesBuffer);

        BankStatementLinesBuffer.SetFilter("External Doc no.", BankStatementLines."External Doc no.");
        if IsBalanceLine then
            BankStatementLinesBuffer.SetFilter("Statement Amount", BankStatementLines."Statement Amount".ToText())
        else
            BankStatementLinesBuffer.SetFilter("Statement Amount", (BankStatementLines."Statement Amount" * -1).ToText());

        BankStatementLinesBuffer.SetRange(IsBalanceLine, IsBalanceLine);
        BankStatementLinesBuffer.SetRange("Transaction Date", BankStatementLines."Transaction Date");
        if not BankStatementLinesBuffer.FindFirst() then begin
            Clear(EntryNo);
            EntryNo := LastEntryNO + 1;
            BankStatementLinesBuffer.Init();
            BankStatementLinesBuffer.TransferFields(BankStatementLines, true);
            if IsBalanceLine then
                BankStatementLinesBuffer."Statement Amount" := BankStatementLines."Statement Amount"
            else
                BankStatementLinesBuffer."Statement Amount" := BankStatementLines."Statement Amount" * -1;
            BankStatementLinesBuffer.EntryNo := EntryNo;
            BankStatementLinesBuffer.TxnId := CreateGuid();
            BankStatementLinesBuffer.IsBalanceLine := IsBalanceLine;
            BankStatementLinesBuffer.Insert();
            LastEntryNO := EntryNo;
        end;
        exit(BankStatementLinesBuffer.TxnId);
    end;

    local procedure CreateNewGenjournalLine(IsBalanceLine: Boolean; PostingDate: Date; Description: Text[100]; ExtDocNo: Code[35]; StatementAmount: Decimal; LineTxnId: Guid)
    var
        LineNo: Integer;
    begin
        Clear(GenJouLines);
        GenJouLines.SetFilter(TxnId, LineTxnId);
        if GenJouLines.FindFirst() then begin
            JourLineDocNo := GenJouLines."Document No.";
            exit;
        end;

        if (not IsBalanceLine) and NeedNewJournalDocNo then
            GetNextNo();
        LineNo := LastLineNo + 10000;
        GenJouLines.Init();
        GenJouLines.Validate("Journal Template Name", GeneralTemplate);
        GenJouLines.Validate("Journal Batch Name", GeneralBatch);
        GenJouLines.Validate("Line No.", LineNo);
        GenJouLines.Validate("Posting Date", PostingDate);
        GenJouLines.Validate("Document Type", GenJouLines."Document Type"::" ");
        GenJouLines.Validate("Document No.", JourLineDocNo);
        GenJouLines.Validate(Description, Description);
        GenJouLines.Validate("External Document No.", ExtDocNo);

        if not IsBalanceLine then begin
            GenJouLines.Validate("Account Type", GenJouLines."Account Type"::"Bank Account");
            GenJouLines.Validate("Account No.", BankNo);
            GenJouLines.Validate("Currency Code", Currency);
            // GenJouLines.Validate(Amount, -1 * StatementAmount);
        end;
        // else
        GenJouLines.Validate(Amount, StatementAmount);

        GenJouLines.TxnId := TxnId;
        GenJouLines.Insert(true);
        JourLineDocNo := GenJouLines."Document No.";
        LastLineNo := LineNo;
    end;

    local procedure GetSetup(Rec: Record "Bank Acc. Reconciliation")
    begin
        Clear(GeneralBatch);
        Clear(GeneralTemplate);
        Clear(BankNo);
        Clear(Currency);
        Clear(StatementNo);

        BankImpSetup.Get();
        BankImpSetup.TestField("General Journal Template");
        GeneralTemplate := BankImpSetup."General Journal Template";
        BankNo := Rec."Bank Account No.";
        StatementNo := Rec."Statement No.";

        BankAccount.get(BankNo);
        BankAccount.TestField("General Batch");
        BankAccount.TestField("Currency Code");
        GeneralBatch := BankAccount."General Batch";
        Currency := BankAccount."Currency Code";
    end;


    local procedure GetLastLineNo()
    begin
        Clear(LastLineNo);
        Clear(LastEntryNO);
        Clear(GenJouLines);
        GenJouLines.SetFilter("Journal Template Name", GeneralTemplate);
        GenJouLines.SetFilter("Journal Batch Name", GeneralBatch);
        if GenJouLines.FindLast() then
            LastLineNo := GenJouLines."Line No."
        else
            LastLineNo := 0;

        BankStatementLinesBuffer.SetCurrentKey(EntryNo);
        if BankStatementLinesBuffer.FindLast() then
            LastEntryNO := BankStatementLinesBuffer.EntryNo
        else
            LastEntryNO := 0;
    end;

    // local procedure GetNextNo()
    // var
    //     NoSeries: Codeunit "No. Series";
    // begin
    //     if GenBatch.Get(GeneralTemplate, GeneralBatch) then begin
    //         GenBatch.TestField("No. Series");
    //         JourLineDocNo := NoSeriesMGT.GetNextNo(GenBatch."No. Series");
    //         //   FirstDocNo := NoSeries.PeekNextNo(GenJnlBatch."No. Series", "Posting Date");
    //     end;
    // end;

    local procedure GetLastUsedDocNo()
    var
        NoSeries: Codeunit "No. Series";
        GenJouLine: Record "Gen. Journal Line";
    begin
        Clear(GenJouLine);
        GenJouLine.SetFilter("Journal Template Name", GeneralTemplate);
        GenJouLine.SetFilter("Journal Batch Name", GeneralBatch);
        GenJouLine.SetCurrentKey("Document No.");
        if GenJouLine.FindLast() then
            LastUsedJourLineDocNo := GenJouLine."Document No."
        else begin
            if GenBatch.Get(GeneralTemplate, GeneralBatch) then begin
                GenBatch.TestField("No. Series");
                LastUsedJourLineDocNo := NoSeries.GetLastNoUsed(GenBatch."No. Series");
                //   FirstDocNo := NoSeries.PeekNextNo(GenJnlBatch."No. Series", "Posting Date");
            end;
        end;
    end;

    local procedure GetNextNo()
    begin
        if JourLineDocNo = '' then
            JourLineDocNo := IncStr(LastUsedJourLineDocNo)
        else
            JourLineDocNo := IncStr(JourLineDocNo);
    end;

    local procedure DeleteImportedLines()
    var
        DocNo: Code[50];
    begin
        if ListofBankStatementLines.Count > 0 then
            foreach DocNo in ListofBankStatementLines do begin
                Clear(BankStatementLines);
                BankStatementLines.SetFilter("External Doc no.", DocNo);
                if BankStatementLines.FindFirst() then
                    BankStatementLines.Delete();
            end;
    end;

    //Get Journal Account Name base on account type and account no
    procedure GetJournaAccountName(AcoountType: Enum "Gen. Journal Account Type"; AccountNo: Code[50]): Text[250]
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
        AccFieldRef: FieldRef;
        AccountName: Text[250];
    begin
        Clear(AccountName);
        if AccountNo = '' then
            exit(AccountName);

        case AcoountType of
            AcoountType::"Bank Account":
                RecRef.Open(Database::"Bank Account");
            AcoountType::"Allocation Account":
                RecRef.Open(Database::"Allocation Account");
            AcoountType::Customer:
                RecRef.Open(Database::Customer);
            AcoountType::Employee:
                RecRef.Open(Database::Employee);
            AcoountType::"Fixed Asset":
                RecRef.Open(Database::"Fixed Asset");
            AcoountType::"G/L Account":
                RecRef.Open(Database::"G/L Account");
            AcoountType::"IC Partner":
                RecRef.Open(Database::"IC Partner");
            AcoountType::Vendor:
                RecRef.Open(Database::Vendor);
        end;
        Clear(AccountName);
        FieldRef := RecRef.Field(1);
        AccFieldRef := RecRef.Field(2);

        if not RecRef.IsEmpty then begin
            FieldRef.Value := AccountNo;
            if RecRef.Find('=') then begin
                AccountName := AccFieldRef.Value;
            end;
        end;
        exit(AccountName);
    end;
}