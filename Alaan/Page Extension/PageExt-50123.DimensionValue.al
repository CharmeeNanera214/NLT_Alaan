pageextension 50123 "Dimension Values Ext" extends "Dimension Values"
{
    layout
    {
        modify(Name)
        {
            trigger OnAfterValidate()
            begin
                UpdateAlaanDimenison();
            end;
        }
    }
    local procedure UpdateAlaanDimenison()
    var
        ExpenseCategory: Record "Expense Categories";
        NLTEmployee: Record NLTEmployee;
        AlaanSetup: Record "NLT - Alaan Setup";
        EMPDIM: Code[20];
        EXPDIM: Code[20];
    begin
        ExpenseCategory.SetFilter("EXP. CAT.", Rec.Code);
        ExpenseCategory.SetFilter("EXP CAT DIM CODE", Rec."Dimension Code");
        if ExpenseCategory.FindFirst() then begin
            ExpenseCategory."Expense category Name" := Rec.Name;
            ExpenseCategory.Modify(true);
        end;

        if NLTEmployee.Get(Rec.Code, Rec."Dimension Code") then begin
            NLTEmployee.Name := Rec.Name;
            NLTEmployee.Modify(true);
        end;

    end;
}