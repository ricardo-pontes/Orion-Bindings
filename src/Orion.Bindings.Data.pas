unit Orion.Bindings.Data;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  Orion.Bindings.Types,
  Orion.Bindings.Middleware
{$IF DECLARED(FireMonkeyVersion)}
  , FMX.Graphics
{$ELSE}
  , VCL.Graphics
{$IFEND}
  ;

type
  {$SCOPEDENUMS ON}
  TDataListBindType = (Entity, SeparatedOfEntity);
  {$SCOPEDENUMS OFF}
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

  TOrionBindingsDataListBind = class
  strict private
    FListBinds : TList<TOrionBind>;
    FComponentName : string;
    FObjectListPropertyName : string;
    FPrimaryKeyName : string;
    FClassType : TClass;
    FBitmap : TBitmap;
    FIsSeparatedOfEntityBindList: boolean;
  private
    FObjectList: TObject;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Validate(aDataListBindType : TDataListBindType = TDataListBindType.Entity);
    procedure ComponentName(aValue : string); overload;
    function ComponentName : string; overload;
    procedure PrimaryKeyName(aValue : string); overload;
    function PrimaryKeyName : string; overload;
    procedure ObjectListName(aValue : string); overload;
    function ObjectListName : string; overload;
    procedure ClassType(aValue : TClass); overload;
    function ClassType : TClass; overload;
    property Bitmap: TBitmap read FBitmap write FBitmap;
    procedure AddBind(aComponentName, aObjectPropertyName : string; aMiddlewares : array of OrionBindingsMiddleware; aBitmap : TBitmap);
    function Binds : TList<TOrionBind>;
    property IsSeparatedOfEntityBindList: boolean read FIsSeparatedOfEntityBindList write FIsSeparatedOfEntityBindList;
    property ObjectList: TObject read FObjectList write FObjectList;
  end;

  TOrionBindingsDataListBinds = class
  strict private
    FListBinds : TObjectList<TOrionBindingsDataListBind>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddDataListBind(aValue : TOrionBindingsDataListBind);
    function Count : integer;
    function Binds : TObjectList<TOrionBindingsDataListBind>;
    function ContainsSeparatedofEntityListBind : boolean;
  end;

  TOrionBindingsList<T:class> = class
  strict private
    FItens : TObjectList<T>;
    FCurrentItem : T;
    FCount : integer;
    FIndex : integer;
  public
    constructor Create;
    destructor destroy; override;

    procedure Add(aValue : T);
    function Count : integer;
    procedure First;
    procedure Next;
    function HasNext : boolean;

    function CurrentItem : T;
  end;

procedure SetMiddlewares(var aBind : TOrionBind; aMiddlewares : array of OrionBindingsMiddleware);

implementation

procedure SetMiddlewares(var aBind : TOrionBind; aMiddlewares : array of OrionBindingsMiddleware);
var
  I : integer;
begin
  SetLength(aBind.Middlewares, Length(aMiddlewares));
  for I := 0 to Pred(Length(aMiddlewares)) do
  begin
    aBind.Middlewares[I] := aMiddlewares[I];
  end;
end;

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
begin
  lOrionBind.&Type := TOrionBindType.Simple;
  lOrionBind.ComponentName := aComponentName;
  lOrionBind.ObjectPropertyName := aObjectPropertyName;
  SetMiddlewares(lOrionBind, aMiddlewares);
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

{ TOrionBindingsDataListBind }

procedure TOrionBindingsDataListBind.AddBind(aComponentName, aObjectPropertyName : string; aMiddlewares : array of OrionBindingsMiddleware; aBitmap : TBitmap);
var
  lOrionBind : TOrionBind;
begin
  lOrionBind.ComponentName := aComponentName;
  lOrionBind.ObjectPropertyName := aObjectPropertyName;
  lOrionBind.Bitmap := aBitmap;
  SetMiddlewares(lOrionBind, aMiddlewares);
  FListBinds.Add(lOrionBind);
end;

procedure TOrionBindingsDataListBind.ComponentName(aValue: string);
begin
  FComponentName := aValue;
end;

function TOrionBindingsDataListBind.Binds: TList<TOrionBind>;
begin
  Result := FListBinds;
