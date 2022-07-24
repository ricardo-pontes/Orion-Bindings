unit Orion.Bindings.Framework.FMX.Native;

interface

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Types,
  System.Rtti,
  System.Classes,
  System.SysUtils;

type
  TOrionBindingsMiddlewaresFMXNative = class(TInterfacedObject, iOrionLibraryFramework)
  private

  public
    class function New : iOrionLibraryFramework;
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
  end;

implementation

uses
  FMX.Edit,
  FMX.StdCtrls;

{ TOrionBindingsMiddlewaresFMXNative }

class function TOrionBindingsMiddlewaresFMXNative.New: iOrionLibraryFramework;
begin
  Result := Self.Create;
end;

procedure TOrionBindingsMiddlewaresFMXNative.Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
begin
  case aCommand of
    TOrionMiddlewareCommand.BindToEntity:
    begin
      if aComponent is TEdit then
        aValue := TEdit(aComponent).Text
      else if aComponent is TLabel then
        aValue := TLabel(aComponent).Text
      else
        raise OrionBindingsException.Create(Format('%s: %s not supported', [OrionBindingsException.ClassName, aComponent.ClassName]));
    end;
    TOrionMiddlewareCommand.BindToView:
    begin
      if aComponent is TEdit then
        TEdit(aComponent).Text := aValue.ToString
      else if aComponent is TLabel then
        TLabel(aComponent).Text := aValue.ToString
      else
        raise OrionBindingsException.Create(Format('%s: %s not supported', [OrionBindingsException.ClassName, aComponent.ClassName]));
    end;
    TOrionMiddlewareCommand.BindToViewListBindClear: ;
    TOrionMiddlewareCommand.BindToViewListBindAddRow: ;
    TOrionMiddlewareCommand.BindToEntityListBindNextRow: ;
    TOrionMiddlewareCommand.ListBindUpdateValue: ;
  end;
end;

end.
