pageextension 50127 "Payment Journal WS" extends "Payment Journal"
{
    layout
    {
        addafter(JournalErrorsFactBox)
        {
            part("ReceiptDetails"; "Receipt Factbox")
            {
                ApplicationArea = All;
                SubPageLink = TransactionId = field(TxnId);
            }
        }
        addafter("Message to Recipient")
        {
            field(Memo; Rec.Memo)
            {
                ApplicationArea = All;
                Caption = 'Memo';
            }
        }
    }
}

