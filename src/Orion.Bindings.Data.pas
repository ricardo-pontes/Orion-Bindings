unit Orion.Bindings.Data;

interface

uses
  System.Generics.Collections,
  Orion.Bindings.Types, Orion.Bindings.Middleware;

type
  TOrionBindingsData = class
  private
    FBinds : TList<TOrionBind>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddBind(aComponentName, aObjectPropertyName : string); overload;
    procedure AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut : string); overload;
    procedure AddBind(aComponentName : string; aObjectPropertyName : string; aMiddlewares : array of OrionBindingsMiddleware); overload;
    procedure AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut : string; aRemoveSimbolsIn : boolean); overload;
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

procedure TOrionBindingsData.AddBind(aComponentName, aObjectPropertyNameIn, aObjectPropertyNameOut: string;
  aRemoveSimbolsIn: boolean);
var
  lOrionBind : TOrionBind;
begin
  lOrionBind.&Type := TOrionBindType.Compound;
  lOrionBind.ComponentName := aComponentName;
  lOrionBind.ObjectPropertyNameIn := aObjectPropertyNameIn;
  lOrionBind.ObjectPropertyNameOut := aObjectPropertyNameOut;
  lOrionBind.RemoveSimbolsIn := aRemoveSimbolsIn;
  FBinds.Add(lOrionBind);
end;

procedure TOrionBindingsData.AddBind(aComponentName, aObjectPropertyName: string;
  aMiddlewares: array of OrionBindingsMiddleware);
var
  lOrionBind : TOrionBind;
  I : integer;
begin
  lOrionBind.&Type := TOrionBindType.Simple;
  lOrionBind.ComponentName := aComponentName;
  lOrionBind.ObjectPropertyName := aObjectPropertyName;
  for I := 0 to Pred(Length(aMiddlewares)) do
  begin
    SetLength(lOrionBind.Middlewares, I + 1);
    lOrionBind.Middlewares[I] := aMiddlewares[I];
  end;
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
