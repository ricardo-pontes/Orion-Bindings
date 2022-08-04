unit Orion.Bindings.Types;

interface

uses
  Orion.Bindings.Middleware,
  System.Rtti,
  System.SysUtils;

type
  {$SCOPEDENUMS ON}
    TOrionBindType = (Simple, Compound, List);
    TOrionMiddlewareCommand = (BindToEntity, BindToView, BindToViewListBindClear, BindToViewListBindAddRow, BindToEntityListBindNextRow, BindToEntityGetListCount, ListBindUpdateValue, ListBindGetValue);
  {$SCOPEDENUMS OFF}

  TOrionBind = record
    &Type : TOrionBindType;
    ComponentName : string;
    ObjectPropertyName : string;
    ObjectListPropertyName : string;
    ObjectPropertyNameIn : string;
    ObjectPropertyNameOut : string;
    RemoveSimbolsIn : boolean;
    Middlewares : array of OrionBindingsMiddleware;
  end;

  TOrionBindSyncList = class
    Index : integer;
    ComponentName : string;
    Value : TValue;
  end;

  TOrionBindKeyPropertySynk = record
    Key : Variant;
    isSynked : boolean;
  end;

  OrionBindingsException = class(Exception)
    constructor Create(aMessage : string);
  end;

implementation

{ OrionBindingsException }

constructor OrionBindingsException.Create(aMessage: string);
begin
  message := Format('OrionBindings Exception - %s', [aMessage]);
end;

end.
