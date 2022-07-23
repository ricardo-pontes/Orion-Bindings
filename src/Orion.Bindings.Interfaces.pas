unit Orion.Bindings.Interfaces;

interface

uses
  System.Classes,
  System.Rtti,
  Orion.Bindings.Types;

type
  iOrionMiddleware = interface;

  iOrionBindings = interface
    function Use(aMiddleware : iOrionMiddleware) : iOrionBindings;
    function View(aView : TComponent) : iOrionBindings;
    function Entity(aEntity : TObject) : iOrionBindings;
    function AddBind(aComponentName : string; aObjectPropertyName : string) : iOrionBindings; overload;
    function AddBind(aComponentName : string; aObjectPropertyNameIn, aObjectPropertyNameOut : string) : iOrionBindings; overload;
    function BindToEntity : iOrionBindings;
    function BindToView : iOrionBindings;
  end;

  iOrionMiddleware = interface
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
  end;

implementation

end.
