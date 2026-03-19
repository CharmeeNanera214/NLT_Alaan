codeunit 50140 "NLT Employee Sync API"
{
    procedure SyncNLTEmployee(NLTEmployee: Record NLTEmployee)
    var
        Response: JsonObject;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        Employee: Record Employee;
    begin
        Clear(NLTEmployeeLog);
        NLTEmployeeLog.Init();
        NLTEmployeeLog.Validate(BC_Emp_Dim_Code, NLTEmployee.DIMEmpCode);
        NLTEmployeeLog.Validate(NLT_Emp_Code, NLTEmployee.Code);
        NLTEmployeeLog.Validate(Name, NLTEmployee.Name);
        NLTEmployeeLog.Validate(SyncType, NLTEmployeeLog.SyncType::"To Alaan");
        NLTEmployeeLog.Validate(NLTEmployeeId, NLTEmployee."Employee ID");
        NLTEmployeeLog.Validate("Sync Date & Time", CurrentDateTime);
        NLTEmployeeLog.Insert();

        if IsNullGuid(NLTEmployee."Employee ID") then begin
            NLTEmployeeLog.ActionType := NLTEmployeeLog.ActionType::Create;
            Response := CreateNLTEmployeeInAlaan(NLTEmployee);
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
                            NLTEmployeeLog."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then begin
                        if not JsonToken.AsValue().IsNull then
                            NLTEmployeeLog."Error Message" := JsonToken.AsValue().AsText();
                    end;
                    NLTEmployeeLog.IsError := true;
                    NLTEmployeeLog.Modify();
                    exit;
                end;

            if Response.Get('id', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(NLTEmployeeLog.NLTEmployeeId, JsonToken.AsValue().AsText());

            if Response.Get('isActive', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(NLTEmployeeLog.IsActive, JsonToken.AsValue().AsText());

            if Response.Get('corporateId', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(NLTEmployeeLog.CorporateId, JsonToken.AsValue().AsText());

            if Response.Get('name', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(NLTEmployeeLog.Name, JsonToken.AsValue().AsText());

            if Response.Get('tagGroupId', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(NLTEmployeeLog.TaxGroupId, JsonToken.AsValue().AsText());
            if Response.Get('accountingReference', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(NLTEmployeeLog."Accounting Reference", JsonToken.AsValue().AsText());

            NLTEmployeeLog.Modify();
        end
        else begin
            NLTEmployeeLog.ActionType := NLTEmployeeLog.ActionType::Update;
            Response := UpdateNLTEmployeeInAlaan(NLTEmployee);
            if Response.Get('status', JsonToken) then
                if not JsonToken.AsValue().AsBoolean() then begin
                    if Response.get('errorType', JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            NLTEmployeeLog."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            NLTEmployeeLog."Error Message" := JsonToken.AsValue().AsText();
                    NLTEmployeeLog.IsError := true;
                    exit;
                end;
            NLTEmployeeLog.Modify();
        end;

        NLTEmployee."Last Synced with Alaan" := CurrentDateTime;
        NLTEmployee."Synced With Alaan" := true;
        NLTEmployee.Validate("Employee ID", NLTEmployeeLog.NLTEmployeeId);
        NLTEmployee.Modify();
        Clear(Employee);
        if Employee.Get(NLTEmployee.Code) then begin
            Employee."Alaan Employee" := true;
            Employee.Modify();
        end;
    end;

    procedure CreateNLTEmployeeInAlaan(NLTEmployee: Record NLTEmployee) Response: JsonObject
    var
        JsonObject: JsonObject;
        JObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
    begin
        URL := StrSubstNo('%1/expense-tracking-tags/%2/items', AlaanAPIMGT.GetBaseURL(), GetExpenseTagID(NLTEmployee.DIMEmpCode));
        JsonObject.Add('name', NLTEmployee.Name);
        JsonObject.Add('accountingReference', NLTEmployee.Code);
        JsonArray.Add(JsonObject);
        JObject.Add('expenseTrackingTagItems', JsonArray);
        JObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'POST');
        exit(Response);
    end;

    procedure UpdateNLTEmployeeInAlaan(NLTEmployee: Record NLTEmployee) Response: JsonObject
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
        NLTEmployeeIDTXT: Text;
    begin
        NLTEmployeeIDTXT := DelChr(NLTEmployee."Employee ID", '=', '{}');
        URL := StrSubstNo('%1/expense-tracking-tags/%2/items/%3', AlaanAPIMGT.GetBaseURL(), GetExpenseTagID(NLTEmployee.DIMEmpCode), NLTEmployeeIDTXT);
        JsonObject.Add('name', NLTEmployee.Name);
        JsonObject.Add('accountingReference', 'TG-123');
        JsonObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'PATCH');
        exit(Response);
    end;

    procedure DeleteNLTEmployeeFromAlaan(NLTEmployee: Record NLTEmployee)
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        URL: Text;
        NLTEmployeeIDTXT: Text;
        Guid: Guid;
    begin
        NLTEmployeeLog.Init();
        NLTEmployeeLog.Validate(BC_Emp_Dim_Code, NLTEmployee.DIMEmpCode);
        NLTEmployeeLog.Validate(NLT_Emp_Code, NLTEmployee.Code);
        NLTEmployeeLog.Validate(Name, NLTEmployee.Name);
        NLTEmployeeLog.Validate(SyncType, NLTEmployeeLog.SyncType::"To Alaan");
        NLTEmployeeLog.Validate(ActionType, NLTEmployeeLog.ActionType::Delete);
        NLTEmployeeLog.Validate(NLTEmployeeId, NLTEmployee."Employee ID");
        NLTEmployeeLog.Validate("Sync Date & Time", CurrentDateTime);
        NLTEmployeeLog.Insert();

        if AlaanAPIMGT.CheckRecordIsInTransaction(NLTEmployee."Employee ID", 'EMPLOYEE') then begin
            NLTEmployeeLog."Error Message" := 'Record is mapped with some Transaction. You can not Delete it';
            NLTEmployeeLog.Modify();
            Error('Record is mapped with some Transaction. You can not Delete it');
        end;


        NLTEmployeeIDTXT := DelChr(NLTEmployee."Employee ID", '=', '{}');
        URL := StrSubstNo('%1/expense-tracking-tags/%2/items/%3', AlaanAPIMGT.GetBaseURL(), GetExpenseTagID(NLTEmployee.DIMEmpCode), NLTEmployeeIDTXT);
        JsonObject := AlaanAPIMGT.CallDeleteAPI(CompanyProperty.ID(), URL);

        if JsonObject.Get('status', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                NLTEmployeeLog.IsError := true;
                if JsonObject.Get('message', JsonToken) then begin
                    if not JsonToken.AsValue().IsNull then
                        NLTEmployeeLog."Error Message" := JsonToken.AsValue().AsText();
                end;
                NLTEmployeeLog.Modify();
            end
            else begin
                NLTEmployee."Sync With Alaan" := false;
                NLTEmployee."Synced With Alaan" := false;
                NLTEmployee.Validate("Employee ID", Guid);
                NLTEmployee."Last Synced with Alaan" := CurrentDateTime;
                if NLTEmployee.Modify() then
                    Message('Alaan User : %1 deleted Successfully', NLTEmployee.Name);
            end;
    end;



    local procedure GetExpenseTagID(DimensionCode: Code[20]) DimensionTXT: Text
    var
        Dimension: Record Dimension;
    begin

        if (Dimension.Get(DimensionCode)) and (not IsNullGuid(Dimension.AlaanID)) then begin
            DimensionTXT := DelChr(Dimension.AlaanID, '=', '{}');
            exit(DimensionTXT);
        end
        else
            Error('Expense Code is not Connected');
    end;

    var
        AlaanAPIMGT: Codeunit "Alaan API MGT";
        NLTEmployeeLog: Record "NLT Employee - Alaan Logs";
        AlaanSetup: Record "NLT - Alaan Setup";
}