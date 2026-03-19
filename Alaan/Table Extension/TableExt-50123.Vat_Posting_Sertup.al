tableextension 50123 "VAT Posting Setup EXT" extends "VAT Posting Setup"
{
    fields
    {
        modify("VAT Bus. Posting Group")
        {
            trigger OnAfterValidate()
            begin
                if ("VAT Prod. Posting Group" <> '') and ("VAT Bus. Posting Group" <> '') then begin
                    "Alaan Tax Code" := StrSubstNo('%1-%2', "VAT Bus. Posting Group", "VAT Prod. Posting Group");
                    "Synced With Alaan" := false;
                end;

            end;
        }
        modify("VAT Prod. Posting Group")
        {
            trigger OnAfterValidate()
            begin
                if ("VAT Prod. Posting Group" <> '') and ("VAT Bus. Posting Group" <> '') then begin
                    "Alaan Tax Code" := StrSubstNo('%1-%2', "VAT Bus. Posting Group", "VAT Prod. Posting Group");
                    "Synced With Alaan" := false;
                end;
            end;
        }
        field(50100; "Alaan Tax Code Id"; Guid)
        {
            DataClassification = ToBeClassified;
            Caption = 'Supplier ID';

            trigger OnValidate()
            begin
                if IsNullGuid("Alaan Tax Code Id") then
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
            trigger OnValidate()
            begin
                if Rec."Sync With Alaan" and (Rec."Alaan Tax Code" = '') then begin
                    "Alaan Tax Code" := StrSubstNo('%1-%2', "VAT Bus. Posting Group", "VAT Prod. Posting Group");
                    "Synced With Alaan" := false;
                end;
            end;
        }
        field(50103; "Last Synced with Alaan"; DateTime)
        {
            DataClassification = ToBeClassified;
            Caption = 'Last Connected with Alaan';
        }
        field(50104; "Alaan Tax Code"; Code[45])
        {
            DataClassification = ToBeClassified;
            Caption = 'Alaan Tax Code';
        }
    }
}