
page 50123 "Transactions - Alaan"
{
    PageType = List;
    Caption = 'Transactions - Alaan';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Transactions - Alaan";
    CardPageId = "Transaction Card - Alaan";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PromotedActionCategories = 'New,Process,Nevigate,Alaan';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Transaction Id"; Rec.TransactionId)
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Id';
                    ToolTip = 'Specifies the unique identifier of the transaction.';
                    Visible = false;
                }
                field("Merchant Name"; Rec."Merchant Name")
                {
                    ApplicationArea = All;
                    Caption = 'Merchant Name';
                    ToolTip = 'Specifies the merchant associated with this transaction.';
                    DrillDown = true;
                    // DrillDownPageId = "Transaction Card - Alaan";

                    trigger OnDrillDown()
                    var
                        TxnCard: Page "Transaction Card - Alaan";
                    begin
                        TxnCard.SetRecord(Rec);
                        TxnCard.Run();
                    end;
                }
                field("Spender Name"; Rec."Spender Name")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Name';
                }
                field("Spender Email"; Rec."Spender Email")
                {
                    ApplicationArea = All;
                    Caption = 'Email';
                }
                field("Card No"; Rec."Card No")
                {
                    ApplicationArea = All;
                    Caption = 'Card No';
                }
                field("Billing Amount"; Rec."Billing Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Billing Amount';
                    ToolTip = 'Specifies the billing amount of the transaction.';
                }
                field("Billing Currency"; Rec."Billing Currency")
                {
                    ApplicationArea = All;
                    Caption = 'Billing Currency';
                    ToolTip = 'Specifies the currency used for billing.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Caption = 'VAT Amount';
                    ToolTip = 'Specifies the VAT amount applied to the transaction.';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Type';
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
                field("Payment Journal Terms"; Rec."Payment Journal Terms")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Admin Status"; Rec."Admin Status")
                {
                    ApplicationArea = All;
                    Caption = 'Admin Status';
                    ToolTip = 'Specifies the current status set by the administrator (Pending Review, Approved, Rejected).';
                }
                field("Txn Clearing Status"; Rec."Txn Clearing Status")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Clearing Status';
                    ToolTip = 'Specifies whether the transaction is Settled or Not Settled.';
                }
                field("Txn Clearing Date"; Rec."Txn Clearing Date")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Clearing Date';
                    ToolTip = 'Specifies the date when the transaction was cleared, if applicable.';
                    Visible = false;
                }
                field(Synced; Synced)
                {
                    Caption = 'Transaction Synced';
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    Caption = 'Journal Created';
                    ApplicationArea = All;

                }
                field(Posted; Posted)
                {
                    Caption = 'Journal Posted';
                    ApplicationArea = All;
                }
                field("Export Status"; Rec."Export Status")
                {
                    ApplicationArea = All;
                    Caption = 'Export Status';
                }
                field("Error message"; Rec."Error message")
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    Style = Unfavorable;
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
            action("Get Txn From Alaan")
            {
                ApplicationArea = All;
                Caption = 'Get Transaction From Alaan';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = report "Transaction MGT API";

            }

            action("Sync Txn")
            {
                ApplicationArea = All;
                Caption = 'Create Payment Journal Entry';
                Image = CreateLinesFromJob;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    SyncTxn: Codeunit "Sync Transactions Test";
                    Transaction: Record "Transactions - Alaan";
                begin
                    CurrPage.SetSelectionFilter(Transaction);
                    if Transaction.FindSet() then begin
                        repeat
                            SyncTxn.SyncTransaction(Transaction.TransactionId);
                        until Transaction.Next() = 0;
                    end;
                end;
            }
            action("Entry Log")
            {
                ApplicationArea = All;
                Caption = 'Journal Entry Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Txn Jur. - Alaan Logs";
                RunPageMode = View;
                RunPageLink = TxnId = field(TransactionId);
                RunPageView = sorting(EntryNo) order(descending);
            }
            action(DownloadReceipt)
            {
                ApplicationArea = All;
                Caption = 'Download Receipt';
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    IStream: InStream;
                    OStream: OutStream;
                    FileName: Text;
                begin
                    Clear(OStream);
                    Clear(IStream);
                    Rec.CalcFields(Receipt);
                    if not Rec.Receipt.HasValue then
                        Error('No receipt Attached');
                    Rec.Receipt.CreateInStream(IStream);
                    FileName := 'Receipt_' + Rec."Merchant Name" + '.png';
                    DownloadFromStream(IStream, '', '', '', FileName);
                end;
            }
            action("Sync Log")
            {
                ApplicationArea = All;
                Caption = 'Connection Log';
                Image = ChangeLog;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = page "Transaction - Alaan Logs";
                RunPageLink = TransactionId = field(TransactionId);
                RunPageView = sorting(EntryNo) order(descending);
                RunPageMode = View;
            }
            action("Export Txn")
            {
                ApplicationArea = All;
                Caption = 'Export Transaction to Alaan';
                Image = Export;
                Promoted = true;
                PromotedCategory = Category4;
                trigger OnAction()
                var
                    ExportTxn: Codeunit "Export Transactions";
                    selectedRec: Record "Transactions - Alaan";
                begin
                    //Code added on 10-4-26
                    //Code is added for multiple selection
                    CurrPage.SetSelectionFilter(selectedRec);
                    if SelectedRec.FindSet() then begin
                        repeat
                            ExportTxn.ExportTransaction(SelectedRec.TransactionId, false);
                        until SelectedRec.Next() = 0;
                    end;
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
    }

    var
        Synced: Boolean;
        Created: Boolean;
        Posted: Boolean;
        Error: Boolean;
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

        Clear(Synced);
        Clear(Created);
        Clear(Posted);
        Clear(Error);

        case Rec.SyncStatus of
            Rec.SyncStatus::Synced:
                begin
                    StyleExp := 'Ambiguous';
                    Synced := true;
                end;
            Rec.SyncStatus::Created:
                begin
                    StyleExp := 'StrongAccent';
                    Created := true;
                end;
            Rec.SyncStatus::Posted:
                begin
                    StyleExp := 'Favorable';
                    Posted := true;
                end;
        end;
    end;
}