page 50111 "Bank Statements Import"
{
    ApplicationArea = All;
    Caption = 'Bank Statement Import';
    CardPageId = "Bank Statement Import";
    Editable = false;
    PageType = List;
    SourceTable = "Bank Acc. Reconciliation";
    UsageCategory = Lists;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
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
        }
    }
}