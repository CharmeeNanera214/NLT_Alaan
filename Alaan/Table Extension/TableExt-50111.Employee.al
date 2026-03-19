tableextension 50111 "SH-Employee Ext." extends Employee
{
    fields
    {
        field(50100; Department; Enum "Employee Department")
        {
            Caption = 'Department';
            DataClassification = ToBeClassified;
        }
        field(50101; "Alaan Employee"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Alaan Employee';
        }
    }
}