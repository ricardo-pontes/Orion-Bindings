unit Orion.Bindings.Core;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  Orion.Bindings.Container,
  Orion.Bindings.Data,
  Orion.Bindings.Frameworks,
  Orion.Bindings.Types,
  Orion.Bindings.Middleware;

type
  TOrionBindingsCore = class
  private
    FContainer : TOrionBindingsContainer;
    FData : TOrionBindingsData;
    FDataListBinds : TOrionBindingsDataListBinds;
    FFrameworks : TOrionBindingsFrameworks;
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
  public
    constructor Create(aContainer : TOrionBindingsContainer; aData : TOrionBindingsData; aMiddlewares : TOrionBindingsFrameworks; aDataListBinds : TOrionBindingsDataListBinds);
    destructor Destroy; override;

    procedure BindToView;
    procedure BindToEntity;
  end;

implementation

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Rtti, System.Generics.Collections;

{ TOrionBindingsCore }

procedure TOrionBindingsCore.BindListToEntity;
var
  lListBind : TOrionBindingsDataListBind;
  lComponent : TComponent;
  lBind : TOrionBind;
  lValueListCount, lValue : TValue;
  I: Integer;
  lListValue : TOrionBindSyncList;
begin
  for lListBind in FDataListBinds.Binds do begin
    CheckIfComponentNameExist(lListBind.ComponentName);
    CheckIfComponentNameExist(lListBind.ObjectListName);
    lListBind.Validate;
  end;

  for lListBind in FDataListBinds.Binds do begin
    lComponent := FContainer.View.FindComponent(lListBind.ComponentName);
    Synchronize(TOrionMiddlewareCommand.BindToEntityGetListCount, lComponent, lValueListCount);
    for I := 0 to Pred(lValueListCount.AsInteger) do begin
      for lBind in lListBind.Binds do
      begin
        lListValue.Index := I;
        lListValue.ComponentName := lBind.ComponentName;
        lValue.From<TOrionBindSyncList>(lListValue);
        Synchronize(TOrionMiddlewareCommand.ListBindGetValue, lComponent, lValue);
      end;
    end;

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
begin
//  for lListBind in FDataListBinds.Binds do begin
//    CheckIfComponentNameExist(lListBind.ComponentName);
//    CheckIfObjectPropertyNameExist(lListBind.ObjectListName);
//    lListBind.Validate;
//  end;

  for lListBind in FDataListBinds.Binds do begin
    lResultObjectList := GetEntityPropertyByName(lListBind.ObjectListName, FContainer.Entity);
    lComponent := FContainer.View.FindComponent(lListBind.ComponentName);

    if not lResultObjectList.Entity.ClassName.Contains('List<') then
      Exit;

    Synchronize(TOrionMiddlewareCommand.BindToViewListBindClear, lComponent, lValue);
    lObjectList := TObjectList<TObject>(lResultObjectList.Entity);
    for lObject in lObjectList do begin
      Synchronize(TOrionMiddlewareCommand.BindToViewListBindAddRow, lComponent, lValue);
      for lBind in lListBind.Binds do begin
        lResultProperty := GetEntityPropertyByName(lBind.ObjectPropertyName, lObject);
        lListValue := TorionBindSyncList.Create;
        try
          lListValue.ComponentName := lBind.ComponentName;
          lListValue.Value := lResultProperty.&Property.GetValue(Pointer(lObject));
          ExecuteMiddlewares(lValue, lBind, OrionBindingsMiddlewareState.BindToView);
          lValue := lListValue;
          Synchronize(TOrionMiddlewareCommand.ListBindUpdateValue, lComponent, lValue);
        finally
          lListValue.DisposeOf;
        end;
      end;
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

constructor TOrionBindingsCore.Create(aContainer : TOrionBindingsContainer; aData : TOrionBindingsData; aMiddlewares : TOrionBindingsFrameworks; aDataListBinds : TOrionBindingsDataListBinds);
begin
  FContainer   := aContainer;
  FData        := aData;
  FFrameworks := aMiddlewares;
  FDataListBinds := aDataListBinds;
end;

destructor TOrionBindingsCore.Destroy;
begin

  inherited;
end;

procedure TOrionBindingsCore.ExecuteMiddlewares(var aValue: TValue; aBind : TOrionBind; aMiddlewareState : OrionBindingsMiddlewareState);
var
  lMiddleware : OrionBindingsMiddleware;
begin
  for lMiddleware in aBind.Middlewares do
   lMiddleware(aValue, aMiddlewareState);
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
  lFramework: iOrionLibraryFramework;
begin
  for lFramework in FFrameworks.Frameworks do begin
    lFramework.Synchronize(aCommand, aComponent, aValue);
  end;
end;

end.
