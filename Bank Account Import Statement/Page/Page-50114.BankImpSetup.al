page 50114 "Bank Import Setup"
{
    PageType = Card;
    Caption = 'Bank Statement Import Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Bank Import Statement Setup";

    layout
    {
        area(Content)
        {
            group(Configuration)
            {
                field("General Journal Template"; Rec."General Journal Template")
                {
                    ApplicationArea = All;
                    Caption = 'General Journal Template';
                }
            }
            part("Bank Account Listpart"; "Bank Account Listpart")
            {
                ApplicationArea = All;
                Caption = 'Bank Accounts';
                Editable = true;
            }
        }
    }

    trigger OnOpenPage()
    begin

        if Rec.IsEmpty then begin
            Rec.Init();
            Rec.EntryNo := '';
            Rec.Insert();
        end;
    end;
}