end;

function TOrionBindingsDataListBind.ClassType: TClass;
begin
  Result := FClassType;
end;

procedure TOrionBindingsDataListBind.ClassType(aValue: TClass);
begin
  FClassType := aValue;
end;

function TOrionBindingsDataListBind.ComponentName: string;
begin
  Result := FComponentName;
end;

constructor TOrionBindingsDataListBind.Create;
begin
  FListBinds := TList<TOrionBind>.Create;
end;

destructor TOrionBindingsDataListBind.Destroy;
begin
  FListBinds.DisposeOf;
  inherited;
end;

function TOrionBindingsDataListBind.ObjectListName: string;
begin
  Result := FObjectListPropertyName;
end;

function TOrionBindingsDataListBind.PrimaryKeyName: string;
begin
  Result := FPrimaryKeyName;
end;

procedure TOrionBindingsDataListBind.Validate(aDataListBindType : TDataListBindType = TDataListBindType.Entity);
begin
  if FComponentName = '' then
    raise OrionBindingsException.Create('ListBind: ComponentName is null.');

  if FListBinds.Count = 0 then
    raise OrionBindingsException.Create('ListBind: No one bind setted.');

  if aDataListBindType = TDataListBindType.Entity then begin
    if FObjectListPropertyName = '' then
      raise OrionBindingsException.Create('ListBind: ObjectListPropertyName is null.');

    if FPrimaryKeyName = '' then
      raise OrionBindingsException.Create('ListBind: PrimaryKeyName is null.');
  end
  else if aDataListBindType = TDataListBindType.SeparatedOfEntity then begin
    if not Assigned(FObjectList) then
      raise OrionBindingsException.Create('ListBind: ObjectList is null');
  end;
end;

procedure TOrionBindingsDataListBind.PrimaryKeyName(aValue: string);
begin
  FPrimaryKeyName := aValue;
end;

procedure TOrionBindingsDataListBind.ObjectListName(aValue: string);
begin
  FObjectListPropertyName := aValue;
end;

{ TOrionBindingsDataListBinds }

procedure TOrionBindingsDataListBinds.AddDataListBind(aValue: TOrionBindingsDataListBind);
begin
  FListBinds.Add(aValue);
end;

function TOrionBindingsDataListBinds.Binds: TObjectList<TOrionBindingsDataListBind>;
begin
  Result := FListBinds;
end;

function TOrionBindingsDataListBinds.ContainsSeparatedofEntityListBind: boolean;
var
  lListBind: TOrionBindingsDataListBind;
begin
  Result := False;
  for lListBind in FListBinds do begin
    if not lListBind.IsSeparatedOfEntityBindList then
      Continue;

    Result := True;
    Break;
  end;
end;

function TOrionBindingsDataListBinds.Count: integer;
begin
  Result := FListBinds.Count;
end;

constructor TOrionBindingsDataListBinds.Create;
begin
  FListBinds := TObjectList<TOrionBindingsDataListBind>.Create;
end;

destructor TOrionBindingsDataListBinds.Destroy;
begin
  FListBinds.DisposeOf;
  inherited;
end;

{ TOrionBindingsList<T> }

procedure TOrionBindingsList<T>.Add(aValue: T);
begin
  FItens.Add(aValue);
  Inc(FCount);
end;

function TOrionBindingsList<T>.Count: integer;
begin
  Result := FCount;
end;

constructor TOrionBindingsList<T>.Create;
begin
  FItens := TObjectList<T>.Create;
  FCount := 0;
end;

function TOrionBindingsList<T>.CurrentItem: T;
begin

end;

destructor TOrionBindingsList<T>.destroy;
begin
  FItens.DisposeOf;
  inherited;
end;

procedure TOrionBindingsList<T>.First;
begin
  FCurrentItem := FItens.First;
end;

function TOrionBindingsList<T>.HasNext: boolean;
begin
  Result := FIndex < Pred(FCount);
end;

procedure TOrionBindingsList<T>.Next;
begin
  if FIndex = Pred(FCount) then begin
    FCurrentItem := FItens.Last;
    Exit;
  end;

  Inc(FIndex);
  FCurrentItem := FItens.Items[FIndex];
end;

end.
