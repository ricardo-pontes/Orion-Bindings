unit Orion.Bindings;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Orion.Bindings.Interfaces,
  Orion.Bindings.Container,
  Orion.Bindings.Data,
  Orion.Bindings.VisualFrameworks,
  Orion.Bindings.Core,
  Orion.Bindings.Middleware;

const
  FRAMEWORK_VERSION = '1.1.0';

type
  TOrionBindings = class(TInterfacedObject, iOrionBindings, iOrionBindingsList)
  private
    FContainer : TOrionBindingsContainer;
    FData : TOrionBindingsData;
    FDataListBinds : TOrionBindingsDataListBinds;
    FDataListBind : TOrionBindingsDataListBind;
    FFrameworks : TOrionBindingsVisualFrameworks;
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
    function Use(aLibrary : iOrionVisualFramework) : iOrionBindings;
    function BindToEntity : iOrionBindings;
    function BindToView : iOrionBindings;
    function ListBinds : iOrionBindingsList;

    procedure Init(aIsSeparatedOfEntityBindList : boolean = false);
    procedure ComponentName(aValue : string);
    procedure ObjectListPropertyName(aValue : string);
    procedure ObjectList(aValue : TObject);
    procedure Primarykey(aName : string);
    procedure ClassType(aClassType : TClass);
    procedure AddListBind(aComponentName, aObjectPropertyName : string); overload;
    procedure AddListBind(aComponentName, aObjectPropertyName : string; aMiddlewares : array of OrionBindingsMiddleware); overload;
    procedure Finish;
    function Version : string;
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

function TOrionBindings.Use(aLibrary: iOrionVisualFramework): iOrionBindings;
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

procedure TOrionBindings.ClassType(aClassType: TClass);
begin
  FDataListBind.ClassType(aClassType);
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
  FFrameworks    := TOrionBindingsVisualFrameworks.Create;
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

procedure TOrionBindings.ObjectList(aValue: TObject);
begin
  FDataListBind.ObjectList := aValue;
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

procedure TOrionBindings.Init(aIsSeparatedOfEntityBindList : boolean = false);
begin
  FDataListBind := TOrionBindingsDataListBind.Create;
  FDataListBind.IsSeparatedOfEntityBindList := aIsSeparatedOfEntityBindList;
end;

function TOrionBindings.ListBinds: iOrionBindingsList;
begin
  Result := Self;
end;

function TOrionBindings.Version: string;
begin
  Result := FRAMEWORK_VERSION;
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

procedure TOrionBindings.Primarykey(aName: string);
begin
  FDataListBind.PrimaryKeyName(aName);
end;

end.
