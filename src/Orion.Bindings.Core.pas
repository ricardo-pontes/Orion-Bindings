unit Orion.Bindings.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  Orion.Bindings.Container,
  Orion.Bindings.Data,
  Orion.Bindings.VisualFrameworks,
  Orion.Bindings.Types,
  Orion.Bindings.Middleware;

type
  TOrionBindingsCore = class
  private
    FContainer : TOrionBindingsContainer;
    FData : TOrionBindingsData;
    FDataListBinds : TOrionBindingsDataListBinds;
    FFrameworks : TOrionBindingsVisualFrameworks;
    FObjectListKeyIndexCount : TDictionary<string, SmallInt>;
    procedure BindListToEntity;
    procedure BindListToView;
    procedure SimpleBindToView(aBind : TOrionBind);
    procedure SimpleBindToEntity(aBind : TOrionBind);
    procedure CompoundBindToView(aBind : TOrionBind);
    procedure CompoundBindToEntity(aBind : TOrionBind);
    procedure CheckIfComponentNamesExists;
    procedure CheckIfComponentNameExist(aComponentName : string);
    procedure CheckIfObjectPropertyNamesExists;
    procedure CheckIfObjectPropertyNameExist(aObjectPropertyName : string);
    procedure ExecuteMiddlewares(var aValue: TValue; aBind : TOrionBind; aMiddlewareState : OrionBindingsMiddlewareState);
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
    function GetPrimaryKeyComponentName(aBind : TOrionBindingsDataListBind) : string;
    function GetComponentListValue(aComponentListName: string; aComponent : TComponent; aIndex: integer): TValue;
    function GetObjectByKeyValue(aKeyValue : TValue; aPrimaryKeyName : string; aObjectList : TObjectList<TObject>) : TObject;
    procedure SimpleListBindToEntity(aListBind: TOrionBindingsDataListBind; aComponent: TComponent; aIndex, aNegativeCount: Integer; var aValue: TValue; aObject: TObject; aListSynkEntityIndex : TList<TOrionBindKeyPropertySynk>);
    function ValueIsEmpty(aValue : TValue) : boolean;
    procedure ValidateListBindsData;
    function GetListSynkEntityIndex(lListBind: TOrionBindingsDataListBind) : TList<TOrionBindKeyPropertySynk>;
    function IsInListSynkEntityIndex(aListSynkEntityIndex : TList<TOrionBindKeyPropertySynk>; aValue : TValue) : boolean;
    procedure RemoveUnSynkedEntities(aListBind : TOrionBindingsDataListBind; aSynkedEntityList : TList<TOrionBindKeyPropertySynk>);
    procedure SetObjectIsSynked(aValue : TValue; aSynkedEntityList : TList<TOrionBindKeyPropertySynk>);
  public
    constructor Create(aContainer : TOrionBindingsContainer; aData : TOrionBindingsData; aMiddlewares : TOrionBindingsVisualFrameworks; aDataListBinds : TOrionBindingsDataListBinds);
    destructor Destroy; override;

    procedure BindToView;
    procedure BindToEntity;
  end;

implementation

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Rtti;

{ TOrionBindingsCore }

procedure TOrionBindingsCore.BindListToEntity;
var
  lListBind : TOrionBindingsDataListBind;
  lComponent : TComponent;
  lValueListCount, lValue : TValue;
  lResultObjectList : ResultEntityPropertyByName;
  lObject : TObject;
  Index, lNegativeCount: integer;
  lComponentListName : string;
  lSynkedEntityList : TList<TOrionBindKeyPropertySynk>;
