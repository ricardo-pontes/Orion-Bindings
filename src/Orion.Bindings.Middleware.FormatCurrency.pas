unit Orion.Bindings.Middleware.FormatCurrency;

interface

uses
  System.Rtti,
  System.SysUtils,
  Orion.Bindings.Middleware;

procedure FormatCurrency(var aValue : TValue; aState : OrionBindingsMiddlewareState);

implementation

procedure FormatCurrency(var aValue : TValue; aState : OrionBindingsMiddlewareState);
var
  lValue : string;
begin
  if aState = OrionBindingsMiddlewareState.BindToView then begin
    lValue := FormatFloat('R$ ,#0.00', aValue.AsCurrency);
    aValue := lValue;
  end
  else if aState = OrionBindingsMiddlewareState.BindToEntity then begin
    lValue := aValue.AsString.Replace('R$', '', [rfReplaceAll]).Replace(' ', '', [rfReplaceAll]).Replace('.', '', [rfReplaceAll]);
    aValue := lValue;
  end;
end;

end.
