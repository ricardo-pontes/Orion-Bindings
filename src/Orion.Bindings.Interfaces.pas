unit Orion.Bindings.Interfaces;

interface

uses
  System.Classes,
  System.Rtti,
  Orion.Bindings.Types,
  Orion.Bindings.Middleware;

type
  iOrionLibraryFramework = interface;

  iOrionBindings = interface
    function Use(aLibrary : iOrionLibraryFramework) : iOrionBindings;
    function View(aView : TComponent) : iOrionBindings;
    function Entity(aEntity : TObject) : iOrionBindings;
    function AddBind(aComponentName : string; aObjectPropertyName : string) : iOrionBindings; overload;
    function AddBind(aComponentName : string; aObjectPropertyName : string; aMiddlewares : array of OrionBindingsMiddleware) : iOrionBindings; overload;
//    function AddBind(aComponentName : string; aObjectPropertyNameIn, aObjectPropertyNameOut : string) : iOrionBindings; overload;
//    function AddBind(aComponentName : string; aObjectPropertyNameIn, aObjectPropertyNameOut : string; aRemoveSimbolsIn : boolean) : iOrionBindings; overload;
    function BindToEntity : iOrionBindings;
    function BindToView : iOrionBindings;
  end;


  iOrionLibraryFramework = interface
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
  end;

implementation

end.
