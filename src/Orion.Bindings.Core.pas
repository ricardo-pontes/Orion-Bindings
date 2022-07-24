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
    FFrameworks : TOrionBindingsFrameworks;
    procedure SimpleBindToView(aBind : TOrionBind);
    procedure SimpleBindToEntity(aBind : TOrionBind);
    procedure CompoundBindToView(aBind : TOrionBind);
    procedure CompoundBindToEntity(aBind : TOrionBind);
    procedure CheckIfComponentNamesExists;
    procedure CheckIfObjectPropertyNamesExists;
    procedure ExecuteMiddlewares(var aValue: TValue; aBind : TOrionBind; aMiddlewareState : OrionBindingsMiddlewareState);
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
  public
    constructor Create(aContainer : TOrionBindingsContainer; aData : TOrionBindingsData; aMiddlewares : TOrionBindingsFrameworks);
    destructor Destroy; override;

    procedure BindToView;
    procedure BindToEntity;
  end;

implementation

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Rtti;

{ TOrionBindingsCore }

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
end;

procedure TOrionBindingsCore.CheckIfComponentNamesExists;
var
  lBind: TOrionBind;
  lComponent : TComponent;
begin
  for lBind in FData.Binds do begin
    lComponent := FContainer.View.FindComponent(lBind.ComponentName);
    if not Assigned(lComponent) then
      raise OrionBindingsException.Create(Format('%s: Component %s not found', [OrionBindingsException.ClassName, lBind.ComponentName]));
  end;
end;

procedure TOrionBindingsCore.CheckIfObjectPropertyNamesExists;
var
  lBind: TOrionBind;
  lResult : ResultEntityPropertyByName;
begin
  for lBind in FData.Binds do begin
    if lBind.&Type = TOrionBindType.Simple then begin
      lResult := GetEntityPropertyByName(lBind.ObjectPropertyName, FContainer.Entity);
      if not Assigned(lResult.&Property) then
        raise OrionBindingsException.Create(Format('%s: Property %s not found', [OrionBindingsException.ClassName, lBind.ObjectPropertyName]));

    end
    else if lBind.&Type = TOrionBindType.Compound then begin
      lResult := GetEntityPropertyByName(lBind.ObjectPropertyNameIn, FContainer.Entity);
      if not Assigned(lResult.&Property) then
        raise OrionBindingsException.Create(Format('%s: Property %s not found', [OrionBindingsException.ClassName, lBind.ObjectPropertyNameIn]));

      lResult := GetEntityPropertyByName(lBind.ObjectPropertyNameOut, FContainer.Entity);
      if not Assigned(lResult.&Property) then
        raise OrionBindingsException.Create(Format('%s: Property %s not found', [OrionBindingsException.ClassName, lBind.ObjectPropertyNameOut]));
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

constructor TOrionBindingsCore.Create(aContainer: TOrionBindingsContainer; aData: TOrionBindingsData;
  aMiddlewares: TOrionBindingsFrameworks);
begin
  FContainer   := aContainer;
  FData        := aData;
  FFrameworks := aMiddlewares;
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
