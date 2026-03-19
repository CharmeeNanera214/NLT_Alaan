page 50112 "Bank Statement Import"
{
    Caption = 'Bank Statement Import';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "Bank Acc. Reconciliation";
    InsertAllowed = true;
    DeleteAllowed = true;
    RefreshOnActivate = true;
    ModifyAllowed = true;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = All;
                }
                field("Statement No."; Rec."Statement No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Bank Statement Lines")
            {
                part(StmtLine; "Bank Acc. Reconciliation Lines")
                {
                    ApplicationArea = All;
                    SubPageLink = "Bank Account No." = field("Bank Account No."),
                                  "Statement No." = field("Statement No.");
                    Editable = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("Ba&nk")
            {
                Caption = 'Ba&nk';
                action(ImportBankStatement)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Bank Statement';
                    Image = Import;
                    ToolTip = 'Import electronic bank statements from your bank to populate with data about actual bank transactions.';

                    trigger OnAction()
                    begin
                        CurrPage.Update();
                        Rec.ImportBankStatement();
                        CheckStatementDate();
                        RecallEmptyListNotification();
                    end;
                }
                action(TransferLines)
                {
                    ApplicationArea = All;
                    Caption = 'Transfer Lines';
                    Image = TransferToGeneralJournal;
                    trigger OnAction()
                    var
                        BankImpMGT: Codeunit "Bank Import Statement MGT";
                        BankLines: Page "Bank Acc. Reconciliation Lines";
                        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
                        TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary;
                        Filter: Text;
                    begin
                        CurrPage.StmtLine.Page.GetSelectedRecords(TempBankAccReconciliationLine);
                        // if TempBankAccReconciliationLine.IsEmpty() then begin
                        //     BankImpMGT.TransferLinesToGeneralJournal(Rec);
                        //     exit;
                        // end;

                        if TempBankAccReconciliationLine.FindSet() then begin
                            repeat
                                Clear(BankAccReconciliationLine);
                                if BankAccReconciliationLine.Get(TempBankAccReconciliationLine."Statement Type",
                                                                TempBankAccReconciliationLine."Bank Account No.",
                                                                TempBankAccReconciliationLine."Statement No.",
                                                                TempBankAccReconciliationLine."Statement Line No.") then
                                    BankImpMGT.TransferLinesToGeneralJournal(Rec, BankAccReconciliationLine);
                                BankAccReconciliationLine.Delete();
                            until TempBankAccReconciliationLine.Next() = 0;
                            Message('Bank statement lines are transferd successfully');
                        end;
                    end;
                }
                action(GeneralJournal)
                {
                    ApplicationArea = All;
                    Image = Journal;
                    Caption = 'Open General Journal';
                    RunObject = page "General Journal";
                }
                // action(BankStatementLinesBuffer)
                // {
                //     ApplicationArea = All;
                //     Image = BankAccountStatement;
                //     Caption = 'Bank Staement Lines Buffer';
                //     // RunObject = page "Bank Statement Lines Buffers";

                //     trigger OnAction()
                //     var
                //         Page: page "Bank Statement Lines Buffers";
                //     begin
                //         Page.SetRecord(Rec);
                //         Page.Run();
                //     end;

                // }
                action(BankStatementLinesBuffer)
                {
                    ApplicationArea = All;
                    Image = BankAccountStatement;
                    Caption = 'Bank Statement Lines Buffer';
                    // RunObject = page "Bank Statement Lines Buffers";

                    trigger OnAction()
                    var
                        BufferLines: page "Bank Statement Buffer Lines";
                        BufferLinesRec: Record "Bank Statement Lines Buffer";
                    begin
                        BufferLines.SetBankStatements(Rec."Bank Account No.", Rec."Statement No.");
                        BufferLinesRec.SetFilter("Bank Account No.", Rec."Bank Account No.");
                        BufferLinesRec.SetFilter("Statement No.", Rec."Statement No.");
                        BufferLines.SetTableView(BufferLinesRec);
                        BufferLines.Run();
                    end;

                }
            }
        }

    }

    var
        StatementDateEmptyMsg: Label 'The bank account reconciliation does not have a statement date. %1 is the latest date on a line. Do you want to use that date for the statement?', Comment = '%1 - statement date';
        ImportedLinesAfterStatementDateMsg: Label 'There are lines on the imported bank statement with dates that are after the statement date.';
        ListofBankStatementLines: List of [code[50]];

    local procedure CheckStatementDate()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SetFilter("Bank Account No.", Rec."Bank Account No.");
        BankAccReconciliationLine.SetFilter("Statement No.", Rec."Statement No.");
        BankAccReconciliationLine.SetCurrentKey("Transaction Date");
        BankAccReconciliationLine.Ascending := false;
        if BankAccReconciliationLine.FindFirst() then begin
            BankAccReconciliation.GetBySystemId(Rec.SystemId);
            if BankAccReconciliation."Statement Date" = 0D then begin
                if Confirm(StrSubstNo(StatementDateEmptyMsg, Format(BankAccReconciliationLine."Transaction Date"))) then begin
                    Rec."Statement Date" := BankAccReconciliationLine."Transaction Date";
                    Rec.Modify();
                end;
            end else
                if BankAccReconciliation."Statement Date" < BankAccReconciliationLine."Transaction Date" then
                    Message(ImportedLinesAfterStatementDateMsg);
            // CurrPage.ApplyBankLedgerEntries.Page.SetBankRecDateFilter(BankAccReconciliation.MatchCandidateFilterDate());
        end;
    end;

    local procedure RecallEmptyListNotification()
    var
        ImportBankStatementNotification: Notification;
    begin
        ImportBankStatementNotification.Id := GetImportBankStatementNotificatoinId();
        if ImportBankStatementNotification.Recall() then;
    end;

    local procedure GetImportBankStatementNotificatoinId(): Guid
    begin
        exit('aa54bf06-b8b9-420d-a4a8-1f55a3da3e2a');
    end;


    // local procedure DeleteImportedLines()
    // var
    //     DocNo: Code[50];
    // begin
    //     if ListofBankStatementLines.Count > 0 then
    //         foreach DocNo in ListofBankStatementLines do begin
    //             Clear(BankStatementLines);
    //             BankStatementLines.SetFilter("External Doc no.", DocNo);
    //             if BankStatementLines.FindFirst() then
    //                 BankStatementLines.Delete();
    //         end;
    // end;
}