begin
  ValidateListBindsData;
  lNegativeCount := 0;
  lSynkedEntityList := nil;
  try
    for lListBind in FDataListBinds.Binds do begin
      if lListBind.IsSeparatedOfEntityBindList then
        Continue;

      if Assigned(lListBind.Bitmap) then
        Continue;

      if Assigned(lSynkedEntityList) then
        lSynkedEntityList.DisposeOf;

      if not FObjectListKeyIndexCount.ContainsKey(lListBind.ObjectListName) then
        FObjectListKeyIndexCount.Add(lListBind.ObjectListName, 0);

      lComponent := FContainer.View.FindComponent(lListBind.ComponentName);
      Synchronize(TOrionMiddlewareCommand.BindToEntityGetListCount, lComponent, lValueListCount);
      lSynkedEntityList :=  GetListSynkEntityIndex(lListBind);
      for Index := 0 to Pred(lValueListCount.AsInteger) do begin
        if lComponentListName.IsEmpty then
          lComponentListName := GetPrimaryKeyComponentName(lListBind);

        lValue := GetComponentListValue(lComponentListName, lComponent, Index);

        if not ValueIsEmpty(lValue) then begin
          lResultObjectList := GetEntityPropertyByName(lListBind.ObjectListName, FContainer.Entity);
          lObject := GetObjectByKeyValue(lValue, lListBind.PrimaryKeyName, TObjectList<TObject>(lResultObjectList.&Property.GetValue(Pointer(FContainer.Entity)).AsObject));
          SimpleListBindToEntity(lListBind, lComponent, Index, lNegativeCount, lValue, lObject, lSynkedEntityList);
        end
        else begin
          var lPair := FObjectListKeyIndexCount.ExtractPair(lListBind.ObjectListName);
          Dec(lPair.Value);
          lPair.Value := lPair.Value;
          FObjectListKeyIndexCount.AddOrSetValue(lPair.Key, lPair.Value);
          lNegativeCount := lPair.Value;
          lObject := lListBind.ClassType.Create;
          lResultObjectList := GetEntityPropertyByName(lListBind.ObjectListName, FContainer.Entity);
          SimpleListBindToEntity(lListBind, lComponent, Index, lNegativeCount, lValue, lObject, lSynkedEntityList);
          TObjectList<TObject>(lResultObjectList.&Property.GetValue(Pointer(FContainer.Entity)).AsObject).Add(lObject);
        end;
      end;
      RemoveUnSynkedEntities(lListBind, lSynkedEntityList);
    end;
  finally
    if Assigned(lSynkedEntityList) then
      lSynkedEntityList.DisposeOf;
  end;
end;

procedure TOrionBindingsCore.BindListToView;
var
  lListBind : TOrionBindingsDataListBind;
  lResultObjectList : ResultEntityPropertyByName;
  lObjectList : TObjectList<TObject>;
  lObject : TObject;
  lComponent : TComponent;
  lValue : TValue;
  lResultProperty : ResultEntityPropertyByName;
  lBind: TOrionBind;
  lListValue : TOrionBindSyncList;
  lIndex : integer;
begin
  ValidateListBindsData;
  for lListBind in FDataListBinds.Binds do begin
    lObjectList := nil;
    lIndex := 0;
    if lListBind.IsSeparatedOfEntityBindList then
      lObjectList := TObjectList<TObject>(lListBind.ObjectList)
    else
      lResultObjectList := GetEntityPropertyByName(lListBind.ObjectListName, FContainer.Entity);

    lComponent := FContainer.View.FindComponent(lListBind.ComponentName);

    if not Assigned(lObjectList) then
      if not lResultObjectList.Entity.ClassName.Contains('List<') then
        Exit;

    Synchronize(TOrionMiddlewareCommand.BindToViewListBindClear, lComponent, lValue);
    if not Assigned(lObjectList) then
      lObjectList := TObjectList<TObject>(lResultObjectList.Entity);
    for lObject in lObjectList do begin
      Synchronize(TOrionMiddlewareCommand.BindToViewListBindAddRow, lComponent, lValue);
      for lBind in lListBind.Binds do begin
        if not lBind.ObjectPropertyName.IsEmpty then
          lResultProperty := GetEntityPropertyByName(lBind.ObjectPropertyName, lObject);
        lListValue := TorionBindSyncList.Create;
        try
          lListValue.Index := lIndex;
          lListValue.ComponentName := lBind.ComponentName;

          if not lBind.ObjectPropertyName.IsEmpty then
            lListValue.Value := lResultProperty.&Property.GetValue(Pointer(lResultProperty.Entity))
          else
            lListValue.Value := lBind.Bitmap;

          ExecuteMiddlewares(lListValue.Value, lBind, OrionBindingsMiddlewareState.BindToView);
          lValue := lListValue;
          Synchronize(TOrionMiddlewareCommand.ListBindUpdateValue, lComponent, lValue);
        finally
          lListValue.DisposeOf;
        end;
      end;
      Inc(lIndex);
    end;
  end;
