unit Orion.Bindings;

interface

uses
  System.Classes,
  Orion.Bindings.Interfaces,
  Orion.Bindings.Container,
  Orion.Bindings.Data,
  Orion.Bindings.Middlewares,
  Orion.Bindings.Core;

type
  TOrionBindings = class(TInterfacedObject, iOrionBindings)
  private
    FContainer : TOrionBindingsContainer;
    FData : TOrionBindingsData;
    FMiddlewares : TOrionBindingsMiddlewares;
    FCore : TOrionBindingsCore;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iOrionBindings;

    function AddBind(aComponentName : string; aObjectPropertyName : string) : iOrionBindings; overload;
    function AddBind(aComponentName : string; aObjectPropertyNameIn, aObjectPropertyNameOut : string) : iOrionBindings; overload;
    function View(aView : TComponent) : iOrionBindings;
    function Entity(aEntity : TObject) : iOrionBindings;
    function Use(aMiddleware : iOrionMiddleware) : iOrionBindings;
    function BindToEntity : iOrionBindings;
    function BindToView : iOrionBindings;
  end;

implementation

{ TOrionBindings }

function TOrionBindings.AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut: string): iOrionBindings;
begin
  Result := Self;
  FData.AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut);
end;

function TOrionBindings.AddBind(aComponentName, aObjectPropertyName: string): iOrionBindings;
begin
  Result := Self;
  FData.AddBind(aComponentName, aObjectPropertyName);
end;

function TOrionBindings.Use(aMiddleware: iOrionMiddleware): iOrionBindings;
begin
  Result := Self;
  FMiddlewares.AddMiddleware(aMiddleware);
end;

function TOrionBindings.BindToEntity: iOrionBindings;
begin
  Result := Self;
  FCore.BindToEntity;
end;

function TOrionBindings.BindToView: iOrionBindings;
begin
  Result := Self;
  FCore.BindToView;
end;

constructor TOrionBindings.Create;
begin
  FContainer   := TOrionBindingsContainer.Create;
  FData        := TOrionBindingsData.Create;
  FMiddlewares := TOrionBindingsMiddlewares.Create;
  FCore        := TOrionBindingsCore.Create(FContainer, FData, FMiddlewares);
end;

destructor TOrionBindings.Destroy;
begin
  FContainer.DisposeOf;
  FData.DisposeOf;
  FMiddlewares.DisposeOf;
  FCore.DisposeOf;
  inherited;
end;

class function TOrionBindings.New: iOrionBindings;
begin
  Result := Self.Create;
end;

function TOrionBindings.Entity(aEntity : TObject) : iOrionBindings;
begin
  Result := Self;
  FContainer.Entity(aEntity);
end;

function TOrionBindings.View(aView: TComponent): iOrionBindings;
begin
  Result := Self;
  FCore.BindToView;
end;

end.
