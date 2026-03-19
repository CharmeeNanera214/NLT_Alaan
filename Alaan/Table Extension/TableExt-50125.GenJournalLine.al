tableextension 50125 "Gen Jur Line EXT" extends "Gen. Journal Line"
{
    fields
    {
        field(50100; TxnId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Id';
        }
        field(50101; TxnLineId; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Id';
        }
    }
    //****************************Mark as uncomment for bank import statement
    trigger OnAfterModify()
    var
        BankStatementBuffer: Record "Bank Statement Lines Buffer";
        BankMGT: Codeunit "Bank Import Statement MGT";
    begin
        Clear(BankStatementBuffer);
        if (not IsNullGuid(Rec.TxnId)) and IsNullGuid(Rec.TxnLineId) then begin
            BankStatementBuffer.SetFilter(TxnId, Rec.TxnId);
            if BankStatementBuffer.FindFirst() then begin
                BankStatementBuffer.JournalLineAccNo := "Account No.";
                BankStatementBuffer.JournalLineAccType := "Account Type";
                BankStatementBuffer.Description := Description;
                BankStatementBuffer.JournalDocNo := "Document No.";
                BankStatementBuffer."Statement Amount" := Amount;
                BankStatementBuffer.JournalAccName := BankMGT.GetJournaAccountName("Account Type", "Account No.");
                BankStatementBuffer.Modify();
            end;
        end;
    end;


    trigger OnAfterDelete()
    var
        TransactionLine: Record "Transaction Line - Alaan";
        Transaction: Record "Transactions - Alaan";
        BankStatementBuffer: Record "Bank Statement Lines Buffer";
    begin
        if not (IsNullGuid(Rec.TxnId) or IsNullGuid(Rec.TxnLineId)) then
            if TransactionLine.Get(Rec.TxnId, Rec.TxnLineId) then
                if TransactionLine.Status <> TransactionLine.Status::Posted then begin
                    TransactionLine.Status := TransactionLine.Status::Synced;
                    TransactionLine.Modify();

                    Transaction.Get(TransactionLine."Header ID");
                    if not (Transaction.SyncStatus in [Transaction.SyncStatus::Posted, Transaction.SyncStatus::Synced]) then begin
                        Transaction.SyncStatus := Transaction.SyncStatus::Synced;
                        Transaction.Modify();
                    end;
                end;


        //****************************Mark as uncomment for bank import statement
        //delete or mark bank statement buffer line
        Clear(BankStatementBuffer);
        if (not IsNullGuid(Rec.TxnId)) and IsNullGuid(Rec.TxnLineId) then begin
            BankStatementBuffer.SetFilter(TxnId, Rec.TxnId);
            if BankStatementBuffer.FindFirst() then begin
                if not BankStatementBuffer.LinePosted then
                    BankStatementBuffer."Line Transfered" := false;
                // if BankStatementBuffer.IsBalanceLine then
                //     BankStatementBuffer.Delete()
                // else
                BankStatementBuffer.Modify();
            end;
        end;
    end;
}