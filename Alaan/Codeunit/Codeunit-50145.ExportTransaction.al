codeunit 50145 "Export Transactions"
{
    Permissions = tabledata "G/L Entry" = RIMD,
    tabledata "Bank Account Ledger Entry" = RIMD;
    /* UPDTAE LINE STATUS
        When Gen journal Lines are posted, it updates lines status on Transaction and Bank Statement buffer as posted
            1. Lines Posted from Payment Journal --> Updated on transaction lines
            2. Lines Posted from General journal --> Updated on Bank statement buffer lines
    */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnAfterPostGenJnlLine, '', false, false)]
    local procedure OnAfterPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; CommitIsSuppressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; IsPosted: Boolean; var PostingGenJournalLine: Record "Gen. Journal Line")
    var
        TxnHeaderID: Guid;
        TxnLineID: Guid;
        TransactionLine: Record "Transaction Line - Alaan";
        BankStatementLineBuffer: Record "Bank Statement Lines Buffer";
        Transactions: Record "Transactions - Alaan";
        GLEntry: Record "G/L Entry";
        bankLedger: Record "Bank Account Ledger Entry";
    begin
        //Update transaction lines
        if not CommitIsSuppressed and (not IsNullGuid(GenJournalLine.TxnId)) and (not IsNullGuid(GenJournalLine.TxnLineId)) then begin
            TxnHeaderID := GenJournalLine.TxnId;
            TxnLineID := GenJournalLine.TxnLineId;

            Clear(TransactionLine);
            if TransactionLine.Get(TxnHeaderID, TxnLineID) then begin
                TransactionLine.Status := TransactionLine.Status::Posted;
                TransactionLine.JournalLineDocNo := PostingGenJournalLine."Document No.";
                TransactionLine.Modify();
            end;
        end;

        //code added on 10-4-26
        if Transactions.Get(TxnHeaderID) then begin
            Transactions.JournalDocNo := PostingGenJournalLine."Document No.";
            Transactions.Modify();
        end;
        GLEntry.SetFilter("Document No.", PostingGenJournalLine."Document No.");
        if GLEntry.FindSet() then
            repeat
                GLEntry.Memo := PostingGenJournalLine.Memo;
                GLEntry.Modify();
            until GLEntry.Next() = 0;
        bankLedger.SetFilter("Document No.", PostingGenJournalLine."Document No.");
        if bankLedger.FindSet() then
            repeat
                bankLedger.Memo := PostingGenJournalLine.Memo;
                bankLedger.Modify();
            until bankLedger.Next() = 0;

        //****************************Mark as uncomment for bank import statement
        //Update Bank statement buffer lines
        if not CommitIsSuppressed and (not IsNullGuid(GenJournalLine.TxnId)) then begin
            TxnHeaderID := GenJournalLine.TxnId;

            Clear(BankStatementLineBuffer);
            BankStatementLineBuffer.SetFilter(TxnId, TxnHeaderID);
            if BankStatementLineBuffer.FindFirst() then begin
                BankStatementLineBuffer.LinePosted := true;
                BankStatementLineBuffer."Line Transfered" := true;
                // BankStatementLineBuffer.JournalDocNo := GenJournalLine."Document No.";
                BankStatementLineBuffer.Modify();
            end;
        end;
    end;

    trigger OnRun()
    begin
        ExportTransaction('', true);
    end;

    procedure ExportTransaction(TxnID: Guid; ExportAll: Boolean)
    begin
        Clear(Transaction);
        Transaction.SetRange("Export Status", Transaction."Export Status"::READY_TO_EXPORT);
        Transaction.SetRange(SyncStatus, Transaction.SyncStatus::Posted);
        if not ExportAll and not IsNullGuid(TxnID) then
            Transaction.SetFilter(TransactionId, TxnID);
        if not Transaction.FindFirst() then
            exit;

        repeat
            InitSyncLog();
            //check lines are posted or not
            TransactionLine.Reset();
            TransactionLine.SetFilter("Header ID", TxnID);
            TransactionLine.SetFilter(Status, '<>%1', TransactionLine.Status::Posted);
            if TransactionLine.FindFirst() then begin
                ErrorMessage := 'Some Transaction Lines are not posted Yet';
                if GuiAllowed then Message(ErrorMessage);
            end
            else begin
                if ExportTransaction(Transaction.TransactionId) then begin
                    Transaction."Export Status" := ExportStatus;
                    IsError := false;
                    if GuiAllowed then Message('Transaction has been Exported');
                end
                else begin
                    Transaction."Export Status" := Transaction."Export Status"::READY_TO_EXPORT;
                    ErrorMessage := GetLastErrorText;
                    IsError := true;
                    if GuiAllowed then Message(StrSubstNo('ERROR : %1', ErrorMessage));
                end;
                Transaction.Modify();
            end;
            UpdateSyncLog();
        until Transaction.Next() = 0;

    end;

    [TryFunction]
    local procedure ExportTransaction(TxnID: Guid)
    var
        JObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        TxnIDTXT: Text;
        BodyTXT: Text;
        URL: Text;
        Response: JsonObject;
        ErrorMSG: Text;
        IsSuccess: Boolean;
    begin
        Clear(JObject);
        Clear(BodyTXT);
        Clear(JArray);
        Clear(JToken);
        Clear(ErrorMSG);
        /*
            // Clear(TransactionLine);
            // TransactionLine.SetFilter("Header ID", TxnID);
            // TransactionLine.SetFilter(Status, '<>%1', TransactionLine.Status::Posted);
            // if TransactionLine.FindFirst() then
            //     // if TransactionLine."Error Message" = '' then
            //         Error('Some Transaction Lines are not posted Yet');
        */
        URL := StrSubstNo('%1/sync', AlaanAPIMGT.GetBaseURL());
        TxnIDTXT := DelChr(TxnID.ToText, '=', '{}').ToLower();
        BodyTXT := CreateURLBody(TxnIDTXT);

        if BodyTXT = '' then
            Error('There are some error that needs to resolve');

        Clear(Response);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyTXT, 'POST');
        if Response.Get('status', JToken) then
            if not JToken.AsValue().AsBoolean() then
                if Response.Get('message', JToken) then
                    Error(JToken.AsValue().AsText());
    end;

    local procedure InitSyncLog()
    var
        TransactionLog_: Record "Transaction - Alaan Logs";
    begin
        TransactionLog.Init();
        TransactionLog_.Reset();
        if TransactionLog_.FindLast() then
            TransactionLog.EntryNo := TransactionLog_.EntryNo + 1;
        TransactionLog."Sync Date & Time" := CurrentDateTime;
        TransactionLog.SyncType := TransactionLog.SyncType::"To Alaan";
        TransactionLog.ActionType := TransactionLog.ActionType::Export;
        TransactionLog.TransactionId := Transaction.TransactionId;
        TransactionLog.Insert();
    end;

    local procedure UpdateSyncLog()
    begin
        TransactionLog."Export Status" := ExportStatus;
        TransactionLog.IsError := IsError;
        TransactionLog."Error Message" := ErrorMessage;
        TransactionLog.Modify();
    end;

    //Code added on 24-4-26 to correct the API body
    local procedure CreateURLBody(TxnIDTXT: Text): Text
    var
        JObject, JsonObject_ : JsonObject;
        JArray, JArray_ : JsonArray;
        JToken: JsonToken;
        BodyTXT: Text;
        ErrorMSG: Text;
        IsSuccess: Boolean;
    begin

        Clear(ExportStatus);
        IsSuccess := (Transaction."Error Message" = '') and (Transaction.SyncStatus = Transaction.SyncStatus::Posted);

        if IsSuccess then begin
            JObject.Add('id', TxnIDTXT);
            JArray.Add(JObject);
            Clear(JObject);
            JObject.Add('success_sync', JArray);
            JsonObject_.Add('id', TxnIDTXT);
            JsonObject_.Add('error_message', 'Error');
            JArray_.Add(JsonObject_);
            JObject.Add('failure_sync', JArray_);
            JObject.Add('sync_type', 'Transaction');
            JObject.WriteTo(BodyTXT);
            ExportStatus := ExportStatus::EXPORTED;
            exit(BodyTXT);
        end;

        // if Transaction.SyncStatus <> Transaction.SyncStatus::Posted then begin
        //     //check lines
        //     if (Transaction."Error Message" = '') then begin
        //         Clear(TransactionLine);
        //         TransactionLine.SetFilter("Header ID", Transaction.TransactionId);
        //         TransactionLine.SetFilter("Error Message", '<>%1', ErrorMSG);
        //         if TransactionLine.FindSet() then
        //             repeat
        //                 ErrorMSG += TransactionLine."Error Message" + ' ';
        //             until TransactionLine.Next() = 0;
        //     end
        //     else
        //         ErrorMSG := Transaction."Error Message";

        //     JObject.Add('id', TxnIDTXT);
        //     JObject.Add('error_message', Transaction."Error Message");
        //     JArray.Add(JObject);
        //     Clear(JObject);
        //     JObject.Add('failure_sync', JArray);
        //     JObject.Add('sync_type', 'Transaction');
        //     JObject.WriteTo(BodyTXT);
        //     ExportStatus := ExportStatus::FAILED;
        //     exit(BodyTXT);
        // end;
    end;

    var
        AlaanAPIMGT: Codeunit "Alaan API MGT";
        TransactionLog: Record "Transaction - Alaan Logs";
        Transaction: Record "Transactions - Alaan";
        TransactionLine: Record "Transaction Line - Alaan";
        IsError: Boolean;
        ErrorMessage: Text;
        ExportStatus: option PENDING,EXPORTED,FAILED,SYNC_IN_PROGRESS,READY_TO_EXPORT;
}