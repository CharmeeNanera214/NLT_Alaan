page 50145 "Receipt Factbox"
{
    PageType = CardPart;
    Caption = 'Alaan - Receipt Details';
    SourceTable = "Transactions - Alaan";

    layout
    {
        area(Content)
        {
            group(ReceiptDetails)
            {
                ShowCaption = false;
                field(TransactionId; Rec.TransactionId)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Receipt; Rec.Receipt)
                {
                    ApplicationArea = All;
                }
                field(Warning; Warning)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    var
        ReceiptVisible: Boolean;
        WarningVisible: Boolean;
        Warning: Label 'No Receipt Attched';

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(Receipt);
    end;


}