codeunit 50131 "Alaan API MGT"
{
    /* Get companies client key and secret key*/
    procedure CompanyCredentials(compID: Guid; GetClientID: Boolean): Text[100]
    var
        compInfo: Record "Company Information";
        company: Record Company;
    begin
        CompanyCredemtials.Reset();
        if not CompanyCredemtials.Get(compID) then
            Error('No info for current company')
        else begin
            if GetClientID then
                exit(CompanyCredemtials.ClientID)
            else
                exit(CompanyCredemtials.ClientSecret);
        end;
    end;

    /* Get base url based on company*/
    procedure GetBaseURL(): Text[250]
    var
        compInfo: Record "Company Information";
        company: Record Company;
    begin
        if CompanyName = 'OPTIMAL ENGINEERING SOLUTIONS' then
            exit(SaudiBaseURL)
        else if (CompanyName = 'NuLumenTek Trading LLC') or (CompanyName = 'NuLumenTek MENA Limited') then
            exit(UAEBaseURL)
        else
            Error('Company is Not Allow to Connect with Alaan');
    end;

    /*  Procedure return JSON Token of API response. 
        It contains response dta for API which has been Called by this procedure. 
        Procedure Call GET API of Alaan to request data.
    */
    procedure CallGetAPI(CompId: Guid; URL: Text; DataCodesTXT: Text) Response: JsonObject
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        ResponseData: Text;
        AccessToken: Text;
    begin
        AccessToken := Authorization.GetAccessToken(CompId);
        HttpRequestMessage.Method('GET');
        HttpRequestMessage.SetRequestUri(URL);
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Accept', 'application/json');
        Headers.Add('x-access-token', AccessToken);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode then begin
                Clear(Response);
                HttpResponseMessage.Content.ReadAs(ResponseData);
                Response.ReadFrom(ResponseData);
                exit(Response);
            end
            else
                Error('Unable to get data ' + HttpResponseMessage.ReasonPhrase);
        end;
    end;



    /*  Procedure return JSON Token of API response. 
        It contains response data for API which has been Called by this procedure. 
        Procedure Call Post or Patch API of Alaan to Create or Update data.
    */
    procedure CallPostOrPatchAPI(CompId: Guid; URL: Text; BodyText: Text; RequestType: Code[5]) Response: JsonObject
    var
        ClientID: Text[100];
        ClientSecret: Text[100];
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        contentHeader: HttpHeaders;
        Content: HttpContent;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        AccessToken: Text;
        ResponseData: Text;
    begin
        AccessToken := Authorization.GetAccessToken(CompanyProperty.ID());
        HttpRequestMessage.Method(RequestType);
        HttpRequestMessage.SetRequestUri(URL);
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Accept', 'application/json');
        Headers.Add('x-access-token', AccessToken);

        Clear(Content);
        Clear(contentHeader);
        Content.WriteFrom(BodyText);
        Content.GetHeaders(contentHeader);
        if contentHeader.Contains('Content-Type') then contentHeader.Remove('Content-Type');
        contentHeader.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content := Content;

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode then begin
                Clear(ResponseData);
                HttpResponseMessage.Content.ReadAs(ResponseData);
                Clear(Response);
                Response.ReadFrom(ResponseData);
                exit(Response);
            end
            else
                Error(StrSubstNo('Call Failed : %1', HttpResponseMessage.HttpStatusCode));
        end
        else
            Error('Post request failed');
    end;

    procedure CallDeleteAPI(CompId: Guid; URL: Text) Response: JsonObject
    var
        ClientID: Text[100];
        ClientSecret: Text[100];
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        contentHeader: HttpHeaders;
        Content: HttpContent;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        AccessToken: Text;
        ResponseData: Text;
    begin
        AccessToken := Authorization.GetAccessToken(CompanyProperty.ID());
        HttpRequestMessage.Method('DELETE');
        HttpRequestMessage.SetRequestUri(URL);
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Accept', 'application/json');
        Headers.Add('x-access-token', AccessToken);

        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode then begin
                Clear(ResponseData);
                HttpResponseMessage.Content.ReadAs(ResponseData);
                Clear(Response);
                Response.ReadFrom(ResponseData);
                exit(Response);
            end
            else
                Error(StrSubstNo('Delete Call Failed : %1', HttpResponseMessage.HttpStatusCode));
        end
        else
            Error('Delete request failed');
    end;



    procedure CheckRecordIsInTransaction(RecGuid: Guid; RecType: Code[20]): Boolean
    var
        TranHeader: Record "Transactions - Alaan";
        TranLine: Record "Transaction Line - Alaan";
    begin
        case RecType of
            'EXPENSECAT':
                begin
                    TranLine.SetFilter("Expense Category ID", RecGuid);
                    if TranLine.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            'VENDOR':
                begin
                    TranHeader.SetFilter(SupplierID, RecGuid);
                    if TranHeader.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            'TAXCODE':
                begin
                    TranLine.SetFilter("Tax Code ID", RecGuid);
                    if TranLine.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            'EMPLOYEE':
                begin
                    TranLine.SetFilter("Tag Group Item ID", RecGuid);
                    if TranLine.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
            'TAG':
                begin
                    TranLine.SetFilter("Tag Group ID", RecGuid);
                    if TranLine.FindFirst() then
                        exit(true)
                    else
                        exit(false);
                end;
        end;
    end;


    var
        CompanyCredemtials: Record "NLT - Alaan Setup";
        Authorization:
                Codeunit Authorization;
        AlaanAPIMGT:
                Codeunit "Alaan API MGT";
        SaudiBaseURL:
                Label 'https://openapi.sa.alaanpay.com/athena';
        // SaudiBaseURL: Label 'https://openapi.stage.alaanpay.com/athena';
        UAEBaseURL:
                Label 'https://openapi.alaanpay.com/athena';
    // UAEBaseURL: Label 'https://openapi.stage.alaanpay.com/athena';
}