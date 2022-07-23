unit Orion.Bindings.Middlewares.FMX.Native;

interface

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Types,
  System.Rtti,
  System.Classes;

type
  TOrionBindingsMiddlewaresFMXNative = class(TInterfacedObject, iOrionMiddleware)
  private

  public
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
  end;

implementation

uses
  FMX.Edit;

{ TOrionBindingsMiddlewaresFMXNative }

procedure TOrionBindingsMiddlewaresFMXNative.Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
begin
  case aCommand of
    TOrionMiddlewareCommand.BindToEntity:
    begin
      if aComponent is TEdit then
        aValue := TEdit(aComponent).Text;
    end;
    TOrionMiddlewareCommand.BindToView:
    begin
      if aComponent is TEdit then
        TEdit(aComponent).Text := aValue.ToString;
    end;
    TOrionMiddlewareCommand.BindToViewListBindClear: ;
    TOrionMiddlewareCommand.BindToViewListBindAddRow: ;
    TOrionMiddlewareCommand.BindToEntityListBindNextRow: ;
    TOrionMiddlewareCommand.ListBindUpdateValue: ;
  end;
end;

end.
