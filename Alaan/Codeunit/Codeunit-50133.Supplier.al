codeunit 50133 "Supplier API"
{
    trigger OnRun()
    begin
        SyncSupplierToAlaan('', true);
    end;

    procedure SyncSupplierToAlaan(VendorNo: Code[20]; SyncAll: Boolean)
    var
        Vendor: Record Vendor;
    begin
        Vendor.Reset();
        if not SyncAll then
            Vendor.SetFilter("No.", VendorNo);
        Vendor.SetRange("Sync With Alaan", true);
        // Vendor.SetRange("Synced With Alaan", false);
        if Vendor.FindSet() then
            repeat
                if SyncSupplier(Vendor) then begin
                    if not Supplier.IsError then begin
                        Vendor."Synced With Alaan" := true;
                        Vendor.Validate("Supplier Id", Supplier.SupplierId);
                        Vendor."Last Synced with Alaan" := CurrentDateTime;
                        Vendor.Modify();
                        if GuiAllowed then
                            if not SyncAll then Message('Vendor Connected Successfully');
                    end
                    else
                        if GuiAllowed then
                            if not SyncAll then Message('Vendor not Connected');

                end
                else begin
                    Supplier.IsError := true;
                    Evaluate(Supplier."Error Message", GetLastErrorText());
                    Supplier.Modify();
                    if GuiAllowed then
                        if not SyncAll then Message('Vendor not Connected');
                end;
            until Vendor.Next() = 0
        else
            if GuiAllowed then
                Message('No Vendor Found to connect');
    end;


    [TryFunction]
    local procedure SyncSupplier(Vendor: Record Vendor)
    var
        Response: JsonObject;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
    begin
        // Supplier.Reset();
        Clear(Supplier);
        Supplier.Init();
        Supplier.Validate(BC_Vendor_NO, Vendor."No.");
        Supplier.Validate(partnerSupplierName, Vendor.Name);
        Supplier.Validate(status, Format(Vendor."Privacy Blocked"));
        Supplier.Validate(SyncType, Supplier.SyncType::"To Alaan");
        Supplier.Validate(SupplierId, Vendor."Supplier Id");
        Supplier.Validate("Sync Date & Time", CurrentDateTime);
        Supplier.Insert();

        if IsNullGuid(Vendor."Supplier Id") then begin
            Supplier.ActionType := Supplier.ActionType::Create;
            Response := CreateSupllierInAlaan(Vendor);
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
                        Supplier."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then begin
                        if JsonToken.IsArray then JsonArray := JsonToken.AsArray();
                        if JsonArray.Get(0, JsonToken) then
                            if not JsonToken.AsValue().IsNull then
                                Supplier."Error Message" := JsonToken.AsValue().AsText();
                    end;
                    Supplier.IsError := true;
                    Supplier.Modify();
                    // exit(false);
                end;

            if Response.Get('id', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(Supplier.SupplierId, JsonToken.AsValue().AsText());

            if Response.Get('creationType', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(Supplier.creationType, JsonToken.AsValue().AsText());

            if Response.Get('corporateId', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(Supplier.CorporateId, JsonToken.AsValue().AsText());

            if Response.Get('partnerSupplierName', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(Supplier.PartnerSupplierName, JsonToken.AsValue().AsText());

            if Response.Get('companyId', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(Supplier.CompanyId, JsonToken.AsValue().AsText());

            if Response.Get('status', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(Supplier.Status, JsonToken.AsValue().AsText());
            // if Supplier.Modify() then exit(true) else exit(false);
            Supplier.Modify()
        end
        else begin
            Supplier.ActionType := Supplier.ActionType::Update;
            Response := UpdateSupllierInAlaan(Vendor);
            if Response.Get('status', JsonToken) then
                if not JsonToken.AsValue().AsBoolean() then begin
                    if Response.get('errorType', JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            Supplier."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then begin
                        if JsonToken.IsArray then JsonArray := JsonToken.AsArray();
                        if JsonArray.Get(0, JsonToken) then
                            if not JsonToken.AsValue().IsNull then
                                Supplier."Error Message" := JsonToken.AsValue().AsText();
                    end;
                    Supplier.IsError := true;
                    // exit(false);
                end;
            // else
            Supplier.Modify();
            //     exit(true);
        end;
    end;

    //POST Request for create new supplier in Alaan
    procedure CreateSupllierInAlaan(Vendor: Record Vendor) Response: JsonObject
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
    begin
        URL := StrSubstNo('%1/suppliers', AlaanAPIMGT.GetBaseURL());
        JsonObject.Add('id', Vendor."No.");
        JsonObject.Add('name', Vendor.Name);
        JsonArray.Add(JsonObject);
        Clear(JsonObject);
        JsonObject.Add('suppliers', JsonArray);
        JsonObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'POST');
        exit(Response);
    end;

    procedure UpdateSupllierInAlaan(Vendor: Record Vendor) Response: JsonObject
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
        SupplierIDTXT: Text;
    begin
        SupplierIDTXT := DelChr(Vendor."Supplier Id".ToText, '=', '{}');
        URL := StrSubstNo('%1/suppliers/%2', AlaanAPIMGT.GetBaseURL(), SupplierIDTXT);
        JsonObject.Add('name', Vendor.Name);
        if Vendor."Privacy Blocked" then
            JsonObject.Add('status', 'DISABLED')
        else
            JsonObject.Add('status', 'ACTIVE');
        JsonObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'PATCH');
        exit(Response);
    end;


    procedure DeleteSupplierFromAlaan(vendor: Record Vendor)
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        URL: Text;
        SupplierIDTXT: Text;
        Guid: Guid;
    begin

        // check entries

        Supplier.Init();
        Supplier."Sync Date & Time" := CurrentDateTime;
        Supplier.SyncType := Supplier.SyncType::"To Alaan";
        Supplier.ActionType := Supplier.ActionType::Delete;
        Supplier.BC_Vendor_NO := vendor."No.";
        Supplier.partnerSupplierName := vendor.Name;
        Supplier.SupplierId := vendor."Supplier Id";
        Supplier.Insert();

        if AlaanAPIMGT.CheckRecordIsInTransaction(vendor."Supplier Id", 'VENDOR') then begin
            Supplier."Error Message" := 'Vendor is mapped with some Transaction. You can not Delete it';
            Supplier.Modify();
            Error('Vendor is mapped with some Transaction. You can not Delete it');
        end;

        SupplierIDTXT := DelChr(Vendor."Supplier Id".ToText, '=', '{}');
        URL := StrSubstNo('%1/suppliers/%2', AlaanAPIMGT.GetBaseURL(), SupplierIDTXT);
        JsonObject := AlaanAPIMGT.CallDeleteAPI(CompanyProperty.ID(), URL);

        if JsonObject.Get('status', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                Supplier.IsError := true;
                if JsonObject.Get('message', JsonToken) then begin
                    JsonArray := JsonToken.AsArray();
                    if JsonArray.Get(0, JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            Supplier."Error Message" := JsonToken.AsValue().AsText();

                end;
                Supplier.Modify();
            end
            else begin
                vendor."Sync With Alaan" := false;
                vendor."Synced With Alaan" := false;
                // vendor."Supplier Id" := Guid;
                vendor."Last Synced with Alaan" := CurrentDateTime;
                if vendor.Modify() then
                    Message('Vendor %1 Disabled Successfully', vendor.Name);
            end;
    end;

    var
        AlaanAPIMGT: Codeunit "Alaan API MGT";
        Supplier: Record "Supplier - Alaan Logs";

}