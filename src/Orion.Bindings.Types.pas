unit Orion.Bindings.Types;

interface

uses
  System.SysUtils;

type
  {$SCOPEDENUMS ON}
    TOrionBindType = (Simple, Compound);
    TOrionMiddlewareCommand = (BindToEntity, BindToView, BindToViewListBindClear, BindToViewListBindAddRow, BindToEntityListBindNextRow, ListBindUpdateValue);
  {$SCOPEDENUMS OFF}

  TOrionBind = record
    &Type : TOrionBindType;
    ComponentName : string;
    ObjectPropertyName : string;
    ObjectPropertyNameIn : string;
    ObjectPropertyNameOut : string;
  end;

  OrionBindingsException = class(Exception)

  end;

implementation

end.
