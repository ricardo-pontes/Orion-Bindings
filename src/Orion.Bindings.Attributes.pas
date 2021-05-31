unit Orion.Bindings.Attributes;

interface

const
  EmptyEntityName = '';
  EmptyEntityPropertyname = '';
  EmptyPrefix = '';
  EmptySufix = '';
  EmptyFormat = '';

type
  OrionBindingComponent = class(TCustomAttribute)
  private
    FEntityName : string;
    FEntityPropertyName: string;
    FPrefix : string;
    FSufix : string;
    FFormat: string;
  public
    constructor Create(aEntityName, aEntityPropertyName, aPrefix, aSufix, aFormat : string);

    property EntityPropertyName: string read FEntityPropertyName write FEntityPropertyName;
    property EntityName: string read FEntityName write FEntityName;
    property Prefix: string read FPrefix write FPrefix;
    property Sufix: string read FSufix write FSufix;
    property Format: string read FFormat write FFormat;
  end;

implementation

{ TOrionBindingComponentEdits }

constructor OrionBindingComponent.Create(aEntityName, aEntityPropertyName, aPrefix, aSufix, aFormat : string);
begin
  FEntityName         := aEntityName;
  FEntityPropertyName := aEntityPropertyName;
  FPrefix             := aPrefix;
  FSufix              := aSufix;
  FFormat             := aFormat;
end;

end.
