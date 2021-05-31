unit Orion.Bindings;

interface

uses
  Orion.Bindings.Interfaces,
  FMX.Forms,
  System.Generics.Collections, System.Classes;

type
  TOrionBinding = class(TInterfacedObject, iOrionBinding)
  private
    FView : TComponent;
    FEntity : TObject;
    FFrameworkList : TList<iOrionBindingFramework>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iOrionBinding;

    function Use(aFramework : iOrionBindingFramework) : iOrionBinding;
    function Entity(aEntity : TObject) : iOrionBinding;
    function View(aView : TComponent) : iOrionBinding;
    function BindToView : iOrionBinding;
    function BindToEntity : iOrionBinding;
  end;
implementation

{ TOrionBinding }

function TOrionBinding.Use(aFramework: iOrionBindingFramework): iOrionBinding;
begin
  Result := Self;
  if not FFrameworkList.Contains(aFramework) then
    FFrameworkList.Add(aFramework);
end;

function TOrionBinding.BindToEntity: iOrionBinding;
begin
  Result := Self;
end;

function TOrionBinding.BindToView: iOrionBinding;
var
  lFramework: iOrionBindingFramework;
begin
  Result := Self;
  for lFramework in FFrameworkList do
    lFramework.BindToView(FView, FEntity);
end;

constructor TOrionBinding.Create;
begin
  FFrameworkList := TList<iOrionBindingFramework>.Create;
  end;

destructor TOrionBinding.Destroy;
begin
  FFrameworkList.DisposeOf;
  inherited;
end;

function TOrionBinding.Entity(aEntity: TObject): iOrionBinding;
begin
  Result := Self;
  FEntity := aEntity;
end;

class function TOrionBinding.New: iOrionBinding;
begin
  Result := Self.Create;
end;

function TOrionBinding.View(aView : TComponent) : iOrionBinding;
begin
  Result := Self;
  FView := aView;
end;

end.
