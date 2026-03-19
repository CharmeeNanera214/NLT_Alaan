pageextension 50124 "Business Manager RC Ext" extends "Business Manager Role Center"
{
    layout
    {

    }

    actions
    {
        addbefore(Action39)
        {
            group(Alaan)
            {
                Caption = 'Alaan';

                group("Alaan Setup")
                {
                    action("Alaan-Setup")
                    {
                        Caption = 'Alaan Setup';
                        ApplicationArea = All;
                        RunObject = page "NLT - Alaan Setup";
                    }
                    action(ExpenseCat)
                    {
                        Caption = 'Alaan - Expense Category';
                        ApplicationArea = All;
                        RunObject = page "Expense Categories";
                    }
                    action(TaxCode)
                    {
                        Caption = 'VAT Posting Setup';
                        ApplicationArea = All;
                        RunObject = page "VAT Posting Setup";
                    }
                    action(AlaanVendor)
                    {
                        Caption = 'Vendor';
                        ApplicationArea = All;
                        RunObject = page "Vendor List";
                    }
                    action(AlaanUser)
                    {
                        Caption = 'Alaan - User List';
                        ApplicationArea = All;
                        RunObject = page "NLT Employee";
                    }
                    action(ExpCatTag)
                    {
                        Caption = 'Alaan - Expense Tracking Tags';
                        ApplicationArea = All;
                        RunObject = page ExpenseTrackingTagList;
                    }
                    action(TxnType)
                    {
                        Caption = 'Alaan - Transaction Type';
                        ApplicationArea = All;
                        RunObject = page "Alaan - Transaction Type";
                    }
                }
                group(transaction)
                {
                    Caption = 'Transaction';
                    action(Txn)
                    {
                        Caption = 'Alaan - Transaction';
                        ApplicationArea = All;
                        RunObject = page "Transactions - Alaan";
                    }
                    action(PaymentJournal)
                    {
                        Caption = 'Payment Journal';
                        ApplicationArea = All;
                        RunObject = page "Payment Journal";
                    }
                }
                group(Logs)
                {
                    Caption = 'Alaan - Logs';
                    action(LogVendor)
                    {
                        Caption = 'Alaan Logs - Supplier/Vendor';
                        ApplicationArea = All;
                        RunObject = page "Supplier - Alaan Logs";
                    }
                    action(LogEmployee)
                    {
                        Caption = 'Alaan Logs - Employee';
                        ApplicationArea = All;
                        RunObject = page "NLT Employee - Alaan Logs";
                    }
                    action(LogExpCat)
                    {
                        Caption = 'Alaan Logs - Expense Category';
                        ApplicationArea = All;
                        RunObject = page "Expense Cat - Alaan Logs";
                    }
                    action(LogTaxCode)
                    {
                        Caption = 'Alaan Logs - Tax Code';
                        ApplicationArea = All;
                        RunObject = page "Tax Codes - Alaan Logs";
                    }
                    action(LogExpTracTag)
                    {
                        Caption = 'Alaan Logs - Expense Tracking Tag';
                        ApplicationArea = All;
                        RunObject = page "Exp. Tracking Tag - Alaan Logs";
                    }
                    group(LogTransaction)
                    {
                        Caption = 'Alaan Log - Transation';
                        action(LogTransactionH)
                        {
                            Caption = 'Alaan Logs - Transaction';
                            ApplicationArea = All;
                            RunObject = page "Transaction - Alaan Logs";
                        }
                        action(LogTransactionL)
                        {
                            Caption = 'Alaan Logs - Transaction Line';
                            ApplicationArea = All;
                            RunObject = page "Transaction Line - Alaan Logs";
                        }
                        action(LogPayment)
                        {
                            Caption = 'Alaan Logs - Payment Transaction Journal';
                            ApplicationArea = All;
                            RunObject = page "Txn Jur. - Alaan Logs";
                        }
                    }
                }
            }

            group("Bank Statement Import")
            {
                Caption = 'Bank Statement Import';

                action(BSISetup)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Import Setup';
                    RunObject = page "Bank Import Setup";
                }
                action(BSIList)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Statement Import';
                    RunObject = page "Bank Statements Import";
                }
                action(BSIBufferLines)
                {
                    ApplicationArea = All;
                    Caption = 'Bank Statement Buffer Lines';
                    RunObject = page "Bank Statement Buffer Lines";
                }
                action(GeneralJournal)
                {
                    ApplicationArea = All;
                    Caption = 'General Journal';
                    RunObject = page "General Journal";
                }
            }

        }
    }
}