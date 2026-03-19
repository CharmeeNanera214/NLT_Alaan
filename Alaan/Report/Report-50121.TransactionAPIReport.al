report 50121 "Transaction MGT API"
{
    ProcessingOnly = true;
    Caption = 'Transaction API';
    AllowScheduling = true;
    dataset
    {
        dataitem(Integer; Integer)
        {
            column(FromDate; FromDate)
            {

            }
            column(ToDate; ToDate)
            {

            }
            column(withReceipt; withReceipt)
            {

            }
            column(Status; Status)
            {

            }
            column(adminStatus; adminStatus)
            {

            }
            column(txnClearingStatus; txnClearingStatus)
            {

            }
            trigger OnPreDataItem()
            begin
                CallTransactionFetchAPI();
                Commit();
                CurrReport.Quit();

            end;
        }
    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';
        layout
        {
            area(Content)
            {

                group(GroupName)
                {

                    field(MerchantName; MerchantName)
                    {
                        Caption = 'Merchant';
                        ApplicationArea = All;

                        trigger OnAssistEdit()
                        var
                            TxnList: Page "Transactions - Alaan";
                            TxnRec: Record "Transactions - Alaan";
                            NullGuid: Guid;
                        begin
                            if TxnRec.IsEmpty then
                                Error('There is No transaction in Business central');

                            TxnList.SetTableView(TxnRec);
                            TxnList.LookupMode(true);
                            TxnList.Editable(false);


                            if TxnList.RunModal() = Action::LookupOK then begin
                                TxnList.GetRecord(TxnRec);
                                MerchantName := TxnRec."Merchant Name";
                                id := TxnRec.TransactionId;
                                if not IsNullGuid(id) then begin
                                    Edit := false;
                                    FromDate := CreateDateTime(0D, 0T);
                                    ToDate := CreateDateTime(0D, 0T);
                                    Status := Status::" ";
                                    employeeEmails := '';
                                    // adminStatus := adminStatus::" ";
                                    // txnClearingStatus := txnClearingStatus::" ";
                                end;
                            end
                            else begin
                                MerchantName := '';
                                id := NullGuid;
                                edit := true;
                            end;
                        end;

                    }

                    field(id; id)
                    {
                        Caption = 'Transaction ID';
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field(employeeEmails; employeeEmails)
                    {
                        ApplicationArea = All;
                        Caption = 'Employees';
                        Editable = edit;
                        trigger OnAssistEdit()
                        var
                            Employee: Record Employee;
                            EmployeeList: Page "Employee List";
                            email: Text[80];
                        begin
                            Employee.SetRange("Alaan Employee", true);
                            Employee.LoadFields("No.", "First Name", "Last Name", "E-Mail", Status);
                            Employee.FindFirst();
                            EmployeeList.LookupMode(true);
                            EmployeeList.SetTableView(Employee);
                            EmployeeList.Editable(false);
                            if EmployeeList.RunModal() = Action::LookupOK then begin
                                EmployeeList.SetSelectionFilter(Employee);
                                Clear(employeeEmails);
                                if Employee.FindFirst() then
                                    repeat
                                        if employeeEmails <> '' then employeeEmails += ',';
                                        if Employee."E-Mail" <> '' then
                                            employeeEmails += LowerCase(Employee."E-Mail".Trim());
                                    until Employee.Next() = 0;
                            end;
                        end;
                    }
                    field(FromDate; FromDate)
                    {
                        Caption = 'From Date';
                        ApplicationArea = All;
                        Editable = edit;
                    }
                    field(ToDate; ToDate)
                    {
                        Caption = 'To Date';
                        ApplicationArea = All;
                        Editable = edit;
                    }
                    field(Status; Status)
                    {
                        Caption = 'Status';
                        ApplicationArea = All;
                        Editable = false;
                    }

                    field(adminStatus; adminStatus)
                    {
                        Caption = 'Admin Status';
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(txnClearingStatus; txnClearingStatus)
                    {
                        Caption = 'Transaction Clearing Status';
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(withReceipt; withReceipt)
                    {
                        Caption = 'With receipt';
                        ApplicationArea = All;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            edit := true;
            adminStatus := adminStatus::approved;
            txnClearingStatus := txnClearingStatus::SETTLED;
            Status := Status::READY_TO_EXPORT;
        end;
    }

    local procedure CallTransactionFetchAPI()
    var
        ResponseData: JsonObject;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;

    begin
        CreateURL();

        ResponseData := AlaanAPIMGT.CallGetAPI(CompanyProperty.ID(), URL, DataCodesTXT);
        // CurrReport.Break();
        // exit;
        //get status
        if not ResponseData.Get('status', JsonToken) then
            Error('Missing status in response.');

        //check status
        if not JsonToken.AsValue().AsBoolean() then
            if ResponseData.Get('message', JsonToken) then
                Error('API ERROR RESPONSE : %1', JsonToken.AsValue().AsText())
            else
                Error('API ERROR RESPONSE : Unknown error');

        // get entity object
        if ResponseData.get('entity', JsonToken) then
            JsonObject := JsonToken.AsObject();

        //check for multiple transactions
        if DataCodesTXT <> '' then begin
            if JsonObject.Get('totalCount', JsonToken) and (JsonToken.AsValue().AsInteger() <= 0) then
                Error('No data found from Alaan');

            if JsonObject.Get(DataCodesTXT, JsonToken) then
                TransactionMGT.StoreTransactionData(JsonToken);
        end
        else
            TransactionMGT.StoreTransactionData(JsonObject.AsToken());
    end;

    local procedure CreateURL()
    var
        // URL: Text;
        BaseURL: Text;
        FromDateFilter: Text;
        ToDateFilter: Text;
        ResponseToken: JsonObject;
        TxnIdTXT: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        JsonArray: JsonArray;
    begin
        //Create URL Based On parameters assign
        Clear(DataCodesTXT);
        Clear(URL);
        BaseURL := AlaanAPIMGT.GetBaseURL();
        if not IsNullGuid(id) then begin
            TxnIdTXT := DelChr(id.ToText, '=', '{}');
            URL := StrSubstNo('%1/transaction/%2?', BaseURL, TxnIdTXT);
        end
        else begin
            DataCodesTXT := 'transactions';
            URL := StrSubstNo('%1/transactions?', BaseURL);
        end;

        if FromDate <> CreateDateTime(0D, 0T) then begin
            FromDateFilter := FromDate.ToText();
            URL := StrSubstNo(URL + 'from=%1', FromDateFilter);
        end;

        if ToDate <> CreateDateTime(0D, 0T) then begin
            ToDateFilter := FromDate.ToText();
            if URL.EndsWith('?') then
                URL := StrSubstNo(URL + 'to=%1', ToDateFilter)
            else
                URL := StrSubstNo(URL + '&to=%1', ToDateFilter)
        end;

        if Status <> Status::" " then begin
            if URL.EndsWith('?') then
                URL := StrSubstNo(URL + 'status=%1', Format(Status))
            else
                URL := StrSubstNo(URL + '&status=%1', Format(Status))
        end;
        if adminStatus <> adminStatus::" " then begin
            if URL.EndsWith('?') then
                URL := StrSubstNo(URL + 'adminStatus=%1', Format(adminStatus))
            else
                URL := StrSubstNo(URL + '&adminStatus=%1', Format(adminStatus))

        end;
        if txnClearingStatus <> txnClearingStatus::" " then begin
            if URL.EndsWith('?') then
                URL := StrSubstNo(URL + 'txnClearingStatus=%1', Format(txnClearingStatus))
            else
                URL := StrSubstNo(URL + '&txnClearingStatus=%1', Format(txnClearingStatus))
        end;
        if employeeEmails <> '' then begin
            if URL.EndsWith('?') then
                URL := StrSubstNo(URL + 'employeeEmails=%1', Format(employeeEmails))
            else
                URL := StrSubstNo(URL + '&employeeEmails=%1', Format(employeeEmails))
        end;
        if withReceipt then begin
            if URL.EndsWith('?') then
                URL := StrSubstNo(URL + 'withReceipts=true')
            else
                URL := StrSubstNo(URL + '&withReceipts=true');
        end;
    end;

    procedure GetParameter(TxnId: Guid; Receipt: Boolean)
    begin
        id := TxnId;
        withReceipt := Receipt;
        FromDate := CreateDateTime(0D, 0T);
        ToDate := CreateDateTime(0D, 0T);
        Status := Status::" ";
        employeeEmails := '';
    end;

    var
        FromDate: DateTime;
        ToDate: DateTime;
        Status: Option " ",PENDING,READY_TO_EXPORT,EXPORTED,FAILED,SYNC_IN_PROGRESS;
        withReceipt: Boolean;
        adminStatus: Option " ","pending_review","approved","rejected";
        txnClearingStatus: Option " ","SETTLED","NOT_SETTLED";
        id: Guid;
        MerchantName: Text;
        employeeEmails: Text;
        edit: Boolean;
        AlaanAPIMGT: Codeunit "Alaan API MGT";
        TransactionMGT: Codeunit "Transaction MGT";
        URL: Text;
        DataCodesTXT: Text;
}