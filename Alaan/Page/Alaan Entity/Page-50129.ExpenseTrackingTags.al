page 50129 ExpenseTrackingTagList
{
    PageType = List;
    Caption = 'Alaan - Expense Tracking Tags';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Dimension;
    PromotedActionCategories = 'New,Process,Reporting,Alaan';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Tag Code';
                    Editable = false;
                }
                field(Rec; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Tag Name';
                    Editable = false;
                }

                field("Sync With Alaan"; Rec."Sync With Alaan")
                {
                    ApplicationArea = All;
                    Caption = 'Connect With Alaan';
                }
                field("Synced With Alaan"; Rec."Synced With Alaan")
                {
                    ApplicationArea = All;
                    Caption = 'Connected With Alaan';
                    Editable = false;
                }
                field("Last Synced with Alaan"; Rec."Last Synced with Alaan")
                {
                    ApplicationArea = All;
                    Caption = 'Last Synced with Alaan';
                    Editable = false;
                }
                field(AlaanID; Rec.AlaanID)
                {
                    ApplicationArea = All;
                    Caption = 'Tag ID';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncExpenseTag)
            {
                Caption = 'Connect';
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Category4;
                Enabled = not Rec."Synced With Alaan";

                trigger OnAction()
                var
                    ExpTracTagsAPI: Codeunit "Expense Tracking Tags API";
                begin
                    if (Rec."Sync With Alaan") then
                        // if (not Rec."Synced With Alaan") and (Rec."Sync With Alaan") then
                        ExpTracTagsAPI.SyncExpensetrackingTag(Rec)
                    else
                        Error('The record cannot be connect because it is either already connected or not eligible for connect with Alaan.');
                end;
            }

            action("Sync Log")
            {
                Caption = 'Connection Log';
                ApplicationArea = All;
                Image = Log;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = Page "Exp. Tracking Tag - Alaan Logs";
                RunPageLink = TagName = field(Name), "Dimension Code" = field(Code);
                RunPageView = sorting(EntryNo) order(descending);
                RunPageMode = View;
            }
            action("Delete Exp Cate")
            {
                Caption = 'Disconnect';
                ToolTip = 'Disconnect Expense Tracking Tag';
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    ExpenseAPIMGT: Codeunit "Expense Tracking Tags API";
                begin
                    if (not IsNullGuid(Rec.AlaanID)) and Rec."Sync With Alaan" then begin
                        if Confirm('Do you want to delete Expense Tracking Tag from Alaan ?') then
                            ExpenseAPIMGT.DeleteExpenseTrackingTag(Rec);
                    end
                    else
                        Error('Expense Tracking Tag is not connected with Alaan');
                end;
            }
        }
    }
}