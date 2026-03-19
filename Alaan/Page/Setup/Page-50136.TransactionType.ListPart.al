page 50136 "Transaction type"
{
    PageType = ListPart;
    Caption = 'Transaction Type';
    UsageCategory = None;
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
                    Caption = 'Transation Type Dimension';
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Transaction Type Code';
                    trigger OnAssistEdit()
                    var
                        Setup: Record "NLT - Alaan Setup";
                        DimRec: Record "Dimension Value";
                        DimensionPage: Page "Dimension Values";
                    begin
                        if not Setup.Get(CompanyProperty.ID()) then
                            Error('Company Setup is not defined');

                        Setup.TestField("Transaction Type DIM");
                        DimRec.SetRange("Dimension Code", Setup."Transaction Type DIM");
                        DimRec.SetRange(Blocked, false);
                        if not DimRec.FindFirst() then
                            Error('No Transaction Type for Dimension %1', Setup."Transaction Type DIM");

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
        area(Processing)
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
                        NLTEmployeeAPIMGT: Codeunit "NLT Employee Sync API";
                    begin
                        // if Rec."Sync With Alaan" and not Rec."Synced With Alaan" then begin
                        if Rec."Sync With Alaan" then begin
                            if Confirm('Do you want to sync Transaction Type with Alaan') then
                                NLTEmployeeAPIMGT.SyncNLTEmployee(Rec);
                        end
                        else
                            Error('Transaction Type is not allowed to Connect with Alaan or There is no change to update on Alaan');
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
                    ToolTip = 'Disconnect Transaction Type from Alaan';
                    ApplicationArea = All;
                    Image = Delete;

                    trigger OnAction()
                    var
                        NLTEmployeeAPIMGT: Codeunit "NLT Employee Sync API";
                    begin
                        if (not IsNullGuid(Rec."Employee ID")) and Rec."Sync With Alaan" then begin
                            if Confirm('Do you want to delete Transaction Type from Alaan ?') then
                                NLTEmployeeAPIMGT.DeleteNLTEmployeeFromAlaan(Rec);
                        end
                        else
                            Error('Transaction Type is not connected with Alaan');
                    end;
                }
            }
        }
    }
}