end;

procedure TOrionBindingsCore.BindToEntity;
var
  lBind: TOrionBind;
begin
  CheckIfComponentNamesExists;
  CheckIfObjectPropertyNamesExists;
  for lBind in FData.Binds do begin
    if lBind.&Type = TOrionBindType.Simple then begin
      SimpleBindToEntity(lBind);
    end
    else if lBind.&Type = TOrionBindType.Compound then begin
      CompoundBindToEntity(lBind);
    end;
  end;

  if FDataListBinds.Count > 0 then begin
    BindListToEntity;
  end;
end;

procedure TOrionBindingsCore.ValidateListBindsData;
var
  lListBind: TOrionBindingsDataListBind;
begin
  for lListBind in FDataListBinds.Binds do begin
    CheckIfComponentNameExist(lListBind.ComponentName);
    if lListBind.IsSeparatedOfEntityBindList then
      lListBind.Validate(TDataListBindType.SeparatedOfEntity)
    else begin
      if Assigned(lListBind.Bitmap) then
        Continue;

      CheckIfObjectPropertyNameExist(lListBind.ObjectListName);
      lListBind.Validate;
    end;
  end;
end;

procedure TOrionBindingsCore.SimpleListBindToEntity(aListBind: TOrionBindingsDataListBind; aComponent: TComponent; aIndex, aNegativeCount : Integer; var aValue: TValue; aObject: TObject; aListSynkEntityIndex : TList<TOrionBindKeyPropertySynk>);
var
  lBind: TOrionBind;
  lListValue: TOrionBindSyncList;
  lResultProperty: ResultEntityPropertyByName;
  lValue : TValue;
begin
  for lBind in aListBind.Binds do
  begin
    lListValue := TOrionBindSyncList.Create;
    try
      lListValue.Index := aIndex;
      lListValue.ComponentName := lBind.ComponentName;
      aValue := lListValue;
      Synchronize(TOrionMiddlewareCommand.ListBindGetValue, aComponent, aValue);
      ExecuteMiddlewares(TOrionBindSyncList(aValue.AsObject).Value, lBind, OrionBindingsMiddlewareState.BindToEntity);
      if lBind.ObjectPropertyName.IsEmpty then
        Continue;

      lResultProperty := GetEntityPropertyByName(lBind.ObjectPropertyName, aObject);
      if (lResultProperty.&Property.Name = aListBind.PrimaryKeyName) and not IsInListSynkEntityIndex(aListSynkEntityIndex, lResultProperty.&Property.GetValue(Pointer(aObject))) then begin
        lValue := aNegativeCount;
        SetValueToProperty(lResultProperty.&Property, lValue, aObject);
        lListValue.Value := lValue;
        Synchronize(TOrionMiddlewareCommand.ListBindUpdateValue, aComponent, aValue);
        Continue;
      end;
      SetValueToProperty(lResultProperty.&Property, TOrionBindSyncList(aValue.AsObject).Value, aObject);
      if (lResultProperty.&Property.Name = aListBind.PrimaryKeyName) then
        SetObjectIsSynked(lResultProperty.&Property.GetValue(Pointer(aObject)), aListSynkEntityIndex);
    finally
      lListValue.DisposeOf;
    end;
  end;
end;

procedure TOrionBindingsCore.BindToView;
var
  lBind: TOrionBind;
