pageextension 50125 "VAT Posting Setup EXT" extends "VAT Posting Setup"
{
    PromotedActionCategories = 'Process,Report,New Document,Vendor,Prices & Discounts,Navigate,Synchronize,Alaan Connection';
    layout
    {
        addafter("Tax Category")
        {
            field("Alaan Tax Code"; Rec."Alaan Tax Code")
            {
                ApplicationArea = All;
                Caption = 'Alaan Tax Code';
                Editable = false;
            }
            field("Sync With Alaan"; Rec."Sync With Alaan")
            {
                Caption = 'Connect with Alaan';
                ToolTip = 'Specify that record is allow to Connect with alaan or not';
                ApplicationArea = All;
            }
            field("Synced With Alaan"; Rec."Synced With Alaan")
            {
                Caption = 'Connected With Alaan';
                Editable = false;
                ApplicationArea = All;
            }
            field("Alaan Tax Code Id"; Rec."Alaan Tax Code Id")
            {
                Caption = 'Alaan Tax Code ID';
                Editable = false;
                ApplicationArea = All;
            }

            field("Last Synced with Alaan"; Rec."Last Synced with Alaan")
            {
                Editable = false;
                ApplicationArea = All;
                Caption = 'Last Connected Time with Alaan';
            }
        }
    }

    actions
    {
        addafter(Copy)
        {
            group("Alaan Sync")
            {
                action("Synchnorization")
                {
                    Caption = 'Connect';
                    ApplicationArea = All;
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Category8;
                    trigger OnAction()
                    var
                        TaxCodeAPI: Codeunit "Tax Codes API";
                    begin
                        if Rec."Alaan Tax Code" = '' then
                            Error('Alaan Tax Code is Empty');
                        if Rec."Sync With Alaan" then begin
                            // if Rec."Sync With Alaan" and not Rec."Synced With Alaan" then begin
                            if Confirm('Do you want to sync Tax code ?') then
                                TaxCodeAPI.SyncTaxCodesToAlaan(Rec."Alaan Tax Code", false);
                        end
                        else
                            Error('Tax Code is not allowed to connect with Alaan or there is no change to update on Alaan');
                    end;
                }

                action("Sync Log")
                {
                    Caption = 'Connection Log';
                    ApplicationArea = All;
                    Image = Log;
                    Promoted = true;
                    PromotedCategory = Category8;

                    trigger OnAction()
                    var
                        TaxLog: Record "Tax Code - Alaan Logs";
                        TaxLogPage: Page "Tax Codes - Alaan Logs";
                    begin
                        TaxLog.SetFilter(BC_Tax_Code, Rec."Alaan Tax Code");
                        TaxLog.SetCurrentKey(EntryNo);
                        TaxLog.SetAscending(EntryNo, true);
                        Page.Run(Page::"Tax Codes - Alaan Logs", TaxLog);
                    end;
                }
                action("Delete Tax Code")
                {
                    Caption = 'Disconnect';
                    ToolTip = 'Disconnect Tax Code from Alaan';
                    ApplicationArea = All;
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Category8;

                    trigger OnAction()
                    var
                        TaxCodeAPI: Codeunit "Tax Codes API";
                    begin
                        if (not IsNullGuid(Rec."Alaan Tax Code Id")) and Rec."Sync With Alaan" then begin
                            if Confirm('Do you want to delete Tax Code from Alaan ?') then
                                TaxCodeAPI.DeleteTaxCode(Rec);
                        end
                        else
                            Error('Tax Code is not connected with Alaan');
                    end;
                }
            }
        }

    }
}