unit Orion.Bindings.Middleware;

interface

uses
  System.Rtti;

type
  {$SCOPEDENUMS ON}
    OrionBindingsMiddlewareState = (BindToEntity, BindToView);
  {$SCOPEDENUMS OFF}
  OrionBindingsMiddleware = reference to procedure(var aValue : TValue; aState : OrionBindingsMiddlewareState);

implementation

end.
