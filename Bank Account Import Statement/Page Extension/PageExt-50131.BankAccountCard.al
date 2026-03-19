pageextension 50131 "Bank account card EXT" extends "Bank Account Card"
{
    layout
    {
        addafter("Payment Export Format")
        {
            field("General Batch"; Rec."General Batch")
            {
                ApplicationArea = All;
                Caption = 'General Journal batch';
                trigger OnAssistEdit()
                var
                    BankImpSetup: Record "Bank Import Statement Setup";
                    GenBatch: Record "Gen. Journal Batch";
                    GenBatchPage: Page "General Journal Batches";
                begin
                    BankImpSetup.Get();
                    BankImpSetup.TestField("General Journal Template");
                    GenBatch.SetFilter("Journal Template Name", BankImpSetup."General Journal Template");
                    GenBatch.FindSet();
                    GenBatchPage.SetRecord(GenBatch);
                    GenBatchPage.LookupMode(true);
                    GenBatchPage.Editable(false);
                    if GenBatchPage.RunModal() = Action::LookupOK then begin
                        GenBatchPage.GetRecord(GenBatch);
                        Rec."General Batch" := GenBatch.Name;
                    end;
                end;
            }
        }
    }
}