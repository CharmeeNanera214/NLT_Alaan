table 50127 NLTEmployee
{
    Caption = 'Alaan User';
    Description = 'Employee Dimension to Alaan';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Dimension Employee Code';
        }
        field(2; Name; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Dimension Employee Name';
        }
        field(3; DIMEmpCode; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Dimension Employee';
            TableRelation = Dimension;
        }
        field(50100; "Employee ID"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Employee ID';

            trigger OnValidate()
            begin
                if IsNullGuid("Employee ID") then
                    "Synced With Alaan" := false
                else
                    "Synced With Alaan" := true;
            end;
        }
        field(50101; "Synced With Alaan"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Connected With Alaan';
        }
        field(50102; "Sync With Alaan"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Connect with Alaan';
        }
        field(50103; "Last Synced with Alaan"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Last Connected Time with Alaan';
        }
        field(4; Type; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Type';
            OptionMembers = "Employee","Transaction";
            OptionCaption = 'Employee,Transaction';
        }
    }

    keys
    {
        key(PK; Code, DIMEmpCode)
        {
            Clustered = true;
        }
    }


    trigger OnDelete()
    begin
        if not IsNullGuid("Employee ID") then Error('Record is Connected with Alaan. you can not delete it. First remove it from Alaan');
    end;
}