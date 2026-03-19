codeunit 50135 "Tax Codes API"
{
    trigger OnRun()
    begin
        SyncTaxCodesToAlaan('', true);
    end;

    procedure SyncTaxCodesToAlaan(TaxCode: Code[45]; SyncAll: Boolean)
    var
        VATPostingCode: Record "VAT Posting Setup";
    begin
        VATPostingCode.Reset();
        if not SyncAll then
            VATPostingCode.SetFilter("Alaan Tax Code", TaxCode);
        VATPostingCode.SetRange("Sync With Alaan", true);
        // VATPostingCode.SetRange("Synced With Alaan", false);
        VATPostingCode.SetRange(Blocked, false);
        if VATPostingCode.FindSet() then
            repeat
                if SyncTaxCodes(VATPostingCode) then begin
                    if not TaxCodes.IsError then begin
                        VATPostingCode."Synced With Alaan" := true;
                        VATPostingCode.Validate("Alaan Tax Code Id", TaxCodes.TaxCodeID);
                        VATPostingCode."Last Synced with Alaan" := CurrentDateTime;
                        VATPostingCode.Modify();
                        if GuiAllowed then
                            if not SyncAll then Message('Tax Code Connected Successfully');
                    end
                    else
                        if GuiAllowed then
                            if not SyncAll then Message('Tax Code not Connected');
                end
                else begin
                    TaxCodes.IsError := true;
                    Evaluate(TaxCodes."Error Message", GetLastErrorText());
                    TaxCodes.Modify();
                    if GuiAllowed then
                        if not SyncAll then Message('Tax Code not Connected');
                end;
            until VATPostingCode.Next() = 0
        else
            if GuiAllowed then
                Message('No Tax Codes found to Connect');
    end;

    [TryFunction]
    local procedure SyncTaxCodes(VATPostingCode: Record "VAT Posting Setup")
    var
        Response: JsonObject;
        JsonObj: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
        ObjValue: Text;
    begin
        // Supplier.Reset();
        Clear(TaxCodes);
        TaxCodes.Init();
        TaxCodes.Validate(BC_Tax_Code, VATPostingCode."Alaan Tax Code");
        TaxCodes.Validate(Name, VATPostingCode.Description);
        TaxCodes.Validate(Rate, VATPostingCode."VAT %");
        TaxCodes.Validate(SyncType, TaxCodes.SyncType::"To Alaan");
        TaxCodes.Validate(TaxCodeID, VATPostingCode."Alaan Tax Code Id");
        TaxCodes.Validate("Sync Date & Time", CurrentDateTime);
        TaxCodes.Insert();

        if IsNullGuid(VATPostingCode."Alaan Tax Code Id") then begin
            TaxCodes.ActionType := TaxCodes.ActionType::Create;
            Response := CreateTaxCodeInAlaan(VATPostingCode);
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
                            TaxCodes."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then begin
                        if not JsonToken.AsValue().IsNull then
                            TaxCodes."Error Message" := JsonToken.AsValue().AsText();
                    end;
                    TaxCodes.IsError := true;
                    TaxCodes.Modify();
                end;

            if Response.Get('id', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(TaxCodes.TaxCodeID, JsonToken.AsValue().AsText());
            if Response.Get('code', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(TaxCodes.BC_Tax_Code, JsonToken.AsValue().AsText());
            if Response.Get('rate', JsonToken) then
                TaxCodes.Rate := JsonToken.AsValue().AsDecimal();
            if Response.Get('corporateId', JsonToken) then
                if not JsonToken.AsValue().IsNull then
                    Evaluate(TaxCodes.CorporateId, JsonToken.AsValue().AsText());
            if Response.Get('isDeleted', JsonToken) then
                TaxCodes.IsDeleted := JsonToken.AsValue().AsBoolean();

            if Response.Get('name', JsonToken) then begin
                Clear(ObjValue);
                JsonToken.WriteTo(ObjValue);
                if ObjValue <> 'null' then
                    Evaluate(TaxCodes.Name, JsonToken.AsValue().AsText());
            end;

            if Response.Get('partnerTaxCodeId', JsonToken) then begin
                Clear(ObjValue);
                JsonToken.WriteTo(ObjValue);
                if ObjValue <> 'null' then
                    Evaluate(TaxCodes.Name, JsonToken.AsValue().AsText());
            end;
            if Response.Get('partnerTaxRateStatus', JsonToken) then begin
                Clear(ObjValue);
                JsonToken.WriteTo(ObjValue);
                if ObjValue <> 'null' then
                    Evaluate(TaxCodes.Name, JsonToken.AsValue().AsText());
            end;
            if Response.Get('accountingCompanyId', JsonToken) then begin
                Clear(ObjValue);
                JsonToken.WriteTo(ObjValue);
                if ObjValue <> 'null' then
                    Evaluate(TaxCodes.Name, JsonToken.AsValue().AsText());
            end;
            // if Response.Get('partnerTaxCodeId', JsonToken) then
            //     Evaluate(TaxCodes.PartnerTaxCodeId, JsonToken.AsValue().AsText());
            // if Response.Get('partnerTaxRateStatus', JsonToken) then
            //     Evaluate(TaxCodes.partnerTaxRateStatus, JsonToken.AsValue().AsText());
            // if Response.Get('accountingCompanyId', JsonToken) then
            //     Evaluate(TaxCodes.accountingCompanyId, JsonToken.AsValue().AsText());

            TaxCodes.Modify()
        end
        else begin
            TaxCodes.ActionType := TaxCodes.ActionType::Update;
            Response := UpdateTaxCodeInAlaan(VATPostingCode);
            if Response.Get('status', JsonToken) then
                if not JsonToken.AsValue().AsBoolean() then begin
                    if Response.get('errorType', JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            TaxCodes."Error Type" := JsonToken.AsValue().AsText();
                    if Response.get('message', JsonToken) then begin
                        if JsonToken.IsArray then JsonArray := JsonToken.AsArray();
                        if JsonArray.Get(0, JsonToken) then
                            if not JsonToken.AsValue().IsNull then
                                TaxCodes."Error Message" := JsonToken.AsValue().AsText();
                    end;
                    TaxCodes.IsError := true;
                end;
            TaxCodes.Modify();
        end;
    end;

    procedure CreateTaxCodeInAlaan(VATPostingCode: Record "VAT Posting Setup") Response: JsonObject
    var
        JsonObject: JsonObject;
        TaxCodesArray: JsonArray;
        TaxCodeObj: JsonObject;
        BodyText: Text;
        URL: Text;
    begin
        URL := StrSubstNo('%1/tax-codes', AlaanAPIMGT.GetBaseURL());
        // Create the inner tax code object
        TaxCodeObj.Add('code', VATPostingCode."Alaan Tax Code");
        TaxCodeObj.Add('name', VATPostingCode.Description);
        TaxCodeObj.Add('rate', VATPostingCode."VAT %");

        // Add tax code object to array
        TaxCodesArray.Add(TaxCodeObj);

        // Wrap inside root object
        JsonObject.Add('taxCodes', TaxCodesArray);

        // Write to text variable
        JsonObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'POST');
        exit(Response);
    end;

    procedure UpdateTaxCodeInAlaan(VATPostingCode: Record "VAT Posting Setup") Response: JsonObject
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        BodyText: Text;
        URL: Text;
        SupplierIDTXT: Text;
    begin
        SupplierIDTXT := DelChr(VATPostingCode."Alaan Tax Code Id".ToText(), '=', '{}');
        URL := StrSubstNo('%1/tax-codes/%2', AlaanAPIMGT.GetBaseURL(), SupplierIDTXT);

        // Add fields to JSON
        JsonObject.Add('code', VATPostingCode."Alaan Tax Code");
        JsonObject.Add('name', VATPostingCode.Description);
        JsonObject.Add('rate', VATPostingCode."VAT %"); // stored as string

        JsonObject.WriteTo(BodyText);
        Response := AlaanAPIMGT.CallPostOrPatchAPI(CompanyProperty.ID(), URL, BodyText, 'PATCH');
        exit(Response);
    end;


    procedure DeleteTaxCode(VATTaxCode: Record "VAT Posting Setup")
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        URL: Text;
        AlaanIDTXT: Text;
        Guid: Guid;
    begin

        // check entries

        TaxCodes.Init();
        TaxCodes.ActionType := TaxCodes.ActionType::Delete;
        TaxCodes.SyncType := TaxCodes.SyncType::"To Alaan";
        TaxCodes."Sync Date & Time" := CurrentDateTime;
        TaxCodes.Name := VATTaxCode.Description;
        TaxCodes.BC_Tax_Code := VATTaxCode."Alaan Tax Code";
        TaxCodes.Insert();

        if AlaanAPIMGT.CheckRecordIsInTransaction(VATTaxCode."Alaan Tax Code Id", 'TAXCODE') then begin
            TaxCodes."Error Message" := 'Tax Code is mapped with some Transaction. You can not Delete it';
            TaxCodes.Modify();
            Error('Tax Code is mapped with some Transaction. You can not Delete it');
        end;

        AlaanIDTXT := DelChr(VATTaxCode."Alaan Tax Code Id".ToText(), '=', '{}');
        URL := StrSubstNo('%1/tax-codes/%2', AlaanAPIMGT.GetBaseURL(), AlaanIDTXT);
        JsonObject := AlaanAPIMGT.CallDeleteAPI(CompanyProperty.ID(), URL);

        if JsonObject.Get('status', JsonToken) then
            if not JsonToken.AsValue().AsBoolean() then begin
                TaxCodes.IsError := true;
                if JsonObject.Get('message', JsonToken) then begin
                    JsonArray := JsonToken.AsArray();
                    if JsonArray.Get(0, JsonToken) then
                        if not JsonToken.AsValue().IsNull then
                            TaxCodes."Error Message" := JsonToken.AsValue().AsText();
                end;
                TaxCodes.Modify();
            end
            else begin
                VATTaxCode."Sync With Alaan" := false;
                VATTaxCode."Synced With Alaan" := false;
                VATTaxCode.Validate("Alaan Tax Code Id", Guid);
                VATTaxCode."Last Synced with Alaan" := CurrentDateTime;
                if VATTaxCode.Modify() then
                    Message('Tax Code : %1 deleted Successfully from Alaan', VATTaxCode."Alaan Tax Code");
            end;
    end;

    var
        AlaanAPIMGT: Codeunit "Alaan API MGT";
        TaxCodes: Record "Tax Code - Alaan Logs";
}