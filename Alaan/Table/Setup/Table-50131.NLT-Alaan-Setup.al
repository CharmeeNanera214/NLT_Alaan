table 50131 "NLT - Alaan Setup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; EntryNo; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Caption = 'Entry No';
        }
        field(2; CompanyID; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Company ID';
        }
        field(3; CompanyName; Text[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Company Name';
        }
        field(4; ClientID; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Client ID';
        }
        field(5; ClientSecret; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Client Secret';
        }
        field(6; "Employee DIM"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Employeee Dimension';
            Description = 'Dimension Code to Map Employee with Alaan';
            TableRelation = Dimension.Code where(Blocked = const(false));

            trigger OnValidate()
            var
                Dimension: Record Dimension;
                ExpnseTag: Codeunit "Expense Tracking Tags API";
            begin
                if Rec."Employee DIM" <> xRec."Employee DIM" then begin
                    CheckDimensionValuesSynced(xRec."Employee DIM", 'EMP');
                end;


                if "Employee DIM" <> '' then CheckDimensionSync("Employee DIM");
            end;
        }
        field(7; "Exp. Cat. DIM"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Expense Category Dimension';
            Description = 'Dimension Code to Map Expense Category with Alaan';
            TableRelation = Dimension.Code where(Blocked = const(false));

            trigger OnValidate()
            begin
                if Rec."Exp. Cat. DIM" <> xRec."Exp. Cat. DIM" then begin
                    CheckDimensionValuesSynced(xRec."Exp. Cat. DIM", 'EXPCAT');
                end;
            end;
        }
        field(8; "Transaction Type DIM"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Type Dimension';
            TableRelation = Dimension.Code where(Blocked = const(false));
            trigger OnValidate()
            begin
                if Rec."Transaction Type DIM" <> xRec."Transaction Type DIM" then begin
                    CheckDimensionValuesSynced(xRec."Transaction Type DIM", 'TXNTYPE');
                end;
                if "Transaction Type DIM" <> '' then CheckDimensionSync("Transaction Type DIM");
            end;
        }
        field(9; AlaanVendorJurBatch; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Alaan Vendor Journal Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = const('PAYMENTS'));
        }
        field(10; AlaanExpenseJurBatch; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Alaan Expense Journal Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = const('PAYMENTS'));

        }
        field(11; "Employee Bank"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Employee Bank';
            TableRelation = "Bank Account"."No.";
        }
        field(12; "Payment Method"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Payment Method';
            TableRelation = "Payment Method".Code;
        }
        field(13; "EMP DIM Synced"; Boolean)
        {
            Caption = 'Employee Dimension Synced';
            DataClassification = ToBeClassified;
        }
        field(14; "Exp. Cate. DIM Synced"; Boolean)
        {
            Caption = 'Expense Category Dimension Synced';
            DataClassification = ToBeClassified;
        }
        field(15; "Txn Type DIM Synced"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Transaction Type Dimension Synced';
        }
        field(16; "Cashback Account"; Code[20])
        {
            Caption = 'Cashback Account';
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No." where("Account Type" = const("G/L Account Type"::Posting), Blocked = const(false));
        }
    }

    keys
    {
        key(PK; CompanyID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; CompanyName, "Employee DIM")
        {

        }
    }

    local procedure CheckDimensionSync(Code: Code[20])
    var
        Dimension: Record Dimension;
        ExpnseTag: Codeunit "Expense Tracking Tags API";
    begin
        Dimension.Get(Code);
        if not IsNullGuid(Dimension.AlaanID) then
            exit;
        if Confirm('Dimension is not Connected with Alaan. Do you want to sync it with Alaan') then
            ExpnseTag.SyncExpensetrackingTag(Dimension);
    end;

    local procedure CheckDimensionValuesSynced(Code: Code[20]; DIMTYPE: Code[20])
    var
        Dimension: Record Dimension;
        NLTEMployee: Record NLTEmployee;
        ExpCat: Record "Expense Categories";
        ExpnseTag: Codeunit "Expense Tracking Tags API";
        Guid: Guid;
    begin
        if Dimension.Get(Code) then begin
            case DIMTYPE of
                'EMP':
                    begin
                        if not IsNullGuid(Dimension.AlaanID) then begin
                            NLTEMployee.SetFilter(DIMEmpCode, Code);
                            NLTEMployee.SetFilter("Employee ID", '<>%1', Guid);
                            if NLTEMployee.FindFirst() then
                                Error('Some employees are still linked to this dimension(%1) through Alaan. Please disconnect all related employees before continuing.', Code);
                            Error('This dimension(%1) is still linked with Alaan. Please open the Alaan – Expense Tracking Tag and disconnect it before proceeding.', Code);
                        end;
                    end;
                'EXPCAT':
                    begin
                        ExpCat.SetFilter("EXP CAT DIM CODE", Code);
                        ExpCat.SetFilter("Expense ID", '<>%1', Guid);
                        if ExpCat.FindFirst() then
                            Error('Some expense categories linked to this dimension(%1) are still connected to Alaan. Please disconnect all related categories before proceeding', Code);
                    end;
                'TXNTYPE':
                    begin
                        if not IsNullGuid(Dimension.AlaanID) then begin
                            NLTEMployee.SetFilter(DIMEmpCode, Code);
                            NLTEMployee.SetFilter("Employee ID", '<>%1', Guid);
                            if NLTEMployee.FindFirst() then
                                Error('Some Transaction Types linked to this dimension(%1) are still connected to Alaan. Please disconnect all related transaction types from the Transaction Type group on the page before proceeding.', Code);
                            Error('This dimension(%1) is still linked with Alaan. Please open the Alaan – Expense Tracking Tag and disconnect it before proceeding.', Code);
                        end;
                    end;
            end;



            // if not IsNullGuid(Dimension.AlaanID) then begin

            //     case DIMTYPE of
            //         'EMP':
            //             begin
            //                 NLTEMployee.SetFilter(DIMEmpCode, Code);
            //                 NLTEMployee.SetFilter("Employee ID", '<>%1', Guid);
            //                 if NLTEMployee.FindFirst() then
            //                     Error('There are Employee dimension which are connected with Alaan. Disconnect them all first');
            //             end;
            //         'EXPCAT':
            //             begin
            //                 ExpCat.SetFilter("EXP CAT DIM CODE", Code);
            //                 ExpCat.SetFilter("Expense ID", '<>%1', Guid);
            //                 if ExpCat.FindFirst() then
            //                     Error('There are Expense categories which are connected with Alaan. Disconnect them all first');
            //             end;
            //     end;
            //     Error('Dimension Are still connected with Alaan, Disconnect it first');
            // end
        end;
    end;
}