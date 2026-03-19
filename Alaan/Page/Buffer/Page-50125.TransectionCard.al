page 50125 "Transaction Card - Alaan"
{
    PageType = Card;
    Caption = 'Transaction Card - Alaan';
    SourceTable = "Transactions - Alaan";
    DataCaptionFields = "Merchant Name";
    UsageCategory = None;
    // PromotedActionCategories = 'New,Process,Report,Transaction,Logs & History,Documents';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                ShowCaption = true;
                field("Transaction Id"; Rec.TransactionId)
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Id';
                    ToolTip = 'Specifies the unique identifier of the transaction.';
                    Importance = Promoted;
                }
                field("Merchant Name"; Rec."Merchant Name")
                {
                    ApplicationArea = All;
                    Caption = 'Merchant Name';
                    ToolTip = 'Specifies the name of the merchant where the transaction occurred.';
                    Importance = Promoted;
                }
                field("Billing Amount"; Rec."Billing Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Billing Amount';
                    ToolTip = 'Specifies the billing amount of the transaction.';
                    Importance = Promoted;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Caption = 'VAT Amount';
                    ToolTip = 'Specifies the VAT amount applied to the transaction.';
                }
                field("Reference Number"; Rec."Reference Number")
                {
                    ApplicationArea = All;
                    Caption = 'Reference Number';
                    ToolTip = 'Specifies External doc number.';
                }
                field("Cashback Amount"; Rec."Cashback Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Cashback Amount';
                    ToolTip = 'Specifies the cashback amount received for the transaction.';
                }
                field("Billing Currency"; Rec."Billing Currency")
                {
                    ApplicationArea = All;
                    Caption = 'Billing Currency';
                    ToolTip = 'Specifies the billing currency used for this transaction.';
                    Importance = Promoted;
                }
                field("Merchant Id"; Rec."Merchant Id")
                {
                    ApplicationArea = All;
                    Caption = 'Merchant Id';
                    ToolTip = 'Specifies the identifier of the merchant where the transaction occurred.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Type';
                    Style = Favorable;
                }
                field(SyncStatus; Rec.SyncStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Status';
                    StyleExpr = StyleExp;
                }
                field(JournalDocNo; Rec.JournalDocNo)
                {
                    ApplicationArea = All;
                    Caption = 'Journal Document No';
                }

                field("Admin Status"; Rec."Admin Status")
                {
                    ApplicationArea = All;
                    Caption = 'Admin Status';
                    ToolTip = 'Specifies the current status set by the administrator (Pending Review, Approved, Rejected).';
                }
                field("Export Status"; Rec."Export Status")
                {
                    ApplicationArea = All;
                    Caption = 'Export Status';
                    ToolTip = 'Specifies whether the transaction has been exported.';

                }
                field("Settlement Status"; Rec."Settlement Status")
                {
                    ApplicationArea = All;
                    Caption = 'Settlement Status';
                    ToolTip = 'Specifies whether the transaction is settled or not.';
                }
                field("Error message"; Rec."Error message")
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    Style = Unfavorable;
                }

            }
            part("Transaction Line - Alaan"; "Transaction Line - Alaan")
            {
                SubPageLink = "Header ID" = field(TransactionId);
                ApplicationArea = All;
                // Editable = false;
                Caption = 'Transaction Lines';
            }
            group("Transaction Details")
            {
                Caption = 'Transaction Details';
                ShowCaption = true;
                field("Txn Type"; Rec."Txn Type")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction';
                    ToolTip = 'Specifies whether the transaction is a Debit or Credit.';
                    Importance = Promoted;
                }
                field("Txn Event Type"; Rec."Txn Event Type")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Event Type';
                    ToolTip = 'Specifies the event type of the transaction, such as Purchase or Refund.';
                }
                field("Txn Clearing Date"; Rec."Txn Clearing Date")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Clearing Date';
                    ToolTip = 'Specifies the date when the transaction was cleared, if applicable.';
                }
                field("Txn Time"; Rec."Txn Time")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Time';
                    ToolTip = 'Specifies the timestamp when the transaction occurred.';
                    Importance = Promoted;
                }
                field("Txn Clearing Status"; Rec."Txn Clearing Status")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Clearing Status';
                    ToolTip = 'Specifies the settlement clearing status (Settled or Not Settled).';
                }
                field("Transaction Amount"; Rec."Transaction Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Amount';
                    ToolTip = 'Specifies the actual amount of the transaction.';
                }
                field("Transaction Currency"; Rec."Transaction Currency")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Currency';
                    ToolTip = 'Specifies the currency in which the transaction was made.';
                }
                field("Partner Txn Id"; Rec."Partner Txn Id")
                {
                    ApplicationArea = All;
                    Caption = 'Partner Transaction Id';
                    ToolTip = 'Specifies the partner system transaction identifier.';
                }
                field("Network Txn Id"; Rec."Network Txn Id")
                {
                    ApplicationArea = All;
                    Caption = 'Network Transaction Id';
                    ToolTip = 'Specifies the network transaction identifier.';
                }
            }

            group("Vendor")
            {
                Caption = 'Vendor Details';
                ShowCaption = true;
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No';
                    TableRelation = Vendor."No.";
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Name';
                }
                field("Vendor Currency"; Rec."Vendor Currency")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Currency';
                    TableRelation = Currency.Code;
                }
                field(IsForeignVendor; Rec.IsForeignVendor)
                {
                    Caption = 'Is Forign Vendor';
                    ApplicationArea = All;
                }
            }
            group("Spender Details")
            {
                Caption = 'Speder Details';
                ShowCaption = true;
                field("Spender Id"; Rec."Spender Id")
                {
                    ApplicationArea = All;
                    Caption = 'Spender Id';
                    ToolTip = 'Specifies the unique identifier of the spender.';
                }
                field("Spender Name"; Rec."Spender Name")
                {
                    ApplicationArea = All;
                    Caption = 'Spender Name';
                    ToolTip = 'Specifies the name of the spender associated with the transaction.';
                    Importance = Promoted;
                }
                field("Spender Email"; Rec."Spender Email")
                {
                    ApplicationArea = All;
                    Caption = 'Spender Email';
                    ToolTip = 'Specifies the email address of the spender.';
                    Importance = Promoted;
                }
                field("Spender Comments"; Rec."Spender Comments")
                {
                    ApplicationArea = All;
                    Caption = 'Spender Comments';
                    ToolTip = 'Specifies any comments added by the spender.';
                }
            }

            group("Card Details")
            {
                Caption = 'Card Details';
                ShowCaption = true;
                field("Card Id"; Rec."Card Id")
                {
                    ApplicationArea = All;
                    Caption = 'Card Id';
                    ToolTip = 'Specifies the identifier of the card used for the transaction.';
                }
                field("Card No"; Rec."Card No")
                {
                    ApplicationArea = All;
                    Caption = 'Card Number';
                    ToolTip = 'Specifies the masked number of the card used for the transaction.';
                    Importance = Promoted;
                }
                field("CorpCard Config Id"; Rec."CorpCard Config Id")
                {
                    ApplicationArea = All;
                    Caption = 'Corporate Card Config Id';
                    ToolTip = 'Specifies the configuration identifier of the corporate card.';
                }
            }
        }
        area(FactBoxes)
        {
            part("Receipt Details"; "Receipt Factbox")
            {
                ApplicationArea = All;
                SubPageLink = TransactionId = field(TransactionId);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // ===== Transaction Actions =====
            action(PMT_Entry)
            {
                ApplicationArea = All;
                Caption = 'Create Payment Journal Entry';
                Image = CreateLinesFromJob;
                ToolTip = 'Sync the selected transaction and create a corresponding payment journal entry.';

                trigger OnAction()
                var
                    SyncTxn: Codeunit "Sync Transactions Test";
                begin
                    SyncTxn.SyncTransaction(Rec.TransactionId);
                    CurrPage.Update();
                end;
            }

            action(ResolveERROR)
            {
                ApplicationArea = All;
                Caption = 'Resolve Error';
                Image = Registered;
                ToolTip = 'Resolve processing errors for this transaction.';
                trigger OnAction()
                var
                    TxnLine: Record "Transaction Line - Alaan";
                begin
                    Clear(Rec."Error Message");
                    TxnLine.SetFilter("Header ID", Rec.TransactionId);
                    if TxnLine.FindSet() then
                        TxnLine.ModifyAll("Error Message", '');
                end;
            }

            action(SyncTxn)
            {
                ApplicationArea = All;
                Caption = 'Sync Transaction';
                Image = Refresh;
                trigger OnAction()
                var
                    AlaanSyncTxn: Report "Transaction MGT API";
                    receipt: Boolean;
                begin
                    Clear(receipt);
                    if Confirm('Do you Want to sync Receipt as well?') then
                        receipt := true;

                    AlaanSyncTxn.GetParameter(Rec.TransactionId, receipt);
                    AlaanSyncTxn.UseRequestPage(false);
                    AlaanSyncTxn.Run();
                end;
            }
            action(ExportTxn)
            {
                ApplicationArea = All;
                Caption = 'Export Transaction from Alaan';
                Image = Export;
                trigger OnAction()
                var
                    ExportTxn: Codeunit "Export Transactions";
                begin
                    ExportTxn.ExportTransaction(Rec.TransactionId, false);
                end;
            }
            // ===== Log & Tracking Actions =====
            action(PMT_Entry_Log)
            {
                ApplicationArea = All;
                Caption = 'Payment Journal Log';
                Image = Log;
                ToolTip = 'View payment journal log entries created for this transaction.';
                RunObject = page "Txn Jur. - Alaan Logs";
                RunPageMode = View;
                RunPageLink = TxnId = field(TransactionId);
                RunPageView = sorting(EntryNo) order(descending);
            }
            action(Alaan_Sync_Log)
            {
                ApplicationArea = All;
                Caption = 'Connection Log';
                Image = ChangeLog;
                RunObject = page "Transaction - Alaan Logs";
                RunPageLink = TransactionId = field(TransactionId);
                RunPageView = sorting(EntryNo) order(descending);
                RunPageMode = View;
            }

            // ===== Document Actions =====
            action(DownloadReceipt)
            {
                ApplicationArea = All;
                Caption = 'Download Receipt';
                Image = Document;
                ToolTip = 'Download the attached receipt file for this transaction.';

                trigger OnAction()
                var
                    IStream: InStream;
                    FileName: Text;
                begin
                    Rec.CalcFields(Receipt);
                    if not Rec.Receipt.HasValue then
                        Error('No receipt attached.');

                    Rec.Receipt.CreateInStream(IStream);
                    FileName := StrSubstNo('Receipt_%1.pdf', Rec."Merchant Name");
                    DownloadFromStream(IStream, '', '', '', FileName);
                end;
            }
        }

        area(Navigation)
        {
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find Entries...';
                Image = Navigate;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'View ledger and document entries linked to this transaction.';

                trigger OnAction()
                var
                    NavigatePage: Page Navigate;
                begin
                    NavigatePage.SetDoc(Rec."Txn Clearing Date".Date, Rec.JournalDocNo);
                    NavigatePage.SetRec(Rec);
                    NavigatePage.Run();
                end;
            }
        }

        // ===== Promoted Ribbon Setup (ActionRefs) =====
        area(Promoted)
        {
            group(Transaction)
            {
                Caption = 'Transaction';
                actionref("Sync Txn"; SyncTxn) { }
                actionref("Payment Entry"; PMT_Entry) { }
                actionref("Resolve Error"; ResolveERROR) { }
                actionref("Export Txn"; ExportTxn) { }
            }

            group("Logs & History")
            {
                Caption = 'Logs & History';
                actionref(PMTEntryLog; PMT_Entry_Log) { }
                actionref("Alaan Entry Log"; Alaan_Sync_Log) { }
            }

            group(Documents)
            {
                Caption = 'Documents';
                actionref(Ref_DownloadReceipt; DownloadReceipt) { }
                actionref("Ref &Navigate"; "&Navigate") { }
            }
        }
    }

    var
        StyleExp: Text;

    trigger OnAfterGetRecord()
    var
        TLine: Record "Transaction Line - Alaan";
    begin
        TLine.SetFilter("Header ID", Rec.TransactionId);
        TLine.SetRange(Status, TLine.Status::Posted);
        if TLine.FindSet() then
            Rec.SyncStatus := Rec.SyncStatus::Posted;
        Rec.Modify();
        case Rec.SyncStatus of
            Rec.SyncStatus::Synced:
                StyleExp := 'Ambiguous';
            Rec.SyncStatus::Created:
                StyleExp := 'StrongAccent';
            Rec.SyncStatus::Posted:
                StyleExp := 'Favorable';
        end;
    end;

}