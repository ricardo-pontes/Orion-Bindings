unit Orion.Bindings.Data;

interface

uses
  System.Generics.Collections,
  Orion.Bindings.Types;

type
  TOrionBindingsData = class
  private
    FBinds : TList<TOrionBind>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddBind(aComponentName, aObjectPropertyName : string); overload;
    procedure AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut : string); overload;
    function Binds : TList<TOrionBind>;
  end;

implementation

{ TOrionBindingsData }

procedure TOrionBindingsData.AddBind(aComponentName, aObjectPropertyName: string);
var
  lOrionBind : TOrionBind;
begin
  lOrionBind.&Type := TOrionBindType.Simple;
  lOrionBind.ComponentName := aComponentName;
  lOrionBind.ObjectPropertyName := aObjectPropertyName;
  FBinds.Add(lOrionBind);
end;

procedure TOrionBindingsData.AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut: string);
var
  lOrionBind : TOrionBind;
begin
  lOrionBind.&Type := TOrionBindType.Compound;
  lOrionBind.ComponentName := aComponentName;
  lOrionBind.ObjectPropertyNameIn := aObjectPropertyNameIn;
  lOrionBind.ObjectPropertyNameOut := aObjectPropertyNameOut;
  FBinds.Add(lOrionBind);
end;

function TOrionBindingsData.Binds: TList<TOrionBind>;
begin
  Result := FBinds;
end;

constructor TOrionBindingsData.Create;
begin
  FBinds := TList<TOrionBind>.Create;
end;

destructor TOrionBindingsData.Destroy;
begin
  FBinds.DisposeOf;
  inherited;
end;

end.
