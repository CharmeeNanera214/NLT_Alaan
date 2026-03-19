page 50126 "Transaction Line - Alaan"
{
    PageType = ListPart;
    Caption = 'Transaction Line - Alaan';
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Transaction Line - Alaan";
    Editable = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(TransactionLines)
            {

                Caption = 'Transaction Lines';
                field("Header ID"; Rec."Header ID")
                {
                    ApplicationArea = All;
                    Caption = 'Header';
                    Visible = false;
                }
                field("Line ID"; Rec."Line ID")
                {
                    ApplicationArea = All;
                    Caption = 'Line';
                    Visible = false;
                }
                field(LineType; Rec.LineType)
                {
                    ApplicationArea = All;
                    Caption = 'Line Type';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Style = Favorable;
                }
                field(JournalLineDocNo; Rec.JournalLineDocNo)
                {
                    ApplicationArea = All;
                    Caption = 'Journal Line Document No';
                }
                field(JournalLineLineNo; Rec.JournalLineLineNo)
                {
                    ApplicationArea = All;
                    Caption = 'Journal Line Line No';
                }

                field("Tag Group Item ID"; Rec."Tag Group Item ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Expense Category ID"; Rec."Expense Category ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Expense Category Name"; Rec."Expense Category Name")
                {
                    ApplicationArea = All;
                    Caption = 'Expense Category Name';
                    ToolTip = 'Specifies the identifier of the expense category.';
                    TableRelation = "Expense Categories"."Expense category Name";
                    Editable = false;
                }
                field("Account Details GL Account"; Rec."Account Details GL Account")
                {
                    ApplicationArea = All;
                    Caption = 'Account ';
                    ToolTip = 'Specifies GL Account.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    ToolTip = 'Specifies the amount of the transaction line.';
                }
                field("Amount (FCY)"; Rec."Amount (FCY)")
                {
                    ApplicationArea = All;
                    Caption = 'Amount (FYC)';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Caption = 'VAT Amount';
                    ToolTip = 'Specifies the VAT amount applied to the line.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    Style = Unfavorable;
                }

                field("Tax Rate"; Rec."Tax Rate")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Rate';
                    ToolTip = 'Specifies the tax rate applied to the line.';
                }
                field("Partner Expense Account Name"; Rec."Partner Expense Account Name")
                {
                    ApplicationArea = All;
                    Caption = 'Partner Expense Account Name';
                    ToolTip = 'Specifies the partner’s expense account name associated with this line.';
                    Visible = false;
                }
                field("Partner Tax code ID"; Rec."Partner Tax code ID")
                {
                    ApplicationArea = All;
                    Caption = 'Partner Tax Code ID';
                    ToolTip = 'Specifies the partner’s tax code identifier.';
                    Visible = false;
                }

                field("Tax Code"; Rec."Tax Code")
                {
                    ApplicationArea = All;
                    Caption = 'Tax Code';
                    ToolTip = 'Specifies the tax code for the expense line.';
                    TableRelation = "VAT Posting Setup"."Alaan Tax Code";
                }

            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(syncLog)
            {
                ApplicationArea = All;
                Image = ChangeLog;
                Caption = 'Connection Log';
                RunObject = page "Transaction Line - Alaan Logs";
                RunPageLink = "Line ID" = field("Line ID");
                RunPageView = sorting(EntryNo) order(descending);
                RunPageMode = View;
            }
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                ShortCutKey = 'Ctrl+Alt+Q';
                AboutTitle = 'Get detailed posting details';
                AboutText = 'Here, you can look up the ledger entries that were created when this invoice was posted, as well as any related documents.';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';

                trigger OnAction()
                var
                    NavigatePage: Page Navigate;
                    Transaction: Record "Transactions - Alaan";
                begin
                    NavigatePage.SetDoc(GetTxnClearingDate(Rec."Header ID"), Rec.JournalLineDocNo);
                    NavigatePage.SetRec(Rec);
                    NavigatePage.Run();
                end;

            }


        }

    }
    procedure GetTxnClearingDate(HeaderId: Guid): Date
    var
        Transaction: Record "Transactions - Alaan";
    begin
        Clear(Transaction);
        if not IsNullGuid(HeaderId) then begin
            Transaction.Get(HeaderId);
            exit(Transaction."Txn Clearing Date".Date);
        end;
    end;

}