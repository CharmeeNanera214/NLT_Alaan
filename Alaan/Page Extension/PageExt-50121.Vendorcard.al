pageextension 50121 "Vendor Card Ext" extends "Vendor Card"
{
    PromotedActionCategories = 'Process,Report,Approve,Request Approval,New Document,Navigate,Incoming Documents,Vendor,Prices & Discounts,Synchronize,Alaan Connection';

    layout
    {
        addafter(Receiving)
        {
            group("Alaan Synchronization")
            {
                Caption = 'Alaan Details';
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
                field("Supplier Id"; Rec."Supplier Id")
                {
                    Caption = 'Supplier Id';
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
    }

    actions
    {
        addafter("&Purchases")
        {
            group("Alaan Sync")
            {
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
                            if Confirm('Do you want to sync Vendor with Alaan Supplier') then
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
                action("Delete Vendor")
                {
                    Caption = 'Disable';
                    ToolTip = 'Disable Vendor from Alaan';
                    ApplicationArea = All;
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Category11;

                    trigger OnAction()
                    var
                        SupplierAPI: Codeunit "Supplier Api";
                        Guid: Guid;
                    begin
                        if (not IsNullGuid(Rec."Supplier Id")) and Rec."Sync With Alaan" then begin
                            if not Rec."Privacy Blocked" then begin
                                if Confirm('Vendor is not blocked in business central. Do you still want to disable it from Alaan?') then
                                    SupplierAPI.DeleteSupplierFromAlaan(Rec)
                            end
                            else
                                if Confirm('Do you want to disable Vendor (Supplier) from Alaan ?') then
                                    SupplierAPI.DeleteSupplierFromAlaan(Rec)
                        end
                        else
                            Error('Vendor is not connected with Alaan');

                    end;
                }
            }
        }

    }
}