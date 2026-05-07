codeunit 50136 "Transaction MGT"
{
    procedure StoreTransactionData(ResponseToken: JsonToken)
    var
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        TransactionArray: JsonArray;
        Index: Integer;
    begin
        if ResponseToken.IsObject then
            GetTransactionFromBC(ResponseToken.AsObject());

        if ResponseToken.IsArray then begin
            TransactionArray := ResponseToken.AsArray();

            for Index := 0 to TransactionArray.Count() - 1 do begin
                TransactionArray.Get(Index, JsonToken);
                GetTransactionFromBC(JsonToken.AsObject());
            end;
        end;
    end;

    local procedure GetTransactionFromBC(TransactionObj: JsonObject)
    var
        JObject: JsonObject;
        JToken: JsonToken;
        TransactionID: Guid;
        LogType: Option "","Create","Update","Delete";
        Error: Text;
    begin
        Clear(ReceiptURL);
        Clear(TransactionID);
        Clear(Error);
        if TransactionObj.Get('id', JToken) then
            Evaluate(TransactionID, JToken.AsValue().AsText());

        //If Transaction not exist create new one
        if not Transaction.Get(TransactionID) then begin
            Transaction.Init();
            Transaction.TransactionId := TransactionID;
            if TransactionObj.Get('exportStatus', JToken) then
                if not JToken.AsValue().IsNull then
                    Evaluate(Transaction."Export Status", JToken.AsValue().AsText());
            Transaction.Insert();
            LogType := LogType::Create;
        end
        else begin
            if Transaction.SyncStatus <> Transaction.SyncStatus::Synced then
                exit;
            LogType := LogType::Update;
        end;

        //Use receipt URL to Map in transaction
        ReceiptURL := Transaction."Receipt URL";

        // if transaction is exported or failed then no need to bring it again
        case Transaction."Export Status" of
            Transaction."Export Status"::EXPORTED, Transaction."Export Status"::FAILED:
                exit;
        end;

        if UpdateTransaction(Transaction, TransactionObj) then
            Transaction."Error message" := ''

        else begin
            Transaction."Error message" := GetLastErrorText;
            Error := Transaction."Error Message";
        end;
        Transaction.Modify();
        SetTransactionPaymentJournalTerm();
        InserTransactiontLog(LogType, Error, Transaction);
    end;

    [TryFunction]
    local procedure UpdateTransaction(var TransRec: Record "Transactions - Alaan"; TransactionObj: JsonObject)
    var
        JObject: JsonObject;
        ExtraObj: JsonObject;
        CardObj: JsonObject;
        TTypeObj: JsonObject;
        SpenderObj: JsonObject;
        ReceiptObj: JsonObject;
        SupplierObj: JsonObject;
        JToken: JsonToken;
        JArray: JsonArray;
        TransactionID: Guid;
        TagGroupInt: Integer;
        TTypeID: Guid;
    begin
        Clear(TType);
        TransactionID := TransRec.TransactionId;
        if TransactionObj.Get('corporateId', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Corporate ID", JToken.AsValue().AsText());

        if TransactionObj.Get('billingAmount', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Billing Amount" := JToken.AsValue().AsDecimal();

        if TransactionObj.Get('vatAmount', JToken) then
            if (not JToken.AsValue().IsNull) and (JToken.AsValue().AsText() <> '') then
                TransRec."VAT Amount" := JToken.AsValue().AsDecimal()
            else if JToken.AsValue().AsText() = '' then
                TransRec."VAT Amount" := 0;

        if TransactionObj.Get('billingCurrency', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Billing Currency", JToken.AsValue().AsText());
        //Code Added on 10-4-26 for memo field
        if TransactionObj.Get('spenderComments', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Spender Comments", JToken.AsValue().AsText());

        if TransactionObj.Get('merchantId', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Merchant ID", JToken.AsValue().AsText());

        if TransactionObj.Get('merchantName', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Merchant Name", JToken.AsValue().AsText());

        if TransactionObj.Get('txnTime', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Txn Time" := JToken.AsValue().AsDateTime();

        if TransactionObj.Get('txnType', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Txn Type", JToken.AsValue().AsText());

        if TransactionObj.Get('adminStatus', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Admin Status", JToken.AsValue().AsText());

        if TransactionObj.Get('txnEventType', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Txn Event Type", JToken.AsValue().AsText());

        if TransactionObj.Get('transactionAmount', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Transaction Amount" := JToken.AsValue().AsDecimal();

        if TransactionObj.Get('transactionCurrency', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Transaction Currency", JToken.AsValue().AsText());

        if TransactionObj.Get('posEnvironment', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."POS Environment", JToken.AsValue().AsText());

        if TransactionObj.Get('txnClearingStatus', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Txn Clearing Status", JToken.AsValue().AsText());

        if TransactionObj.Get('txnClearingDate', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Txn Clearing Date" := JToken.AsValue().AsDateTime();

        if TransactionObj.Get('exportStatus', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Export Status", JToken.AsValue().AsText());

        if TransactionObj.Get('settlementStatus', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Settlement Status", JToken.AsValue().AsText());

        if TransactionObj.Get('networkTransactionId', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Network Txn Id", JToken.AsValue().AsText());

        if TransactionObj.Get('partnerTxnId', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Partner Txn ID", JToken.AsValue().AsText());

        if TransactionObj.Get('createdAt', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Created At" := JToken.AsValue().AsDateTime();

        if TransactionObj.Get('updatedAt', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Updated At" := JToken.AsValue().AsDateTime();

        if TransactionObj.Get('merchantCountryCode', JToken) then
            if not JToken.AsValue().IsNull then
                Evaluate(TransRec."Merchant Country Code", JToken.AsValue().AsText());

        if TransactionObj.Get('referenceNumber', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Reference Number" := JToken.AsValue().AsText().Substring(1,35);

        if TransactionObj.Get('feeAmount', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Fee Amount" := JToken.AsValue().AsDecimal();

        if TransactionObj.Get('exchangeRate', JToken) then
            if not JToken.AsValue().IsNull then
                TransRec."Exchange Rate" := JToken.AsValue().AsDecimal();

        Clear(ReceiptObj);
        if TransactionObj.Get('receipts', JToken) then begin
            if JToken.IsArray then begin
                JArray := JToken.AsArray();
                if JArray.Get(0, JToken) then begin
                    ReceiptObj := JToken.AsObject();
                    if ReceiptObj.Get('url', JToken) then
                        if not JToken.AsValue().IsNull then
                            Evaluate(TransRec."Receipt URL", JToken.AsValue().AsText());
                end;
            end
        end;

        // Spender object
        Clear(SpenderObj);
        if TransactionObj.Get('spender', JToken) then begin
            if JToken.IsObject then begin
                SpenderObj := JToken.AsObject();
                if SpenderObj.Get('id', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."Spender ID", JToken.AsValue().AsText());
                if SpenderObj.Get('name', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."Spender Name", JToken.AsValue().AsText());
                if SpenderObj.Get('email', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."Spender Email", JToken.AsValue().AsText());
            end;
        end;

        //Supplier
        Clear(SupplierObj);
        if TransactionObj.Get('supplier', JToken) then begin
            if JToken.IsObject then begin
                SupplierObj := JToken.AsObject();
                if SupplierObj.Get('id', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec.SupplierID, JToken.AsValue().AsText());
                if SupplierObj.Get('partnerSupplierId', JToken) then
                    if not JToken.AsValue().IsNull then
                        TransRec.Validate("Vendor No", JToken.AsValue().AsText());
                // Evaluate(TransRec."Vendor No", JToken.AsValue().AsText());
                if SupplierObj.Get('partnerSupplierName', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."Vendor Name", JToken.AsValue().AsText());
            end;
        end;

        // Card object
        Clear(CardObj);
        if TransactionObj.Get('card', JToken) then begin
            if JToken.IsObject then begin
                CardObj := JToken.AsObject();
                if CardObj.Get('id', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."Card ID", JToken.AsValue().AsText());
                if CardObj.Get('cardNo', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."Card No", JToken.AsValue().AsText());
                if CardObj.Get('corpCardConfigId', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."CorpCard Config Id", JToken.AsValue().AsText());
            end;
        end;

        // ExtraDetails object
        Clear(ExtraObj);
        if TransactionObj.Get('extraDetails', JToken) then begin
            if JToken.IsObject then begin
                ExtraObj := JToken.AsObject();
                if ExtraObj.Get('idempotencyKey', JToken) then
                    if not JToken.AsValue().IsNull then
                        Evaluate(TransRec."Idempotency Key", JToken.AsValue().AsText());
            end;
        end;

        //Transaction Type from tag groups
        Clear(TTypeObj);
        TType := TType::None;
        if TransactionObj.Get('tagGroups', JToken) then begin
            JArray := JToken.AsArray();
            for TagGroupInt := 0 to JArray.Count - 1 do begin
                if JArray.Get(TagGroupInt, JToken) then begin
                    if JToken.IsObject then begin
                        JObject := JToken.AsObject();
                        if JObject.Get('id', JToken) then begin
                            TTypeID := JToken.AsValue().AsText();
                            if IsTransactionTypeID(TTypeID) then begin
                                TType := GetTransactionType(JObject);
                            end;
                        end;
                    end;
                end;
            end;
        end;
        case TType of
            TType::Expense:
                TransRec."Transaction Type" := TType::Expense;
            TType::Vendor:
                TransRec."Transaction Type" := TType::Vendor;
            TType::None:
                Error('Transaction Type must be Selected');
        end;
        TransRec.SyncStatus := TransRec.SyncStatus::Synced;
        TransRec.Modify(true);


        //check vendor no is exist or not
        if TType = TType::Vendor then
            TransRec.TestField("Vendor No");

        //get receipt
        if (ReceiptURL <> TransRec."Receipt URL") and (TransRec."Receipt URL" <> '') then
            GetReceipt(TransRec);

        // Line items array
        if TransactionObj.Get('transactionLineItem', JToken) then
            if JToken.IsArray then
                UpdateTransactionLines(JToken.AsArray(), TransactionID);

        // UpdateBalance();
    end;

    local procedure UpdateTransactionLines(TXNLineArr: JsonArray; TransID: Guid)
    var
        TXNLineObj: JsonObject;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        TxnInteger: Integer;
        NoOfTxnLine: Integer;
        TxnId: Guid;
        TxnLineId: Guid;
        ExpCatObj: JsonObject;
        CopTaxCodeObj: JsonObject;
        TagGroupArray: JsonArray;
        TagGroupObj: JsonObject;
        BlankGuid: Guid;
    begin
        Clear(LineCount);
        TxnInteger := 0;
        NoOfTxnLine := TXNLineArr.Count;
        if NoOfTxnLine = 0 then
            Error('No data in Transaction Lines');
        LineCount := NoOfTxnLine; //used for payment journal term
        for TxnInteger := 0 to NoOfTxnLine - 1 do begin
            if TXNLineArr.Get(TxnInteger, JsonToken) then begin
                TXNLineObj := JsonToken.AsObject();
                if UpdateSingleTransactionLine(TXNLineObj, TransID) then begin
                    LineErrorMessage := '';
                end
                else begin
                    LineErrorMessage := GetLastErrorText;
                end;
                TransactionLine."Error Message" := LineErrorMessage;
                TransactionLine.Modify();
                InsertTransactionLineLog(LogType, TransactionLine);
            end;
        end;
    end;

    [TryFunction]
    local procedure UpdateSingleTransactionLine(TXNLineObj: JsonObject; TransID: Guid)
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        TxnInteger: Integer;
        NoOfTxnLine: Integer;
        TxnId: Guid;
        TxnLineId: Guid;
        ExpCatObj: JsonObject;
        TransTypeObj: JsonObject;
        CopTaxCodeObj: JsonObject;
        TagGroupArray: JsonArray;
        TagGroupObj: JsonObject;
        BlankGuid: Guid;
        Integer: Integer;
        TagGroupID: Guid;
    begin
        if TXNLineObj.Get('id', JsonToken) then
            Evaluate(TxnLineId, JsonToken.AsValue().AsText());

        Clear(TransactionLine);
        LogType := LogType::Update;

        //If Line not exist create new one
        if not TransactionLine.Get(TransID, TxnLineId) then begin
            TransactionLine.Init();
            TransactionLine."Header ID" := TransID;
            TransactionLine."Line ID" := TxnLineId;
            TransactionLine.LineType := TransactionLine.LineType::"Actual Line";
            TransactionLine.Status := TransactionLine.Status::Synced;
            TransactionLine.Insert();
            LogType := LogType::Create;
        end;

        // if line is in error or posted, then no need to get it again from alaan.
        case TransactionLine.Status of
            TransactionLine.Status::Error, TransactionLine.Status::Posted:
                exit;
        end;

        if TXNLineObj.Get('amount', JsonToken) then
            TransactionLine.Amount := JsonToken.AsValue().AsDecimal();
        if TXNLineObj.Get('vatAmount', JsonToken) then
            TransactionLine."VAT Amount" := JsonToken.AsValue().AsDecimal();
        if TXNLineObj.Get('spenderComments', JsonToken) then
            TransactionLine."Spender Comments" := JsonToken.AsValue().IsNull ? '' : JsonToken.AsValue().AsText();

        //expense category
        Clear(JsonObject);
        if TXNLineObj.Get('expenseCategory', JsonToken) then begin
            if JsonToken.IsObject then
                JsonObject := JsonToken.AsObject();

            if JsonObject.Get('id', JsonToken) then
                Evaluate(TransactionLine."Expense Category ID", JsonToken.AsValue().AsText());
            if JsonObject.Get('name', JsonToken) then
                Evaluate(TransactionLine."Expense Category Name", JsonToken.AsValue().AsText());
            if JsonObject.Get('glaccount', JsonToken) then
                Evaluate(TransactionLine."Expense Category GL Account", JsonToken.AsValue().AsText());
            if JsonObject.Get('partnerExpenseAccountId', JsonToken) then
                TransactionLine."Partner Expense Account ID" := JsonToken.AsValue().IsNull ? 0 : JsonToken.AsValue().AsInteger();
            if JsonObject.Get('partnerExpenseAccountName', JsonToken) then
                Evaluate(TransactionLine."Partner Expense Account Name", JsonToken.AsValue().AsText());

            if JsonObject.Get('accountDetails', JsonToken) then
                if JsonToken.IsObject then
                    JsonObject := JsonToken.AsObject();
            if JsonObject.Get('name', JsonToken) then
                Evaluate(TransactionLine."Account Details Name", JsonToken.AsValue().AsText());
            if JsonObject.Get('glaccount', JsonToken) then
                Evaluate(TransactionLine."Account Details GL Account", JsonToken.AsValue().AsText());
        end;

        //corporate tax code
        Clear(JsonObject);
        if TXNLineObj.Get('corporateTaxCode', JsonToken) then begin
            if JsonToken.IsObject then
                JsonObject := JsonToken.AsObject()
            else
                if TransactionLine."VAT Amount" <> 0 then Error('Tax Code is not applied but on Line : %1', TransactionLine."Line ID");
            if JsonObject.Get('id', JsonToken) then
                TransactionLine.Validate("Tax Code ID", JsonToken.AsValue().AsText());
            // Evaluate(TransactionLine."Tax Code ID", JsonToken.AsValue().AsText());
            if JsonObject.Get('code', JsonToken) then
                Evaluate(TransactionLine."Tax Code", JsonToken.AsValue().AsText());
            if JsonObject.Get('rate', JsonToken) then
                Evaluate(TransactionLine."Tax Rate", JsonToken.AsValue().AsText());
            if JsonObject.Get('name', JsonToken) then
                Evaluate(TransactionLine."Tax Name", JsonToken.AsValue().AsText());
            if JsonObject.Get('partnerTaxCodeId', JsonToken) then
                Evaluate(TransactionLine."Partner Tax Code ID", JsonToken.AsValue().IsNull ? BlankGuid : JsonToken.AsValue().AsText());
        end;

        Clear(JsonArray);
        Clear(JsonObject);
        if TXNLineObj.Get('tagGroups', JsonToken) then begin
            if JsonToken.IsArray then
                JsonArray := JsonToken.AsArray();

            for Integer := 0 to JsonArray.Count - 1 do begin
                if JsonArray.Get(Integer, JsonToken) then begin
                    if JsonToken.IsObject then begin
                        JsonObject := JsonToken.AsObject();
                        if JsonObject.Get('id', JsonToken) then begin
                            TagGroupID := JsonToken.AsValue().AsText();
                            if IsEmployeesID(TagGroupID) then begin
                                if JsonObject.Get('id', JsonToken) then
                                    Evaluate(TransactionLine."Tag Group ID", JsonToken.AsValue().AsText());
                                if JsonObject.Get('name', JsonToken) then
                                    Evaluate(TransactionLine."Tag Group Name", JsonToken.AsValue().AsText());
                                if JsonObject.Get('fieldType', JsonToken) then
                                    Evaluate(TransactionLine."Tag Group Field Type", JsonToken.AsValue().AsText());
                                if JsonObject.Get('value', JsonToken) then
                                    Evaluate(TransactionLine."Tag Group Field Type", JsonToken.AsValue().IsNull ? '' : JsonToken.AsValue().AsText());
                                if JsonObject.Get('trackingCategoryType', JsonToken) then
                                    Evaluate(TransactionLine."Tracking Category Type", JsonToken.AsValue().AsText());

                                if JsonObject.Get('tagGroupItems', JsonToken) then begin

                                    if JsonToken.IsArray then
                                        JsonArray := JsonToken.AsArray();
                                    if JsonArray.Get(0, JsonToken) then begin
                                        JsonObject := JsonToken.AsObject();
                                        if JsonObject.Get('id', JsonToken) then
                                            Evaluate(TransactionLine."Tag Group Item ID", JsonToken.AsValue().AsText());
                                        if JsonObject.Get('name', JsonToken) then
                                            Evaluate(TransactionLine."Tag Group Item Name", JsonToken.AsValue().AsText());
                                        if JsonObject.Get('accountingReference', JsonToken) then
                                            Evaluate(TransactionLine."Tag Group Item Accounting Ref", JsonToken.AsValue().IsNull ? '' : JsonToken.AsValue().AsText());
                                        if JsonObject.Get('partnerName', JsonToken) then
                                            Evaluate(TransactionLine."Partner Name", JsonToken.AsValue().IsNull ? '' : JsonToken.AsValue().AsText());
                                        if JsonObject.Get('partnerTagGroupItemId', JsonToken) then
                                            Evaluate(TransactionLine."Partner Tag Group Item ID", JsonToken.AsValue().AsText() = '' ? BlankGuid : JsonToken.AsValue().AsText());
                                        if JsonObject.Get('partnerParentId', JsonToken) then
                                            Evaluate(TransactionLine."Partner Parent ID", JsonToken.AsValue().AsText() = '' ? BlankGuid : JsonToken.AsValue().AsText());
                                        if JsonObject.Get('tagInfo', JsonToken) then
                                            Evaluate(TransactionLine."Tag Info", JsonToken.AsValue().IsNull ? '' : JsonToken.AsValue().AsText());
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;

        TransactionLine.Status := TransactionLine.Status::Synced;
        UpdateBalance();
        TransactionLine.Modify();

        //check lines if expense then gl account mendatory
        if TType = TType::Expense then
            TransactionLine.TestField("Expense Category GL Account");
    end;

    local procedure GetReceipt(var TransRec: Record "Transactions - Alaan") ResponseText: Text
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
        Instr: InStream;
        Outstr: OutStream;
        URL: Text;
    begin
        URL := TransRec."Receipt URL";
        HttpRequestMessage.Method('GET');
        HttpRequestMessage.SetRequestUri(URL);
        if HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then begin
            if HttpResponseMessage.IsSuccessStatusCode then begin
                HttpResponseMessage.Content.ReadAs(Instr);
                TransRec.Receipt.CreateOutStream(Outstr);
                if CopyStream(Outstr, Instr) then
                    TransRec.Modify();
            end
            else
                Error('Unable to get data ' + HttpResponseMessage.ReasonPhrase);
        end;
    end;

    local procedure InserTransactiontLog(LogType: Option "","Create","Update","Delete"; Error: Text; Transaction: Record "Transactions - Alaan")
    begin
        TxnLog.Init();
        TxnLog.SyncType := TxnLog.SyncType::"From Alaan";
        TxnLog.ActionType := LogType;
        TxnLog."Sync Date & Time" := CurrentDateTime;
        TxnLog."Error Message" := Error;
        TxnLog.TransferFields(Transaction);
        TxnLog.Insert(true);
    end;

    local procedure InsertTransactionLineLog(LogType: Option "","Create","Update","Delete"; TLine: Record "Transaction Line - Alaan")
    begin
        Clear(TxnLineLog);
        TxnLineLog.Init();
        TxnLineLog.SyncType := TxnLog.SyncType::"From Alaan";
        TxnLineLog.ActionType := LogType;
        TxnLineLog."Sync Date & Time" := CurrentDateTime;
        TxnLineLog."Error Message" := LineErrorMessage;
        TxnLineLog.TransferFields(TLine);
        TxnLineLog.Insert();
    end;

    local procedure IsTransactionTypeID(ID: Guid): Boolean
    var
        Dimension: Record Dimension;
    begin
        if IsNullGuid(ID) then
            exit(false);

        NLTSetup.Get(CompanyProperty.ID());

        if not Dimension.Get(NLTSetup."Transaction Type DIM") then
            exit(false);

        Dimension.TestField("Synced With Alaan", true);
        exit(ID = Dimension.AlaanID);
    end;

    local procedure IsEmployeesID(ID: Guid): Boolean
    var
        Dimension: Record Dimension;
    begin
        if IsNullGuid(ID) then
            exit(false);

        NLTSetup.Get(CompanyProperty.ID());

        if not Dimension.Get(NLTSetup."Employee DIM") then
            exit(false);

        Dimension.TestField("Synced With Alaan", true);
        exit(ID = Dimension.AlaanID);
    end;

    local procedure GetTransactionType(TJobject: JsonObject) Type: Option "None","VENDOR","EXPENSE"
    var
        JSONObject: JsonObject;
        JSONArray: JsonArray;
        JSONToken: JsonToken;
        NLTEMployee: Record NLTEmployee;
    begin
        if not TJobject.Get('tagGroupItems', JSONToken) then
            exit(Type::None);

        if not JSONToken.IsArray then
            exit(Type::None);

        JSONArray := JSONToken.AsArray();

        if not JSONArray.Get(0, JSONToken) then
            exit(Type::None);

        if not JSONToken.IsObject then
            exit(Type::None);

        JSONObject := JSONToken.AsObject();

        if not JSONObject.Get('name', JSONToken) then
            exit(Type::None);

        case JSONToken.AsValue().AsText() of
            'Vendor Transaction':
                exit(Type::VENDOR);
            'Expense Transaction':
                exit(Type::EXPENSE);
        end;

        exit(Type::None);
    end;

    local procedure SetTransactionPaymentJournalTerm()
    begin
        case Transaction."Transaction Type" of
            Transaction."Transaction Type"::Vendor:
                begin
                    if Transaction.IsForeignVendor then
                        Transaction."Payment Journal Terms" := Transaction."Payment Journal Terms"::"Multiple Vendor"
                    else
                        Transaction."Payment Journal Terms" := Transaction."Payment Journal Terms"::"Single Vendor"
                end;
            Transaction."Transaction Type"::Expense:
                begin
                    if LineCount = 1 then
                        Transaction."Payment Journal Terms" := Transaction."Payment Journal Terms"::"Single GL"
                    else if LineCount > 1 then
                        Transaction."Payment Journal Terms" := Transaction."Payment Journal Terms"::"Multiple GL";
                end;
        end;
        Transaction.Modify();
    end;

    local procedure UpdateBalance()
    var
        Factor: Decimal;
    begin
        if not Transaction.IsForeignVendor then
            exit;
        if Transaction."Vendor Currency" = '' then
            exit;

        Factor := CurrExchRate.ExchangeRate(Transaction."Txn Clearing Date".Date, Transaction."Vendor Currency");

        if Factor <> 0 then
            TransactionLine."Amount (FCY)" := CurrExchRate.ExchangeAmtLCYToFCY(Transaction."Txn Clearing Date".Date, Transaction."Vendor Currency", TransactionLine.Amount, Factor);
    end;

    var
        Transaction: Record "Transactions - Alaan";
        TransactionLine: Record "Transaction Line - Alaan";
        TxnLog: Record "Transaction - Alaan Logs";
        TxnLineLog: Record "Transaction Line - Alaan Logs";
        NLTSetup: Record "NLT - Alaan Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        LogType: Option "","Create","Update","Delete";
        TType: option "None","Vendor","Expense";
        LineErrorMessage: Text;
        ReceiptURL: Text[1048];
        LineCount: Integer;

}