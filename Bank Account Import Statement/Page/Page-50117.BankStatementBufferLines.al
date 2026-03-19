page 50117 "Bank Statement Buffer Lines"
{
    PageType = List;
    Caption = 'Bank Statement Buffer Lines';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Bank Statement Lines Buffer";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    // Editable = false;

    layout
    {
        area(Content)
        {
            group(Filter)
            {
                Caption = 'Journal Filters';
                Visible = not EnableActions;
                field(JournalAccountType; Filter_JournalAccType)
                {
                    ApplicationArea = All;
                    Caption = 'Journal Account Type';
                    trigger OnValidate()
                    begin
                        Filter_JournalAccNo := '';
                    end;
                }
                field(JournalAccNo; Filter_JournalAccNo)
                {
                    ApplicationArea = All;
                    Caption = 'Journal Account No';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GLAcc: Record "G/L Account";
                        Customer: Record Customer;
                        Vendor: Record Vendor;
                        BankAcc: Record "Bank Account";
                        FixedAsset: Record "Fixed Asset";
                        ICPartner: Record "IC Partner";
                        GLAccList: Page "Chart of Accounts";
                        CustomerList: Page "Customer List";
                        BankAccList: Page "Bank Account List";
                        VendorList: Page "Vendor List";
                        FixedAssetList: Page "Fixed Asset List";
                        ICPartnerList: Page "IC Partner List";
                        RecRef: RecordRef;
                        SelectionfilterManagement: Codeunit SelectionFilterManagement;
                    begin
                        case Filter_JournalAccType of
                            Filter_JournalAccType::"G/L Account":
                                begin
                                    GLAcc.SetRange("Account Type", GLAcc."Account Type"::Posting);
                                    GLAccList.LookupMode(true);
                                    GLAccList.SetTableView(GLAcc);
                                    if GLAccList.RunModal() = Action::LookupOK then begin
                                        GLAccList.SetSelectionFilter(GLAcc);
                                        RecRef.GetTable(GLAcc);
                                        Text := SelectionfilterManagement.GetSelectionFilter(RecRef, GLAcc.FieldNo("No."));
                                    end;
                                end;

                            Filter_JournalAccType::Customer:
                                begin
                                    CustomerList.LookupMode(true);
                                    CustomerList.SetTableView(Customer);
                                    if CustomerList.RunModal() = Action::LookupOK then begin
                                        CustomerList.SetSelectionFilter(Customer);
                                        RecRef.GetTable(Customer);
                                        Text := SelectionFilterManagement.GetSelectionFilter(RecRef, Customer.FieldNo("No."));
                                    end;
                                end;

                            Filter_JournalAccType::Vendor:
                                begin
                                    VendorList.LookupMode(true);
                                    VendorList.SetTableView(Vendor);
                                    if VendorList.RunModal() = Action::LookupOK then begin
                                        VendorList.SetSelectionFilter(Vendor);
                                        RecRef.GetTable(Vendor);
                                        Text := SelectionFilterManagement.GetSelectionFilter(RecRef, Vendor.FieldNo("No."));
                                    end;
                                end;

                            Filter_JournalAccType::"Bank Account":
                                begin
                                    BankAccList.LookupMode(true);
                                    BankAccList.SetTableView(BankAcc);
                                    if BankAccList.RunModal() = Action::LookupOK then begin
                                        BankAccList.SetSelectionFilter(BankAcc);
                                        RecRef.GetTable(BankAcc);
                                        Text := SelectionFilterManagement.GetSelectionFilter(RecRef, BankAcc.FieldNo("No."));
                                    end;
                                end;
                            Filter_JournalAccType::"Fixed Asset":
                                begin
                                    FixedAssetList.LookupMode(true);
                                    FixedAssetList.SetTableView(FixedAsset);
                                    if FixedAssetList.RunModal() = Action::LookupOK then begin
                                        FixedAssetList.SetSelectionFilter(FixedAsset);
                                        RecRef.GetTable(FixedAsset);
                                        Text := SelectionFilterManagement.GetSelectionFilter(RecRef, FixedAsset.FieldNo("No."));
                                    end;
                                end;
                            Filter_JournalAccType::"IC Partner":
                                begin
                                    ICPartnerList.LookupMode(true);
                                    ICPartnerList.SetTableView(ICPartner);
                                    if ICPartnerList.RunModal() = Action::LookupOK then begin
                                        ICPartnerList.SetSelectionFilter(ICPartner);
                                        RecRef.GetTable(ICPartner);
                                        Text := SelectionFilterManagement.GetSelectionFilter(RecRef, ICPartner.FieldNo("Code"));
                                    end;
                                end;
                        end;
                        if Text <> '' then begin
                            Rec.SetFilter(JournalLineAccNo, Text);
                            if Rec.FindSet() then;
                            Filter_JournalAccNo := Text;
                        end;
                        CurrPage.Update(false);
                        exit(true);
                    end;

                    trigger OnValidate()
                    begin
                        if Filter_JournalAccNo <> '' then begin
                            Rec.SetFilter(JournalLineAccNo, Filter_JournalAccNo);
                            if Rec.FindSet() then;
                        end;
                        CurrPage.Update(false);
                    end;
                }
            }
            repeater(GroupName)
            {
                ShowCaption = false;
                field(LineType; LineType)
                {
                    ApplicationArea = All;
                    Caption = 'Line Type';
                    Editable = false;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the bank account or check ledger entry on the reconciliation line when the Suggest Lines function is used.';
                    Editable = false;
                    // Editable = EnableActions;
                    Visible = true;
                }
                field("Value Date"; Rec."Value Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value date of the transaction on the bank reconciliation line.';
                    // Editable = EnableActions;
                    Editable = false;
                    Visible = false;
                }
                field(JournalDocNo; Rec.JournalDocNo)
                {
                    ApplicationArea = All;
                    // Editable = EnableActions;
                    Caption = 'Journal Document no';
                    Visible = false;
                    Editable = false;
                }
                field(JournalLineAccType; Rec.JournalLineAccType)
                {
                    ApplicationArea = All;
                    Caption = 'Journal Account Type';
                    // Editable = EnableActions;
                    Editable = false;
                }
                field(JournalLineAccNo; Rec.JournalLineAccNo)
                {
                    ApplicationArea = All;
                    Caption = 'Journal Account No';
                    Editable = false;
                    // Editable = EnableActions;
                }
                field(JournalAccName; Rec.JournalAccName)
                {
                    ApplicationArea = All;
                    // Editable = EnableActions;
                    Caption = 'Journal Account Name';
                    Editable = false;
                }
                field("External Doc no."; Rec."External Doc no.")
                {
                    ApplicationArea = All;
                    Caption = 'External Doc No';
                    // Editable = EnableActions;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    // Editable = EnableActions;
                    ToolTip = 'Specifies a number of your choice that will appear on the reconciliation line.';
                    Editable = false;
                    Visible = false;
                }
                field("Check No."; Rec."Check No.")
                {
                    // Editable = EnableActions;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the check number for the transaction on the reconciliation line.';
                    Editable = false;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    // Editable = EnableActions;
                    Editable = false;
                    ToolTip = 'Specifies a description for the transaction on the reconciliation line.';
                }
                field("Statement Amount"; Rec."Statement Amount")
                {
                    ApplicationArea = Basic, Suite;
                    // Editable = EnableActions;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the transaction on the bank''s statement shown on this reconciliation line.';
                }
                field("Applied Amount"; Rec."Applied Amount")
                {
                    ApplicationArea = Basic, Suite;
                    // Editable = EnableActions;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the transaction on the reconciliation line that has been applied to a bank account or check ledger entry.';
                    Visible = false;
                }

                field(Difference; Rec.Difference)
                {
                    // Editable = EnableActions;
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the difference between the amount in the Statement Amount field and the amount in the Applied Amount field.';
                    Visible = false;
                }
                field("Line Transfered"; Rec."Line Transfered")
                {
                    ApplicationArea = All;
                    // Editable = EnableActions;
                    Editable = false;
                    Caption = 'Line Created';
                }
                field(LinePosted; Rec.LinePosted)
                {
                    ApplicationArea = All;
                    Caption = 'Line Posted';
                    // Editable = EnableActions;
                    Editable = false;
                }
                field("Applied Entries"; Rec."Applied Entries")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the transaction on the bank''s statement has been applied to one or more bank account or check ledger entries.';
                    // Editable = EnableActions;
                    Visible = false;
                    Editable = false;
                }
                field("Related-Party Name"; Rec."Related-Party Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer or vendor who made the payment that is represented by the journal line.';
                    // Editable = EnableActions;
                    Editable = false;
                    Visible = false;
                }
                field("Additional Transaction Info"; Rec."Additional Transaction Info")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies additional information on the bank statement line for the payment.';
                    // Editable = EnableActions;
                    Editable = false;
                    Visible = false;
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Transaction Has been reversed';
                    // Editable = EnableActions;
                    Editable = false;
                    Caption = 'Transaction Reversed';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find entries...';
                Image = Navigate;
                ShortCutKey = 'Ctrl+Alt+Q';
                AboutTitle = 'Get detailed posting details';
                AboutText = 'Here, you can look up the ledger entries that were created when this invoice was posted, as well as any related documents.';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';


                trigger OnAction()
                var
                    NavigatePage: Page Navigate;
                    Transaction: Record "Transactions - Alaan";
                begin
                    NavigatePage.SetDoc(Rec."Transaction Date", Rec.JournalDocNo);
                    NavigatePage.SetRec(Rec);
                    NavigatePage.Run();
                end;

            }
            action(TransferLines)
            {
                Caption = 'Transfer Lines To Journal';
                ApplicationArea = All;
                ToolTip = 'Transfer Bank Statement Buffer Lines to General journal';
                Image = TransferToGeneralJournal;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = EnableActions;
                trigger OnAction()
                var
                    BankImpMGT: Codeunit "Bank Import Statement MGT";
                    BankLineBuffer: Record "Bank Statement Lines Buffer";
                    // BankLineBuffer: Record "Bank Statement Lines Buffer";
                    BankStatements: Record "Bank Acc. Reconciliation";
                    ListOfRec: List of [Code[35]];
                    Filters: Text;
                begin
                    if (BankStatement_AccountCode = '') or (BankStatement_Code = '') then
                        exit;

                    BankStatements.Get(BankStatement_Type, BankStatement_AccountCode, BankStatement_Code);

                    CurrPage.SetSelectionFilter(BankLineBuffer);
                    if BankLineBuffer.FindSet() then
                        repeat
                            if not ListOfRec.Contains(BankLineBuffer."External Doc no.") then
                                ListOfRec.Add(BankLineBuffer."External Doc no.");
                        until BankLineBuffer.Next() = 0;
                    // Message(ListOfRec.Count.ToText());


                    // Message(Filters);
                    if ListOfRec.Count > 0 then
                        BankImpMGT.TransferLinesFromBuffer(BankStatements, ListOfRec);
                end;
            }
            action(GeneralJournal)
            {
                ApplicationArea = All;
                Image = Journal;
                Caption = 'Open General Journal';
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "General Journal";
            }
        }
    }

    var
        LineType: Option "Actual Line","Balance Line";
        BankStatement_AccountCode: Code[20];
        BankStatement_Code: Code[20];
        EnableActions: Boolean;
        BankStatement_Type: Enum "Bank Acc. Rec. Stmt. Type";
        Filter_JournalAccType: Enum "Gen. Journal Account Type";
        Filter_JournalAccNo: Text;

    trigger OnAfterGetRecord()
    var
        BankMGT: Codeunit "Bank Import Statement MGT";
    begin
        if Rec.IsBalanceLine then
            LineType := LineType::"Balance Line"

        else
            LineType := LineType::"Actual Line";


    end;

    procedure SetVariable(JournalAccType: Enum "Gen. Journal Account Type"; JournalAccNo: Text)
    begin
        Filter_JournalAccType := JournalAccType;
        Filter_JournalAccNo := JournalAccNo;
    end;

    procedure SetBankStatements(AccountCode: Code[20];
        StatementCode: Code[20])
    begin
        Clear(BankStatement_AccountCode);
        Clear(BankStatement_Code);
        Clear(BankStatement_Type);
        BankStatement_AccountCode := AccountCode;
        BankStatement_Code := StatementCode;
        BankStatement_Type := BankStatement_Type::"Bank Reconciliation";
    end;

    trigger OnOpenPage()
    begin
        Clear(EnableActions);
        if (BankStatement_AccountCode <> '') and (BankStatement_Code <> '') then
            EnableActions := true
    end;

}