tableextension 50121 "Supplier/Vendor" extends Vendor
{
    fields
    {
        field(50100; "Supplier Id"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Supplier ID';
            trigger OnValidate()
            begin
                if IsNullGuid("Supplier Id") then
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
            Caption = 'Last Connected with Alaan';
        }
    }
}