begin
  CheckIfComponentNamesExists;
  CheckIfObjectPropertyNamesExists;
  for lBind in FData.Binds do begin
    if lBind.&Type = TOrionBindType.Simple then begin
      SimpleBindToView(lBind);
    end
    else if lBind.&Type = TOrionBindType.Compound then begin
      CompoundBindToView(lBind);
    end;
  end;

  if FDataListBinds.Count > 0 then begin
    BindListToView;
  end;
end;

procedure TOrionBindingsCore.CheckIfComponentNameExist(aComponentName: string);
var
  lComponent : TComponent;
begin
  lComponent := FContainer.View.FindComponent(aComponentName);
  if not Assigned(lComponent) then
    raise OrionBindingsException.Create(Format('%s: Component %s not found', [OrionBindingsException.ClassName, aComponentName]));
end;

procedure TOrionBindingsCore.CheckIfComponentNamesExists;
var
  lBind: TOrionBind;
begin
  for lBind in FData.Binds do begin
    CheckIfComponentNameExist(lBind.ComponentName);
  end;
end;

procedure TOrionBindingsCore.CheckIfObjectPropertyNameExist(aObjectPropertyName: string);
var
  lResult : ResultEntityPropertyByName;
begin
  lResult := GetEntityPropertyByName(aObjectPropertyName, FContainer.Entity);
  if not Assigned(lResult.&Property) then
    raise OrionBindingsException.Create(Format('%s: Property %s not found', [OrionBindingsException.ClassName, aObjectPropertyName]));
end;

procedure TOrionBindingsCore.CheckIfObjectPropertyNamesExists;
var
  lBind: TOrionBind;
begin
  for lBind in FData.Binds do begin
    if lBind.&Type = TOrionBindType.Simple then begin
      CheckIfObjectPropertyNameExist(lBind.ObjectPropertyName);
    end
    else if lBind.&Type = TOrionBindType.Compound then begin
      CheckIfObjectPropertyNameExist(lBind.ObjectPropertyNameIn);
      CheckIfObjectPropertyNameExist(lBind.ObjectPropertyNameOut);
    end;
  end;
end;

procedure TOrionBindingsCore.CompoundBindToEntity(aBind: TOrionBind);
var
  lResult : ResultEntityPropertyByName;
  lValue : TValue;
  lComponent : TComponent;
begin
  lComponent := FContainer.View.FindComponent(aBind.ComponentName);
  lResult := GetEntityPropertyByName(aBind.ObjectPropertyNameIn, FContainer.Entity);
  Synchronize(TOrionMiddlewareCommand.BindToEntity, lComponent, lValue);
  ExecuteMiddlewares(lValue, aBind, OrionBindingsMiddlewareState.BindToEntity);
  SetValueToProperty(lResult.&Property, lValue, lResult.Entity);
end;

procedure TOrionBindingsCore.CompoundBindToView(aBind: TOrionBind);
var
  lComponent : TComponent;
  lResult : ResultEntityPropertyByName;
  lValue : TValue;
begin
  lComponent := FContainer.View.FindComponent(aBind.ComponentName);
  lResult := GetEntityPropertyByName(aBind.ObjectPropertyNameOut, FContainer.Entity);
  lValue := lResult.&Property.GetValue(Pointer(lResult.Entity));
  ExecuteMiddlewares(lValue, aBind, OrionBindingsMiddlewareState.BindToView);
  Synchronize(TOrionMiddlewareCommand.BindToView, lComponent, lValue);
end;

constructor TOrionBindingsCore.Create(aContainer : TOrionBindingsContainer; aData : TOrionBindingsData; aMiddlewares : TOrionBindingsVisualFrameworks; aDataListBinds : TOrionBindingsDataListBinds);
begin
  FContainer   := aContainer;
  FData        := aData;
  FFrameworks := aMiddlewares;
  FDataListBinds := aDataListBinds;
  FObjectListKeyIndexCount := TDictionary<string, SmallInt>.Create;
end;

destructor TOrionBindingsCore.Destroy;
begin
  FObjectListKeyIndexCount.DisposeOf;
  inherited;
end;

procedure TOrionBindingsCore.ExecuteMiddlewares(var aValue: TValue; aBind : TOrionBind; aMiddlewareState : OrionBindingsMiddlewareState);
var
  lMiddleware : OrionBindingsMiddleware;
