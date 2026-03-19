codeunit 50142 "Set Dimension On Gen Line"
{
    Permissions = tabledata "Dimension Set Entry" = RIMD;
    procedure SetDimension(TxnLine: Record "Transaction Line - Alaan"; AccountType: Option "Vendor","GL Account","Bank Account") DimesnionID: Integer
    begin
        Clear(EMPDIMCODE);
        Clear(EMPDIMVALUE);
        Clear(ACCDIMCODE);
        Clear(ACCDIMVALUE);
        Clear(DimensionValue);
        Clear(DimensionSetEntry);

        GetEmployeeDimenison(TxnLine."Tag Group Item ID");
        if AccountType <> AccountType::Vendor then
            GetAccountDimenison(TxnLine."Expense Category ID");

        if (EMPDIMCODE <> '') and (EMPDIMVALUE <> '') then
            CreateTempDimensionEntry(EMPDIMCODE, EMPDIMVALUE);
        if (ACCDIMCODE <> '') and (ACCDIMVALUE <> '') then
            CreateTempDimensionEntry(ACCDIMCODE, ACCDIMVALUE);
        DimesnionID := DimensionSetEntry.GetDimensionSetID(TempDimensionSetEntry);
        exit(DimesnionID);
    end;

    local procedure GetEmployeeDimenison(EmployeeID: Guid)
    var
        NLTEmployee: Record NLTEmployee;
    begin
        if not IsNullGuid(EmployeeID) then begin
            NLTEmployee.SetFilter("Employee ID", EmployeeID);
            if not NLTEmployee.FindSet() then
                Error('Associated Employee is not synced');
            EMPDIMCODE := NLTEmployee.DIMEmpCode;
            EMPDIMVALUE := NLTEmployee.Code;
        end;
    end;

    local procedure GetAccountDimenison(ExpenseCategoryID: Guid)
    var
        ExpenseCategory: Record "Expense Categories";
    begin
        Clear(ExpenseCategory);
        if not IsNullGuid(ExpenseCategoryID) then begin
            ExpenseCategory.SetFilter("Expense ID", ExpenseCategoryID);
            if not ExpenseCategory.FindSet() then
                Error('Associated Expense category is not synced');
            ACCDIMCODE := ExpenseCategory."EXP CAT DIM CODE";
            ACCDIMVALUE := ExpenseCategory."EXP. CAT.";
        end;
    end;

    local procedure GetDimensionValueID(Code: Code[20]; Value: Code[20]): Integer
    begin
        Clear(DimensionValue);
        if DimensionValue.Get(Code, Value) then
            exit(DimensionValue."Dimension Value ID");
    end;

    local procedure CreateTempDimensionEntry(Code: Code[20]; Value: Code[20])
    begin
        TempDimensionSetEntry.SetFilter("Dimension Code", Code);
        TempDimensionSetEntry.SetFilter("Dimension Value Code", Value);
        if TempDimensionSetEntry.FindSet() then
            exit;

        TempDimensionSetEntry.Init();
        TempDimensionSetEntry."Dimension Code" := Code;
        TempDimensionSetEntry."Dimension Value Code" := Value;
        TempDimensionSetEntry."Dimension Value ID" := GetDimensionValueID(Code, Value);
        TempDimensionSetEntry.Insert();
    end;


    var
        DimensionSetEntry: Record "Dimension Set Entry";
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionValue: Record "Dimension Value";
        EMPDIMCODE: Code[20];
        EMPDIMVALUE: Code[20];
        ACCDIMCODE: Code[20];
        ACCDIMVALUE: Code[20];
}