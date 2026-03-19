page 50116 "Bank Account Listpart"
{
    Caption = 'Bank Account';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "Bank Account";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Bank No';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Bank Name';
                }
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
                        GenBatchPage.SetTableView(GenBatch);
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
}