page 50127 "Expense Categories"
{
    PageType = List;
    Caption = 'Alaan - Expense Category';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Expense Categories";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("EXP. CAT."; Rec."EXP. CAT.")
                {
                    ApplicationArea = All;
                    Caption = 'Expense Category';

                    trigger OnAssistEdit()
                    var
                        Setup: Record "NLT - Alaan Setup";
                        DimRec: Record "Dimension Value";
                        DimensionPage: Page "Dimension Values";
                    begin
                        if not Setup.Get(CompanyProperty.ID()) then
                            Error('Company Setup is not defined');

                        Setup.TestField("Exp. Cat. DIM");
                        DimRec.SetRange("Dimension Code", Setup."Exp. Cat. DIM");
                        DimRec.SetRange(Blocked, false);

                        if not DimRec.FindFirst() then
                            Error('No employee assigned for Dimension %1', Setup."Exp. Cat. DIM");
                        DimensionPage.Editable(false);
                        DimensionPage.LookupMode(true);
                        DimensionPage.SetTableView(DimRec);

                        if DimensionPage.RunModal() = Action::LookupOK then begin
                            DimensionPage.GetRecord(DimRec);
                            Rec."EXP. CAT." := DimRec.Code;
                            Rec."Expense category Name" := DimRec.Name;
                        end;
                    end;

                }
                field("EXP CAT DIM CODE"; Rec."EXP CAT DIM CODE")
                {
                    Caption = 'Expense Category Dimension Code';
                    ApplicationArea = All;
                    Editable = false;

                }
                field("GL Acc"; Rec."GL Acc")
                {
                    ApplicationArea = All;
                    Caption = 'GL Account';
                    TableRelation = "G/L Account"."No." where("Account Type" = const("G/L Account Type"::Posting));
                }
                field("Expense category Name"; Rec."Expense category Name")
                {
                    ApplicationArea = All;
                    Caption = 'Expense category Name';
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
                field("Expense ID"; Rec."Expense ID")
                {
                    Caption = 'Expense ID';
                    Editable = true;
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
        area(Navigation)
        {

            group("Alaan Sync")
            {
                Caption = 'Alaan Connection';
                action("Synchnorization")
                {
                    Caption = 'Connect';
                    ApplicationArea = All;
                    Image = Refresh;

                    trigger OnAction()
                    var
                        ExpenseAPIMGT: Codeunit "Exp. Cat. GL Acc. API";
                        TempExpCat: Record "Expense Categories" temporary;
                        ExpCatRec: Record "Expense Categories";
                        EXP_CAT_Filter: Text;
                        GL_Filter: Text;
                        DIM_Filter: Text;
                        Count: Integer;
                    begin
                        CurrPage.SetSelectionFilter(ExpCatRec);
                        ExpCatRec.SetRange("Sync With Alaan", true);
                        // ExpCatRec.SetRange("Synced With Alaan", false);
                        if ExpCatRec.FindSet() then begin
                            Count := ExpCatRec.Count;
                            if Count = 1 then begin
                                if ExpCatRec."Sync With Alaan" then begin
                                    // if Rec."Sync With Alaan" and not Rec."Synced With Alaan" then begin
                                    if Confirm('Do you want to sync Chart of account with Alaan Expense Category') then
                                        ExpenseAPIMGT.SyncExpenseCategoryToAlaan(ExpCatRec);
                                end
                                else
                                    Error('Account is not allowed to Connect with Alaan or There is no chnage to update on Alaan');
                            end
                            else begin
                                if Confirm('Do you want to sync Chart of account with Alaan Expense Category') then
                                    repeat
                                        ExpenseAPIMGT.SyncExpenseCategoryToAlaan(ExpCatRec);
                                    until ExpCatRec.Next() = 0;
                            end;
                        end;


                        //  if Rec."Sync With Alaan" and not Rec."Synced With Alaan" then begin
                        //             if Confirm('Do you want to sync Chart of account with Alaan Expense Category') then
                        //                 ExpenseAPIMGT.SyncExpenseCategoryToAlaan(Rec."EXP. CAT.", Rec."GL Acc", Rec."EXP CAT DIM CODE", false);
                        //         end
                        //         else
                        //             Error('Account is not allowed to Connect with Alaan or There is no chnage to update on Alaan');
                    end;
                }


                action("Sync Log")
                {
                    Caption = 'Connection Log';
                    ApplicationArea = All;
                    Image = Log;
                    RunObject = Page "Expense Cat - Alaan Logs";
                    RunPageLink = BC_EXPCAT_CODE = field("EXP. CAT.");
                    RunPageView = sorting(EntryNo) order(descending);
                    RunPageMode = View;
                }
                action("Delete Exp Cate")
                {
                    Caption = 'Disconnect';
                    ToolTip = 'Disconnect Expense Category from Alaan';
                    ApplicationArea = All;
                    Image = Delete;

                    trigger OnAction()
                    var
                        ExpenseAPIMGT: Codeunit "Exp. Cat. GL Acc. API";
                        TempExpCat: Record "Expense Categories" temporary;
                        ExpCatRec: Record "Expense Categories";
                        EXP_CAT_Filter: Text;
                        GL_Filter: Text;
                        DIM_Filter: Text;
                        Count: Integer;
                    begin
                        if (not IsNullGuid(Rec."Expense ID")) and Rec."Sync With Alaan" then begin
                            if Confirm('Do you want to delete Chart of Account (Expense Category) from Alaan ?') then
                                ExpenseAPIMGT.DeleteExpenseCategoryFromAlaan(Rec);
                        end
                        else
                            Error('Chart of Account is not Connected with Alaan');
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AlaanSetup: Record "NLT - Alaan Setup";
        ExpDIM: Code[20];
    begin
        if AlaanSetup.Get(CompanyProperty.ID()) then begin
            ExpDIM := AlaanSetup."Exp. Cat. DIM";
        end;

        if ExpDIM <> '' then begin
            Rec.SetRange("EXP CAT DIM CODE", ExpDIM);
            CurrPage.SetTableView(Rec);
        end;
    end;
}