pageextension 50128 "Employees Ext" extends "Employee List"
{
    layout
    {
        addafter("E-Mail")
        {
            field("Alaan Employee"; Rec."Alaan Employee")
            {
                ApplicationArea = All;
                Caption = 'Alaan Employee';
            }
        }
    }
}