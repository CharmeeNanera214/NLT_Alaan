pageextension 50132 "Bank Acc. Recon. Lines Ext." extends "Bank Acc. Reconciliation Lines"
{
    DeleteAllowed = true;
    layout
    {
        addbefore(Description)
        {
            field("External Doc no."; Rec."External Doc no.")
            {
                ApplicationArea = All;
                Caption = 'External Document No';
            }
        }
    }
}