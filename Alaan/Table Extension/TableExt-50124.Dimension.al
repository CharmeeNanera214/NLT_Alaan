tableextension 50124 DimensionEXT extends Dimension
{
    fields
    {
        field(50100; AlaanID; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Alaan ID';
            trigger OnValidate()
            begin
                if IsNullGuid(AlaanID) then
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
    }
}