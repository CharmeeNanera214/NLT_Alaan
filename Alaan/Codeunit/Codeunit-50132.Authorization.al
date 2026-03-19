codeunit 50132 "Authorization"
{
    procedure GetAccessToken(ComID: Guid): Text[250]
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
        JsonToken: JsonToken;
        BodyText: Text;
        AccessToken: Text;
        RefreshToken: Text;
        URL: Text;
        grant: text;
        status: Text;
    begin
        Clear(ClientID);
        Clear(ClientSecret);
        ClientID := AlaanAPIMGT.CompanyCredentials(ComID, true);
        ClientSecret := AlaanAPIMGT.CompanyCredentials(ComID, false);
        URL := StrSubstNo('%1/token', AlaanAPIMGT.GetBaseURL());
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(URL);
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('x-client-id', ClientID);
        Headers.Add('x-client-secret', ClientSecret);
        Headers.Add('Accept', 'application/json');
        Content.GetHeaders(contentHeader);

        // create JSON Object for Grant type and write it into grant variable
        JsonObject.Add('grantType', 'authorization_code');
        JsonObject.AsToken().WriteTo(grant);

        // add JSON Object iunto Content Header
        Content.WriteFrom(grant);

        contentHeader.Clear();
        contentHeader.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content := Content;
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode then begin
                Clear(JsonObject);
                HttpResponseMessage.Content.ReadAs(BodyText);
                JsonObject.ReadFrom(BodyText);
                JsonObject.Get('status', JsonToken);
                JsonToken.WriteTo(status);
                if status = 'true' then begin
                    JsonObject.get('entity', JsonToken);
                    JsonObject := JsonToken.AsObject();
                    JsonObject.Get('accessToken', JsonToken);
                    AccessToken := JsonToken.AsValue().AsText();
                    exit(AccessToken);
                end;
            end
            else
                Error('Unable to get access token ' + HttpResponseMessage.HttpStatusCode.ToText());
        end;
    end;

    var
        CompCre: Record "NLT - Alaan Setup";
        AlaanAPIMGT: Codeunit "Alaan API MGT";
}