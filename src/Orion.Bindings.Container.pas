unit Orion.Bindings.Container;

interface

uses
  System.Classes;

type
  TOrionBindingsContainer = class
  private
    FView : TComponent;
    FEntity : TObject;
  public
    procedure View(aView : TComponent); overload;
    function View : TComponent; overload;
    procedure Entity(aEntity : TObject); overload;
    function Entity : TObject; overload;
  end;

implementation

{ TOrionBindingsContainer }

procedure TOrionBindingsContainer.Entity(aEntity: TObject);
begin
  FEntity := aEntity;
end;

function TOrionBindingsContainer.Entity: TObject;
begin
  Result := FEntity;
end;

procedure TOrionBindingsContainer.View(aView: TComponent);
begin
  FView := aView;
end;

function TOrionBindingsContainer.View: TComponent;
begin
  Result := FView;
end;

end.
