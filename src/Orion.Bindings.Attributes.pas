unit Orion.Bindings.Attributes;

interface

uses
  System.Rtti;
const
  EmptyEntityName = '';
  EmptyEntityPropertyname = '';
  EmptyPrefix = '';
  EmptySufix = '';
  EmptyFormat = '';

type
  OrionBindingComponent = class(TCustomAttribute)
  private
    FEntityPropertyName: string;
  public
    constructor Create(aEntityPropertyName : string);
    property EntityPropertyName: string read FEntityPropertyName write FEntityPropertyName;
  end;

  OrionBindsChangeProperty = class(TCustomAttribute)
  private
    FProperty: string;
    FValue: TValue;
  public
    constructor Create(aProperty : string; aValue : TValue);
    property Prop: string read FProperty write FProperty;
    property Value: TValue read FValue write FValue;
  end;

  OrionBindAssertProperty = class(TCustomAttribute)
  private
    FCondition: string;
    FTrueValue: TValue;
    FFalseValue: TValue;
    FPropertyName: string;
  public
    constructor Create(aCondition, aPropertyName: string; aTrueValue, aFalseValue: TValue);

    property Condition    : string read FCondition    write FCondition;
    property PropertyName : string read FPropertyName write FPropertyName;
    property TrueValue    : TValue read FTrueValue    write FTrueValue;
    property FalseValue   : TValue read FFalseValue   write FFalseValue;
  end;

  OrionBindingComboBox = class(TCustomAttribute)
  private
    FEntityPropertyDisplayName: string;
    FEntityPropertyKeyName: string;

  public
    constructor Create(aEntityPropertyDisplayName, aEntityPropertyKeyName : string);

    property EntityPropertyDisplayName: string read FEntityPropertyDisplayName write FEntityPropertyDisplayName;
    property EntityPropertyKeyName: string read FEntityPropertyKeyName write FEntityPropertyKeyName;
  end;

  Prefix = class(TCustomAttribute)
  private
    FValue: string;
  public
    constructor Create(aValue : string);
    property Value: string read FValue write FValue;
  end;

  Sufix = class(TCustomAttribute)
  private
    FValue: string;
  public
    constructor Create(aValue : string);
    property Value: string read FValue write FValue;
  end;

implementation

{ TOrionBindingComponentEdits }

constructor OrionBindingComponent.Create(aEntityPropertyName : string);
begin
  FEntityPropertyName := aEntityPropertyName;
end;

{ OrionBindingComboBox }

constructor OrionBindingComboBox.Create(aEntityPropertyDisplayName, aEntityPropertyKeyName: string);
begin
  FEntityPropertyDisplayName := aEntityPropertyDisplayName;
  FEntityPropertyKeyName     := aEntityPropertyKeyName;
end;

{ Sufix }

constructor Sufix.Create(aValue: string);
begin
  FValue := aValue;
end;

{ Prefix }

constructor Prefix.Create(aValue: string);
begin
 FValue := aValue;
end;

{ OrionBindsChangeProperty }

constructor OrionBindsChangeProperty.Create(aProperty: string; aValue: TValue);
begin
  FProperty := aProperty;
  FValue    := aValue;
end;

{ OrionBindAssertProperty }

constructor OrionBindAssertProperty.Create(aCondition, aPropertyName: string; aTrueValue, aFalseValue: TValue);
begin
  FCondition    := aCondition;
  FPropertyName := aPropertyName;
  FTrueValue    := aTrueValue;
  FFalseValue   := aFalseValue;
end;

end.
