page 50137 "Alaan - Transaction Type"
{
    PageType = List;
    Caption = 'Alaan- Transaction Types';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = NLTEmployee;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(DIMEmpCode; Rec.DIMEmpCode)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Transaction Dimension';
                }

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Code';
                    trigger OnAssistEdit()
                    var
                        Setup: Record "NLT - Alaan Setup";
                        DimRec: Record "Dimension Value";
                        DimensionPage: Page "Dimension Values";
                    begin
                        if not Setup.Get(CompanyProperty.ID()) then
                            Error('Company Setup is not defined');

                        Setup.TestField("Employee DIM");
                        DimRec.SetRange("Dimension Code", Setup."Transaction Type DIM");
                        DimRec.SetRange(Blocked, false);
                        if not DimRec.FindFirst() then
                            Error('No Transaction assigned for Dimension %1', Setup."Employee DIM");

                        DimensionPage.Editable(false);
                        DimensionPage.LookupMode(true);
                        DimensionPage.SetTableView(DimRec);
                        if DimensionPage.RunModal() = Action::LookupOK then begin
                            DimensionPage.GetRecord(DimRec);
                            Rec.Code := DimRec.Code;
                            Rec.Name := DimRec.Name;
                            Rec.DIMEmpCode := DimRec."Dimension Code";
                        end;
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Name';
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
                field("Employee ID"; Rec."Employee ID")
                {
                    Caption = 'Transaction Type ID';
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
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        NLTEmployeeAPIMGT: Codeunit "NLT Employee Sync API";
                    begin
                        if Rec."Sync With Alaan" then begin
                            // if Rec."Sync With Alaan" and not Rec."Synced With Alaan" then begin
                            if Confirm('Do you want to sync Transaction type with Alaan') then
                                NLTEmployeeAPIMGT.SyncNLTEmployee(Rec);
                        end
                        else
                            Error('Transaction type is not allowed to Connect with Alaan or There is no change to update on Alaan');
                    end;
                }


                action("Sync Log")
                {
                    Caption = 'Connection Log';
                    ApplicationArea = All;
                    Image = Log;
                    RunObject = Page "NLT Employee - Alaan Logs";
                    RunPageLink = BC_Emp_Dim_Code = field(DIMEmpCode), NLT_Emp_Code = field(Code);
                    RunPageView = sorting(EntryNo) order(descending);
                    RunPageMode = View;
                }
                action("Delete Exp Cate")
                {
                    Caption = 'Disconnect';
                    ToolTip = 'Disconnect Transaction type from Alaan';
                    ApplicationArea = All;
                    Image = Delete;

                    trigger OnAction()
                    var
                        NLTEmployeeAPIMGT: Codeunit "NLT Employee Sync API";
                    begin
                        if (not IsNullGuid(Rec."Employee ID")) and Rec."Sync With Alaan" then begin
                            if Confirm('Do you want to delete Transaction type from Alaan ?') then
                                NLTEmployeeAPIMGT.DeleteNLTEmployeeFromAlaan(Rec);
                        end
                        else
                            Error('Transaction type is not Connected with Alaan');
                    end;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Type := Rec.Type::Transaction;
    end;

    trigger OnOpenPage()
    begin
        Getsetup();
        Rec.SetRange(Type, Rec.Type::Transaction);
        CurrPage.SetTableView(Rec);
    end;

    local procedure Getsetup()
    begin
        Setup.FindFirst();
    end;

    var
        Setup: Record "NLT - Alaan Setup";
}