codeunit 50139 "Exp. Cat. GL Acc. API"
{
    trigger OnRun()
    begin
        // SyncExpenseCategoryToAlaan('', '', '', true);
    end;

    // procedure SyncExpenseCategoryToAlaan(ExpCatCode: Text; GLAccountNo: Code[20]; DIMCode: Code[20]; SyncAll: Boolean)
    procedure SyncExpenseCategoryToAlaan(ExpCat: Record "Expense Categories")
    begin
        // ExpCat.Reset();
        // if not SyncAll then begin
        //     ExpCat.SetFilter("EXP. CAT.", ExpCatCode);
        //     ExpCat.SetFilter("GL Acc", GLAccountNo);
        //     ExpCat.SetFilter("EXP CAT DIM CODE", DIMCode);
        // end;
        // ExpCat.SetRange("Sync With Alaan", true);
        // ExpCat.SetRange("Synced With Alaan", false);
        // if ExpCat.FindSet() then
        //     repeat
        if SyncExpenseCategory(ExpCat) then begin
            if not ExpenseCatLog.IsError then begin
                ExpCat."Synced With Alaan" := true;
                ExpCat.Validate("Expense ID", ExpenseCatLog."Expense Category Id");
                // Evaluate(ExpCat."Expense ID", ExpenseCatLog."Expense Category Id");
                ExpCat."Last Synced with Alaan" := CurrentDateTime;
                ExpCat.Modify();
                // if GuiAllowed then
                Message('GL Account Connected Successfully');
                // if not SyncAll then 
            end
            else
                // if GuiAllowed then
                //     if not SyncAll then
                     Message('GL Account not Connected');
        end
        else begin
            ExpenseCatLog.IsError := true;
            Evaluate(ExpenseCatLog."Error Message", GetLastErrorText());
            ExpenseCatLog.Modify();
            // if GuiAllowed then
            //     if not SyncAll then
            Message('GL Account not Connected');
        end;
        //     until ExpCat.Next() = 0
        // else
        //     if GuiAllowed then
        //         Message('No Expense Category (GL Account) Found to Connect');
    end;

    [TryFunction]
    local procedure SyncExpenseCategory(ExpCat: Record "Expense Categories")
    var
        Response: JsonObject;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
    begin
        Clear(ExpenseCatLog);
        ExpenseCatLog.Init();
        ExpenseCatLog.Validate(BC_GLAcc_NO, ExpCat."GL Acc");
        ExpenseCatLog.Validate(BC_EXPCAT_CODE, ExpCat."EXP. CAT.");
        ExpenseCatLog.Validate(Name, ExpCat."Expense category Name");
        ExpenseCatLog.Validate(SyncType, ExpenseCatLog.SyncType::"To Alaan");
        ExpenseCatLog.Validate("Expense Category Id", ExpCat."Expense ID");
        ExpenseCatLog.Validate("Sync Date & Time", CurrentDateTime);
        ExpenseCatLog.Insert();

        if IsNullGuid(ExpCat."Expense ID") then begin
            ExpenseCatLog.ActionType := ExpenseCatLog.ActionType::Create;
            Response := CreateExpenseAccInAlaan(ExpCat);
            if Response.Get('status', JsonToken) then
                if JsonToken.AsValue().AsBoolean() then begin
                    Response.get('entity', JsonToken);
                    if JsonToken.IsArray then begin
                        JsonArray := JsonToken.AsArray();
                        Response := JsonArray.GetObject(0);
                    end;
                end
                else begin
                    if Response.get('errorType', JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            ExpenseCatLog."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then begin
                        if JsonToken.IsArray then JsonArray := JsonToken.AsArray();
                        if JsonArray.Get(0, JsonToken) then ExpenseCatLog."Error Message" := JsonToken.AsValue().AsText();
                    end;
                    ExpenseCatLog.IsError := true;
                    ExpenseCatLog.Modify();
                end;

            if Response.Get('id', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(ExpenseCatLog."Expense Category Id", JsonToken.AsValue().AsText());

            if Response.Get('active', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(ExpenseCatLog.Active, JsonToken.AsValue().AsText());

            if Response.Get('corporateId', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(ExpenseCatLog.CorporateId, JsonToken.AsValue().AsText());

            if Response.Get('name', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(ExpenseCatLog.Name, JsonToken.AsValue().AsText());

            if Response.Get('partnerExpenseAccountId', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(ExpenseCatLog.partnerExpenseAccountId, JsonToken.AsValue().AsText());

            if Response.Get('glaccount', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(ExpenseCatLog.BC_GLAcc_NO, JsonToken.AsValue().AsText());
            ExpenseCatLog.Modify()
        end
        else begin
            ExpenseCatLog.ActionType := ExpenseCatLog.ActionType::Update;
            Response := UpdateExpenseAccInAlaan(ExpCat);
            if Response.Get('status', JsonToken) then
                if not JsonToken.AsValue().AsBoolean() then begin
                    if Response.get('errorType', JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            ExpenseCatLog."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            ExpenseCatLog."Error Message" := JsonToken.AsValue().AsText();
                    ExpenseCatLog.IsError := true;
                end;
            ExpenseCatLog.Modify();
        end;
    end;

    procedure CreateExpenseAccInAlaan(ExpCat: Record "Expense Categories") Response: JsonObject
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
    begin
        URL := StrSubstNo('%1/expense-categories', AlaanAPIMGT.GetBaseURL());
        JsonObject.Add('name', ExpCat."Expense category Name");
        JsonObject.Add('glaccount', ExpCat."GL Acc");
        JsonArray.Add(JsonObject);
        Clear(JsonObject);
        JsonObject.Add('expenseCategories', JsonArray);
        JsonObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'POST');
        exit(Response);
    end;

    procedure UpdateExpenseAccInAlaan(ExpCat: Record "Expense Categories") Response: JsonObject
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
        ExpenseIDTXT: Text;
    begin
        ExpenseIDTXT := DelChr(ExpCat."Expense ID".ToText, '=', '{}');
        URL := StrSubstNo('%1/expense-categories/%2', AlaanAPIMGT.GetBaseURL(), ExpenseIDTXT);
        JsonObject.Add('name', ExpCat."Expense category Name");
        JsonObject.Add('glaccount', ExpCat."GL Acc");
        JsonObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'PATCH');
        exit(Response);
    end;

    procedure DeleteExpenseCategoryFromAlaan(ExpCat: Record "Expense Categories")
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        URL: Text;
        ExpcatIDTXT: Text;
        Guid: Guid;
    begin
        ExpenseCatLog.Init();
        ExpenseCatLog."Sync Date & Time" := CurrentDateTime;
        ExpenseCatLog.SyncType := ExpenseCatLog.SyncType::"To Alaan";
        ExpenseCatLog.ActionType := ExpenseCatLog.ActionType::Delete;
        ExpenseCatLog.BC_GLAcc_NO := ExpCat."GL Acc";
        ExpenseCatLog.BC_EXPCAT_CODE := ExpCat."EXP. CAT.";
        ExpenseCatLog.Name := ExpCat."Expense category Name";
        ExpenseCatLog."Expense Category Id" := ExpCat."Expense ID";
        ExpenseCatLog.Insert();
        if AlaanAPIMGT.CheckRecordIsInTransaction(ExpCat."Expense ID", 'EXPENSECAT') then begin
            ExpenseCatLog."Error Message" := 'Expense Category is mapped with some Transaction. You can not Delete it';
            ExpenseCatLog.Modify();
            Error('Expense Category is mapped with some Transaction. You can not Delete it');
        end;

        ExpcatIDTXT := DelChr(ExpCat."Expense ID".ToText, '=', '{}');
        URL := StrSubstNo('%1/expense-categories/%2', AlaanAPIMGT.GetBaseURL(), ExpcatIDTXT);
        JsonObject := AlaanAPIMGT.CallDeleteAPI(CompanyProperty.ID(), URL);

        if JsonObject.Get('status', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                ExpenseCatLog.IsError := true;
                if JsonObject.Get('message', JsonToken) then begin
                    if not JsonToken.AsValue().IsNull then
                        ExpenseCatLog."Error Message" := JsonToken.AsValue().AsText();
                    // JsonArray := JsonToken.AsArray();
                    // if JsonArray.Get(0, JsonToken) then
                end;
                ExpenseCatLog.Modify();
            end
            else begin
                ExpCat."Sync With Alaan" := false;
                ExpCat."Synced With Alaan" := false;
                ExpCat.Validate("Expense ID", Guid);
                ExpCat."Last Synced with Alaan" := CurrentDateTime;
                if ExpCat.Modify() then
                    if GuiAllowed then Message('Expense Category : %1 and GL account : %2 deleted Successfully', ExpCat."EXP. CAT.", ExpCat."GL Acc");
            end;
    end;



    var
        AlaanAPIMGT: Codeunit "Alaan API MGT";
        ExpenseCatLog: Record "Expense Cat - Alaan Logs";
}