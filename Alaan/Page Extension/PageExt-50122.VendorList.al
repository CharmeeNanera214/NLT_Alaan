pageextension 50122 "Vendor List" extends "Vendor List"
{
    PromotedActionCategories = 'Process,Report,New Document,Vendor,Prices & Discounts,Navigate,Synchronize,Category7,Category8,Category9,Alaan Connection';

    layout
    {
        addafter("Allow Multiple Posting Groups")
        {

            field("Sync With Alaan"; Rec."Sync With Alaan")
            {
                ApplicationArea = All;
                Caption = 'Connect With Alaan';
                Editable = false;
            }
            field("Synced With Alaan"; Rec."Synced With Alaan")
            {
                ApplicationArea = All;
                Caption = 'Connected with Alaan';
                Editable = false;
            }
        }
    }

    actions
    {
        addafter("&Purchases")
        {
            group("Alaan Sync")
            {
                Caption = 'Alaan Connection';
                action("Synchnorization")
                {
                    Caption = 'Connect';
                    ApplicationArea = All;
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Category11;
                    trigger OnAction()
                    var
                        SupplierAPI: Codeunit "Supplier Api";
                    begin
                        if Rec."Sync With Alaan" then begin
                            // if Rec."Sync With Alaan" and not Rec."Synced With Alaan" then begin
                            if Confirm('Do you want to Connect Vendor with Alaan Supplier') then
                                SupplierAPI.SyncSupplierToAlaan(Rec."No.", false);
                        end
                        else
                            Error('Vendor is not allowed to Connect with Alaan or there is no change to update on Alaan');
                    end;
                }
                action("Sync Log")
                {
                    Caption = 'Connection Log';
                    ApplicationArea = All;
                    Image = Log;
                    Promoted = true;
                    PromotedCategory = Category11;
                    RunObject = Page "Supplier - Alaan Logs";
                    RunPageLink = BC_Vendor_NO = field("No.");
                    RunPageView = sorting(No) order(descending);
                    RunPageMode = View;
                }
            }
        }
    }
}