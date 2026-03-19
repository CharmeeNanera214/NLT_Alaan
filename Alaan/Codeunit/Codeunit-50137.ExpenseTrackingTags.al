codeunit 50137 "Expense Tracking Tags API"
{
    procedure SyncExpensetrackingTag(Dimension: Record Dimension)
    var
        JsonObject: JsonObject;
        JsonObj: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
        Response: JsonObject;
        AlaanID: Guid;
    begin
        Clear(ExpTracTagLog);
        ExpTracTagLog.Init();
        ExpTracTagLog.SyncType := ExpTracTagLog.SyncType::"To Alaan";
        ExpTracTagLog."Sync Date & Time" := CurrentDateTime;
        ExpTracTagLog."Dimension Code" := Dimension.Code;
        ExpTracTagLog.TagName := Dimension.Name;
        ExpTracTagLog.Insert();
        if IsNullGuid(Dimension.AlaanID) then begin
            if CreateNewExpenseTrackingTag(Dimension) then begin
                Dimension.Validate(AlaanID, ExpTracTagLog.ExpTracTagID);
                Dimension."Synced With Alaan" := true;
                Dimension."Last Synced with Alaan" := CurrentDateTime;
                if Dimension.Modify() then Message('Expense Tracking Tag : %1 Connected successfully with Alaan', Dimension.Name);
            end
            else
                Message('Expense Tracking Tag %1 was not Connected  with Alaan. For more details, see logs.', Dimension.Name);
        end
        else begin
            if UpdateNewExpenseTrackingTag(Dimension) then begin
                Dimension."Synced With Alaan" := true;
                Dimension."Last Synced with Alaan" := CurrentDateTime;
                if Dimension.Modify() then Message('Expense Tracking Tag : %1 Connected successfully with Alaan', Dimension.Name);
            end
            else
                Message('Expense Tracking Tag %1 was not Connected with Alaan. For more details, see logs.', Dimension.Name);
        end;
    end;

    local procedure CreateNewExpenseTrackingTag(Dimension: Record Dimension): Boolean
    var
        JsonObject: JsonObject;
        JsonObj: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
        Response: JsonObject;
        AlaanID: Guid;
    begin
        URL := StrSubstNo('%1/expense-tracking-tags', AlaanAPIMGT.GetBaseURL());
        JsonObject.Add('name', Dimension.Name);
        JsonObject.Add('fieldType', 'SINGLE_SELECT');
        JsonArray.Add(JsonObject);
        JsonObj.Add('expenseTrackingTags', JsonArray);
        JsonObj.WriteTo(BodyText);

        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'POST');

        if Response.Get('status', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                ExpTracTagLog.IsError := true;
                if Response.Get('message', JsonToken) then
                    if not JsonToken.AsValue().IsNull then
                        ExpTracTagLog."Error Message" := JsonToken.AsValue().AsText();
                if Response.Get('errorType', JsonToken) then
                    if not JsonToken.AsValue().IsNull then
                        ExpTracTagLog."Error Type" := JsonToken.AsValue().AsText();
                if ExpTracTagLog.Modify() then
                    exit(false);
            end;

        if Response.Get('entity', JsonToken) then
            JsonArray := JsonToken.AsArray();

        Clear(JsonObject);
        if JsonArray.Get(0, JsonToken) then JsonObject := JsonToken.AsObject();

        if JsonObject.Get('id', JsonToken) then
            if not JsonToken.AsValue().IsNull then
                Evaluate(ExpTracTagLog.ExpTracTagID, JsonToken.AsValue().AsText());


        if JsonObject.Get('corporateId', JsonToken) then
            if not JsonToken.AsValue().IsNull then
                Evaluate(ExpTracTagLog.CorporateID, JsonToken.AsValue().AsText());

        if JsonObject.Get('name', JsonToken) then
            if not JsonToken.AsValue().IsNull then
                ExpTracTagLog.TagName := JsonToken.AsValue().AsText();

        if JsonObject.Get('fieldType', JsonToken) then
            if not JsonToken.AsValue().IsNull then
                ExpTracTagLog.FieldType := JsonToken.AsValue().AsText();

        if JsonObject.Get('isActive', JsonToken) then
            ExpTracTagLog.IsActive := JsonToken.AsValue().AsBoolean();

        if JsonObject.Get('isEmployeeLevel', JsonToken) then
            ExpTracTagLog.IsEmployeeLevel := JsonToken.AsValue().AsBoolean();

        ExpTracTagLog.IsError := false;
        ExpTracTagLog.ActionType := ExpTracTagLog.ActionType::Create;
        if ExpTracTagLog.Modify() then
            exit(true);
    end;

    local procedure UpdateNewExpenseTrackingTag(Dimension: Record Dimension): Boolean
    var
        JsonObject: JsonObject;
        JsonObj: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
        Response: JsonObject;
        AlaanID: Guid;
        AlaanIDTXT: Text;
    begin
        AlaanIDTXT := DelChr(Dimension.AlaanID.ToText(), '=', '{}');
        URL := StrSubstNo('%1/expense-tracking-tags/%2', AlaanAPIMGT.GetBaseURL(), AlaanIDTXT);
        JsonObject.Add('name', Dimension.Name);
        JsonObject.WriteTo(BodyText);

        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'PUT');
        ExpTracTagLog.ActionType := ExpTracTagLog.ActionType::Update;
        if Response.Get('status', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                ExpTracTagLog.IsError := true;
                if Response.Get('message', JsonToken) then begin
                    if JsonToken.IsArray then begin
                        JsonArray := JsonToken.AsArray();
                        if JsonArray.Get(0, JsonToken) then
                            ExpTracTagLog."Error Message" := JsonToken.AsValue().AsText();
                    end;
                end;
                if Response.Get('errorType', JsonToken) then
                    ExpTracTagLog."Error Type" := JsonToken.AsValue().AsText();
                if ExpTracTagLog.Modify() then
                    exit(false);
            end
            else
                exit(true);
    end;

    procedure DeleteExpenseTrackingTag(Dimension: Record Dimension)
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        URL: Text;
        AlaanIDTXT: Text;
        Guid: Guid;
    begin

        // check entries

        ExpTracTagLog.Init();
        ExpTracTagLog.ActionType := ExpTracTagLog.ActionType::Delete;
        ExpTracTagLog.SyncType := ExpTracTagLog.SyncType::"To Alaan";
        ExpTracTagLog."Sync Date & Time" := CurrentDateTime;
        ExpTracTagLog.TagName := Dimension.Name;
        ExpTracTagLog."Dimension Code" := Dimension.Code;
        ExpTracTagLog.Insert();

        if AlaanAPIMGT.CheckRecordIsInTransaction(Dimension.AlaanID, 'TAG') then begin
            ExpTracTagLog."Error Message" := 'Dimension is mapped with some Transaction. You can not Delete it';
            ExpTracTagLog.Modify();
            Error('Dimension is mapped with some Transaction. You can not Delete it');
        end;


        AlaanIDTXT := DelChr(Dimension.AlaanID.ToText(), '=', '{}');
        URL := StrSubstNo('%1/expense-tracking-tags/%2', AlaanAPIMGT.GetBaseURL(), AlaanIDTXT);
        JsonObject := AlaanAPIMGT.CallDeleteAPI(CompanyProperty.ID(), URL);

        if JsonObject.Get('status', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                ExpTracTagLog.IsError := true;
                if JsonObject.Get('message', JsonToken) then begin
                    JsonArray := JsonToken.AsArray();
                    if JsonArray.Get(0, JsonToken) then
                        ExpTracTagLog."Error Message" := JsonToken.AsValue().AsText();
                end;
                ExpTracTagLog.Modify();
            end
            else begin
                Dimension."Sync With Alaan" := false;
                Dimension."Synced With Alaan" := false;
                Dimension.Validate(AlaanID, Guid);
                Dimension."Last Synced with Alaan" := CurrentDateTime;
                if Dimension.Modify() then
                    Message('Expense Tracking Tag : %1 deleted Successfully from Alaan', Dimension.Code);
            end;
    end;


    var
        AlaanAPIMGT: Codeunit "Alaan API MGT";
        ExpTracTagLog: Record "Exp. Tracking Tags - Alaan log";
}