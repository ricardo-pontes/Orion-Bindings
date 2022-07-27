unit Orion.Bindings;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Orion.Bindings.Interfaces,
  Orion.Bindings.Container,
  Orion.Bindings.Data,
  Orion.Bindings.Frameworks,
  Orion.Bindings.Core,
  Orion.Bindings.Middleware;

type
  TOrionBindings = class(TInterfacedObject, iOrionBindings, iOrionBindingsList)
  private
    FContainer : TOrionBindingsContainer;
    FData : TOrionBindingsData;
    FDataListBinds : TOrionBindingsDataListBinds;
    FDataListBind : TOrionBindingsDataListBind;
    FFrameworks : TOrionBindingsFrameworks;
    FCore : TOrionBindingsCore;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iOrionBindings;

    function AddBind(aComponentName : string; aObjectPropertyName : string) : iOrionBindings; overload;
    function AddBind(aComponentName : string; aObjectPropertyNameIn, aObjectPropertyNameOut : string) : iOrionBindings; overload;
    function AddBind(aComponentName : string; aObjectPropertyName : string; aMiddlewares : array of OrionBindingsMiddleware) : iOrionBindings; overload;
    function AddBind(aComponentName : string; aObjectPropertyNameIn, aObjectPropertyNameOut : string; aRemoveSimbolsIn : boolean) : iOrionBindings; overload;
    function View(aView : TComponent) : iOrionBindings;
    function Entity(aEntity : TObject) : iOrionBindings;
    function Use(aLibrary : iOrionLibraryFramework) : iOrionBindings;
    function BindToEntity : iOrionBindings;
    function BindToView : iOrionBindings;
    function ListBinds : iOrionBindingsList;

    procedure Init;
    procedure ComponentName(aValue : string);
    procedure ObjectListPropertyName(aValue : string);
    procedure AddListBind(aComponentName, aObjectPropertyName : string); overload;
    procedure AddListBind(aComponentName, aObjectPropertyName : string; aMiddlewares : array of OrionBindingsMiddleware); overload;
    procedure Finish;
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

function TOrionBindings.Use(aLibrary: iOrionLibraryFramework): iOrionBindings;
begin
  Result := Self;
  FFrameworks.AddFramework(aLibrary);
end;

function TOrionBindings.AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut: string;
  aRemoveSimbolsIn: boolean): iOrionBindings;
begin
  Result := Self;
  FData.AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut, aRemoveSimbolsIn);
end;

procedure TOrionBindings.AddListBind(aComponentName, aObjectPropertyName: string);
begin
  FDataListBind.AddBind(aComponentName, aObjectPropertyName, []);
end;

function TOrionBindings.AddBind(aComponentName, aObjectPropertyName: string;
  aMiddlewares: array of OrionBindingsMiddleware): iOrionBindings;
begin
  Result := Self;
  FData.AddBind(aComponentName, aObjectPropertyName, aMiddlewares);
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

procedure TOrionBindings.ComponentName(aValue: string);
begin
  FDataListBind.ComponentName(aValue);
end;

constructor TOrionBindings.Create;
begin
  FContainer     := TOrionBindingsContainer.Create;
  FData          := TOrionBindingsData.Create;
  FDataListBinds := TOrionBindingsDataListBinds.Create;
  FFrameworks    := TOrionBindingsFrameworks.Create;
  FCore          := TOrionBindingsCore.Create(FContainer, FData, FFrameworks, FDataListBinds);
end;

destructor TOrionBindings.Destroy;
begin
  FContainer.DisposeOf;
  FData.DisposeOf;
  FFrameworks.DisposeOf;
  FCore.DisposeOf;
  FDataListBinds.DisposeOf;
  inherited;
end;

class function TOrionBindings.New: iOrionBindings;
begin
  Result := Self.Create;
end;

procedure TOrionBindings.ObjectListPropertyName(aValue: string);
begin
  FDataListBind.ObjectListName(aValue);
end;

function TOrionBindings.Entity(aEntity : TObject) : iOrionBindings;
begin
  Result := Self;
  FContainer.Entity(aEntity);
end;

procedure TOrionBindings.Finish;
begin
  FDataListBinds.AddDataListBind(FDataListBind);
end;

procedure TOrionBindings.Init;
begin
  FDataListBind := TOrionBindingsDataListBind.Create;
end;

function TOrionBindings.ListBinds: iOrionBindingsList;
begin
  Result := Self;
end;

function TOrionBindings.View(aView: TComponent): iOrionBindings;
begin
  Result := Self;
  FContainer.View(aView);
end;

procedure TOrionBindings.AddListBind(aComponentName, aObjectPropertyName: string;
  aMiddlewares: array of OrionBindingsMiddleware);
begin
  FDataListBind.AddBind(aComponentName, aObjectPropertyName, aMiddlewares);
end;

end.
