unit Orion.Bindings.Container;

interface

uses
  System.Classes,
  System.SysUtils;

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
    function isObjectList : boolean;
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

function TOrionBindingsContainer.isObjectList: boolean;
begin
  Result := FEntity.ClassName.Contains('TObjectList<');
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
