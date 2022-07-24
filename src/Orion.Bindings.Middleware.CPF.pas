unit Orion.Bindings.Middleware.CPF;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.MaskUtils,
  Orion.Bindings.Middleware;

procedure MiddlewareCPF(var aValue : TValue; aState : OrionBindingsMiddlewareState);

implementation

procedure MiddlewareCPF(var aValue : TValue; aState : OrionBindingsMiddlewareState);
var
  lIndex : integer;
  lValue : string;
  lNewValue : string;
begin
  if aState = OrionBindingsMiddlewareState.BindToEntity then begin
    lValue := aValue.ToString;
    for lIndex := 1 to Length(lValue) do begin
      if CharInSet(lValue[lIndex], ['0'..'9']) then
        lNewValue := lNewValue + lValue[lIndex];
    end;

    aValue := lNewValue;
  end
  else
  begin
    lValue := aValue.ToString;
    Delete(lValue, AnsiPos('.',lValue),1);
    Delete(lValue, AnsiPos('.',lValue),1);
    Delete(lValue, AnsiPos('-',lValue),1);
    Delete(lValue, AnsiPos('/',lValue),1);
    aValue := FormatMaskText('000\.000\.000\-00;0;',lValue);
  end;
end;

end.
