page 50131 "NLT - Alaan Setup"
{
    Caption = 'NLT - Alaan Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NLT - Alaan Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    DataCaptionFields = CompanyName;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Company Credentails';
                field(CompanyID; Rec.CompanyID)
                {
                    ApplicationArea = All;
                    Caption = 'Company ID';
                    Editable = false;
                }
                field(CompanyName; Rec.CompanyName)
                {
                    ApplicationArea = All;
                    Caption = 'Company Name';
                    Editable = false;
                }
                field(ClientID; Rec.ClientID)
                {
                    Caption = 'Client ID';
                    ApplicationArea = All;
                }
                field(ClientSecret; Rec.ClientSecret)
                {
                    ApplicationArea = All;
                    Caption = 'Client Secret';
                }
            }
            group(Dimension)
            {
                Caption = 'Dimension';
                field("Employee DIM"; Rec."Employee DIM")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Dimession';
                    ToolTip = 'Dimension Code to Map Employee with Alaan';
                }
                field("Exp. Cat. DIM"; Rec."Exp. Cat. DIM")
                {
                    ApplicationArea = All;
                    Caption = 'Expense Category Dimession';
                    ToolTip = 'Dimension Code to Map Expense Category with Alaan';
                }
                field("Transaction Type DIM"; Rec."Transaction Type DIM")
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Type Dimension';
                }

            }
            group("Payment Journal")
            {
                Caption = 'Payment Journal';
                field("Employee Bank"; Rec."Employee Bank")
                {
                    ApplicationArea = All;
                    Caption = 'Employee Card Bank';
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    ApplicationArea = All;
                    Caption = 'Payment Method';
                }
                field(AlaanVendorJurBatch; Rec.AlaanVendorJurBatch)
                {
                    ApplicationArea = All;
                    Caption = 'Alaan Vendor Journal Batch';
                    ToolTip = 'Use to post transactions which came from Alaan';
                }
                field(AlaanExpenseJurBatch; Rec.AlaanExpenseJurBatch)
                {
                    ApplicationArea = All;
                    Caption = 'Alaan Expense Journal Batch';
                    ToolTip = 'Use to post transactions which came from Alaan';
                }
                // field("Cashback Account"; Rec."Cashback Account")
                // {
                //     ApplicationArea = All;
                //     Caption = 'Cashback Account';
                //     ToolTip = 'Cashback account for bacalance account of Cashback line of transaction';
                // }
            }

            group("Transaction Type")
            {
                Caption = 'Transaction type';
                part(TransactionType; "Transaction type")
                {
                    SubPageLink = DIMEmpCode = field("Transaction Type DIM");
                    ApplicationArea = All;
                    Caption = 'Transaction Type';
                }
            }

            // group("Synced Dimension")
            // {
            //     Caption = 'Dimension Synced';
            //     field("EMP DIM Synced"; Rec."EMP DIM Synced")
            //     {
            //         Editable = false;
            //         ApplicationArea = All;
            //         Caption = 'Employee Dimension Synced';
            //     }
            //     field("Exp. Cate. DIM Synced"; Rec."Exp. Cate. DIM Synced")
            //     {
            //         ApplicationArea = All;
            //         Caption = 'Expense category Dimension Synced';
            //         Editable = false;
            //     }
            //     field("Txn Type DIM Synced"; Rec."Txn Type DIM Synced")
            //     {
            //         Caption = 'Transaction Type Dimension Synced';
            //         ApplicationArea = All;
            //         Editable = false;

            //     }
            // }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                ApplicationArea = All;
                Image = Create;
                Promoted = true;
                PromotedCategory = New;
                trigger OnAction()
                var
                    Authorization: Codeunit Authorization;
                    Token: Text[250];
                begin
                    if not IsNullGuid(Rec.CompanyID) then
                        Token := Authorization.GetAccessToken(Rec.CompanyID)
                    else
                        Error('Setup is not created for this company');
                    if Token <> '' then
                        Message('Connected Successfully!!!')
                    else
                        Message('Connection Failed');
                end;
            }
            // action(CreateTxnDimension)
            // {
            //     Caption = 'Create Transaction Type';
            //     ApplicationArea = All;
            //     Image = Create;
            //     Promoted = true;
            //     PromotedCategory = New;
            //     trigger OnAction()
            //     var
            //         Dimension: Record Dimension;
            //         DimensionValue: Record "Dimension Value";
            //         TempDimension: Record Dimension temporary;
            //         DimensionList: Page "Dimension List";
            //     begin
            //         DimensionList.LookupMode(true);
            //         DimensionList.SetTableView(TempDimension);
            //         if DimensionList.RunModal() = Action::LookupOK then begin
            //             // if Page.RunModal(Page::"Dimension List", TempDimension) = Action::LookupOK then begin
            //             if TempDimension.FindFirst() then begin
            //                 Dimension.Init();
            //                 Dimension := TempDimension;
            //                 if Dimension.Insert() then
            //                     CreateTxnType(Dimension);
            //             end;
            //         end;
            //     end;
            // }

        }
    }

    trigger OnOpenPage()
    begin
        if Rec.IsEmpty then
            if Rec.Get(CompanyProperty.ID()) then
                CurrPage.SetTableView(Rec)
            else begin
                if Confirm('No credentials Available for this company. Do you want to create new one ?') then begin
                    InitialCompanyCredentials();
                    Rec.Get(CompanyProperty.ID());
                    CurrPage.SetTableView(Rec);
                end;
            end;
    end;

    local procedure InitialCompanyCredentials()
    begin
        if Rec.Get(CompanyProperty.ID()) then Error('Credentials for this company is already exist.');
        Rec.Init();
        Rec.CompanyName := CompanyProperty.DisplayName();
        Rec.CompanyID := CompanyProperty.ID();
        Rec.Insert();
    end;

    // local procedure CreateTxnType(Dimension: Record Dimension)
    // var
    //     DimensionValue: Record "Dimension Value";
    // begin
    //     DimensionValue.Init();
    //     DimensionValue."Dimension Code" := Dimension.Code;
    //     DimensionValue.Code := 'EXPENSE';
    //     Dimension.Name := 'Expense Transaction';
    //     DimensionValue.Insert();
    //     DimensionValue.Init();
    //     DimensionValue."Dimension Code" := Dimension.Code;
    //     DimensionValue.Code := 'VENDOR';
    //     Dimension.Name := 'Vendor Transaction';
    //     DimensionValue.Insert();
    //     Message('Transation Dimension and Value has been inserted');
    // end;
}