begin
  for lMiddleware in aBind.Middlewares do
   lMiddleware(aValue, aMiddlewareState);
end;

function TOrionBindingsCore.GetComponentListValue(aComponentListName: string; aComponent : TComponent; aIndex: integer): TValue;
var
  lListValue : TOrionBindSyncList;
  lValue : TValue;
begin
  lListValue := TOrionBindSyncList.Create;
  try
    lListValue.Index := aIndex;
    lListValue.ComponentName := aComponentListName;
    lValue := lListValue;
    Synchronize(TOrionMiddlewareCommand.ListBindGetValue, aComponent, lValue);
    Result := TOrionBindSyncList(lValue.AsObject).Value;
  finally
    lListValue.DisposeOf;
  end;
end;

function TOrionBindingsCore.GetListSynkEntityIndex(
  lListBind: TOrionBindingsDataListBind): TList<TOrionBindKeyPropertySynk>;
var
  lObjectList: TObjectList<TObject>;
  lResultObject: ResultEntityPropertyByName;
  lResultObjectList : ResultEntityPropertyByName;
  lOrionKeyPropertySynk: TOrionBindKeyPropertySynk;
  lObject: TObject;
begin
  lResultObjectList := GetEntityPropertyByName(lListBind.ObjectListName, FContainer.Entity);
  lObjectList := TObjectList<TObject>(lResultObjectList.&Property.GetValue(Pointer(FContainer.Entity)).AsObject);
  Result := TList<TOrionBindKeyPropertySynk>.Create;
  for lObject in lObjectList do
  begin
    lResultObject := GetEntityPropertyByName(lListBind.PrimaryKeyName, lObject);
    lOrionKeyPropertySynk.Key := lResultObject.&Property.GetValue(Pointer(lObject)).AsVariant;
    lOrionKeyPropertySynk.isSynked := False;
    Result.Add(lOrionKeyPropertySynk);
  end;
end;

function TOrionBindingsCore.GetObjectByKeyValue(aKeyValue : TValue; aPrimaryKeyName : string; aObjectList : TObjectList<TObject>) : TObject;
var
  lObject: TObject;
  lResultProperty : ResultEntityPropertyByName;
  Index : integer;
begin
  Result := nil;
  for Index := Pred(aObjectList.Count) downto 0 do begin
    lObject := aObjectList.Items[Index];
     lResultProperty := GetEntityPropertyByName(aPrimaryKeyName, lObject);
     if not (lResultProperty.&Property.GetValue(Pointer(lObject)).ToString = aKeyValue.ToString) then
       Continue;

     Result := lObject;
     Exit;
  end;

//  for lObject in aObjectList do begin
//     lResultProperty := GetEntityPropertyByName(aPrimaryKeyName, lObject);
//     if not (lResultProperty.&Property.GetValue(Pointer(lObject)).ToString = aKeyValue.ToString) then
//       Continue;
//
//     Result := lObject;
//     Exit;
//  end;
end;

function TOrionBindingsCore.GetPrimaryKeyComponentName(aBind : TOrionBindingsDataListBind) : string;
var
  lBind : TOrionBind;
begin
  for lBind in aBind.Binds do begin
    if not (aBind.PrimaryKeyName = lBind.ObjectPropertyName) then
      Continue;

    Result := lBind.ComponentName;
    Exit;
  end;
end;

function TOrionBindingsCore.IsInListSynkEntityIndex(aListSynkEntityIndex : TList<TOrionBindKeyPropertySynk>; aValue : TValue): boolean;
var
  lKeyProperty: TOrionBindKeyPropertySynk;
  lValue : Variant;
begin
  Result := False;
  for lKeyProperty in aListSynkEntityIndex do begin
    lValue := aValue.AsVariant;
    if lKeyProperty.Key = lValue then begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TOrionBindingsCore.RemoveUnSynkedEntities(aListBind: TOrionBindingsDataListBind; aSynkedEntityList : TList<TOrionBindKeyPropertySynk>);
