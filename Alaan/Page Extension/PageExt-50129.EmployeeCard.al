pageextension 50129 "Employee Card Ext" extends "Employee Card"
{
    layout
    {
        addafter("Company E-Mail")
        {
            field(Department; Rec.Department)
            {
                ApplicationArea = All;
                Caption = 'Department';
            }
            field("Alaan Employee"; Rec."Alaan Employee")
            {
                ApplicationArea = All;
                Caption = 'Alaan Employee';
            }
        }
    }
}