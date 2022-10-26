unit Orion.Bindings.Rtti;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.StrUtils,
  System.TypInfo,
  System.Generics.Collections,
  Orion.Bindings.Types,
  Orion.Bindings.Container;

type
  ResultEntityPropertyByName = record
    &Property : TRttiProperty;
    Entity : TObject;
  end;

procedure SetValueToProperty(aProperty: TRttiProperty; aValue: TValue; aEntity : TObject);

function EnumAsString(aEnum : TTypeKind) : string;

function GetEntityPropertyByName(aEntityPropertyName: string; aEntity : TObject): ResultEntityPropertyByName;

function GetEntityListPropertyByName(aEntityPropertyName: string; aEntity : TObjectList<TObject>; aValue : TValue): ResultEntityPropertyByName;

implementation

procedure SetValueToProperty(aProperty: TRttiProperty; aValue: TValue; aEntity : TObject);
begin
  case aProperty.PropertyType.TypeKind of
    tkInteger:
    begin
      if aValue.Kind in [tkString, tkChar, tkWChar, tkLString, tkWString, tkUString, tkAnsiChar] then
        aProperty.SetValue(Pointer(aEntity), StrToInt(aValue.AsString))
      else
        aProperty.SetValue(Pointer(aEntity), aValue.AsInteger);
    end;
    tkInt64:
    begin
      if aValue.Kind in [tkString, tkChar, tkWChar, tkLString, tkWString, tkUString, tkAnsiChar] then
        aProperty.SetValue(Pointer(aEntity), StrToInt64(aValue.AsString))
      else
        aProperty.SetValue(Pointer(aEntity), aValue.AsInt64);
    end;
    tkFloat:
    begin
      if aProperty.PropertyType.Name = 'TDateTime' then
        aProperty.SetValue(Pointer(aEntity), StrToDateTime(aValue.AsString))
      else if aValue.Kind in [tkString, tkChar, tkWChar, tkLString, tkWString, tkUString, tkAnsiChar] then
        aProperty.SetValue(Pointer(aEntity), StrToFloat(aValue.AsString))
      else
        aProperty.SetValue(Pointer(aEntity), aValue.AsExtended);
    end;
    tkChar: aProperty.SetValue(Pointer(aEntity), aValue.AsString);
    tkString: aProperty.SetValue(Pointer(aEntity), aValue.AsString);
    tkWChar: aProperty.SetValue(Pointer(aEntity), aValue.AsString);
    tkLString: aProperty.SetValue(Pointer(aEntity), aValue.AsString);
    tkWString: aProperty.SetValue(Pointer(aEntity), aValue.AsString);
    tkUString: aProperty.SetValue(Pointer(aEntity), aValue.AsString);
    tkUnknown: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkUnknown']));
    tkEnumeration: aProperty.SetValue(Pointer(aEntity), aValue.AsBoolean);
    tkSet: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkSet']));
    tkClass: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkClass']));
    tkMethod: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkMethod']));
    tkArray: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkArray']));
    tkRecord: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkRecord']));
    tkInterface: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkInterface']));
    tkDynArray: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkDynArray']));
    tkClassRef: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkClassRef']));
    tkPointer: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkPointer']));
    tkProcedure: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkProcedure']));
    tkMRecord: raise OrionBindingsException.Create(Format('Type %s not supported.', ['tkMRecord']));
  end;
end;

function EnumAsString(aEnum : TTypeKind) : string;
begin
  Result := GetEnumName(TypeInfo(TTypeKind), integer(tkUnknown));
end;

function GetEntityPropertyByName(aEntityPropertyName: string; aEntity : TObject): ResultEntityPropertyByName;
var
  lContext : TRttiContext;
  lType : TRttiType;
  lProperty : TrttiProperty;
  lResult : ResultEntityPropertyByName;
  lStrings : TArray<string>;
  I : integer;
  lObject : TObject;
  IsCompound : boolean;
begin
  IsCompound := False;
  lContext := TRttiContext.Create;
  lType := lContext.GetType(aEntity.ClassInfo);
  try
    if aEntityPropertyName.Contains('.') then begin
      IsCompound := True;
      lStrings := SplitString(aEntityPropertyName, '.');
      for I := 0 to Pred(Length(lStrings)) do begin
        lResult := GetEntityPropertyByName(lStrings[i], aEntity);
        if lResult.&Property.PropertyType.TypeKind = tkClass then begin
          lObject := lResult.Entity;
          lResult := GetEntityPropertyByName(lStrings[I+1], lObject);
        end;

        if lResult.&Property.Name = lStrings[Pred(Length(lStrings))] then begin
          Result.&Property := lResult.&Property;
          Result.Entity := lResult.Entity;
          Break;
        end;
      end;
    end
    else begin
      lProperty := lType.GetProperty(aEntityPropertyName);
      Result.&Property := lProperty;
      if lProperty.PropertyType.TypeKind = tkClass then
        Result.Entity := lProperty.GetValue(Pointer(aEntity)).AsObject
      else
        Result.Entity := aEntity;
    end;
  finally
    if not IsCompound then
      lType.DisposeOf;
  end;
end;

function GetEntityListPropertyByName(aEntityPropertyName: string; aEntity : TObjectList<TObject>; aValue : TValue): ResultEntityPropertyByName;
var
  lObject: TObject;
begin
  for lObject in aEntity do
  begin
    Result := GetEntityPropertyByName(aEntityPropertyName, lObject);
    if Assigned(Result.&Property) then
      Continue;

    if Result.&Property.GetValue(Pointer(lObject)).AsVariant = aValue.AsVariant then
      Exit;
  end;
end;

end.