var
  lResultObjectList : ResultEntityPropertyByName;
  lKeyProperty : TOrionBindKeyPropertySynk;
  lObjectList : TObjectList<TObject>;
  lObject: TObject;
  lValue : TValue;
begin
  lResultObjectList := GetEntityPropertyByName(aListBind.ObjectListName, FContainer.Entity);
  lObjectList := TObjectList<TObject>(lResultObjectList.Entity);
  for lKeyProperty in aSynkedEntityList do begin
    if not lKeyProperty.isSynked then begin
      lValue := TValue.FromVariant(lKeyProperty.Key);
      lObject := GetObjectByKeyValue(lValue, aListBind.PrimaryKeyName, lObjectList);
      lObject := lObjectList.Extract(lObject);
      lObject.DisposeOf;
    end;
  end;
end;

procedure TOrionBindingsCore.SetObjectIsSynked(aValue: TValue; aSynkedEntityList: TList<TOrionBindKeyPropertySynk>);
var
  lKeyProperty: TOrionBindKeyPropertySynk;
  lValue : Variant;
  I: Integer;
begin
  for I := 0 to Pred(aSynkedEntityList.Count) do begin
    lValue := aValue.AsVariant;
    if aSynkedEntityList.Items[I].Key = lValue then begin
      lKeyProperty := aSynkedEntityList.ExtractAt(I);
      lKeyProperty.isSynked := True;
      aSynkedEntityList.Insert(I, lKeyProperty);
      Exit;
    end;
  end;
end;

procedure TOrionBindingsCore.SimpleBindToEntity(aBind: TOrionBind);
var
  lResult : ResultEntityPropertyByName;
  lValue : TValue;
  lComponent : TComponent;
begin
  lComponent := FContainer.View.FindComponent(aBind.ComponentName);
  lResult := GetEntityPropertyByName(aBind.ObjectPropertyName, FContainer.Entity);
  Synchronize(TOrionMiddlewareCommand.BindToEntity, lComponent, lValue);
  ExecuteMiddlewares(lValue, aBind, OrionBindingsMiddlewareState.BindToEntity);
  SetValueToProperty(lResult.&Property, lValue, lResult.Entity);
end;

procedure TOrionBindingsCore.SimpleBindToView(aBind: TOrionBind);
var
  lComponent : TComponent;
  lResult : ResultEntityPropertyByName;
  lValue : TValue;
begin
  lComponent := FContainer.View.FindComponent(aBind.ComponentName);
  lResult := GetEntityPropertyByName(aBind.ObjectPropertyName, FContainer.Entity);
  lValue := lResult.&Property.GetValue(Pointer(lResult.Entity));
  ExecuteMiddlewares(lValue, aBind, OrionBindingsMiddlewareState.BindToView);
  Synchronize(TOrionMiddlewareCommand.BindToView, lComponent, lValue);
end;

procedure TOrionBindingsCore.Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
var
  lFramework: iOrionVisualFramework;
begin
  for lFramework in FFrameworks.Frameworks do begin
    lFramework.Synchronize(aCommand, aComponent, aValue);
  end;
end;

function TOrionBindingsCore.ValueIsEmpty(aValue: TValue): boolean;
begin
  Result := False;
  case aValue.Kind of
    tkInt64: Result := aValue.AsInt64 = 0;
    tkInteger: Result := aValue.AsInteger = 0;
    tkChar, tkWChar, tkLString, tkWString, tkString, tkUString: Result := aValue.ToString.IsEmpty;
    tkFloat: Result := aValue.AsExtended = 0;
    tkUnknown: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkEnumeration: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkSet: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkClass: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkMethod: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkVariant: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkArray: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkRecord: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkInterface: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkDynArray: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkClassRef: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkPointer: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkProcedure: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
    tkMRecord: OrionBindingsException.Create(Format('%s.ValueIsEmpty: Property Type %s not implemented.', [Self.QualifiedClassName, EnumAsString(aValue.Kind)]));
  end;
end;

end.
