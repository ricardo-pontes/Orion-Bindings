unit Orion.Bindings.Types;

interface

uses
  Orion.Bindings.Middleware,
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
    RemoveSimbolsIn : boolean;
    Middlewares : array of OrionBindingsMiddleware;
  end;

  OrionBindingsException = class(Exception)

  end;

implementation

end.
