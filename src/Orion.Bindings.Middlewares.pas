unit Orion.Bindings.Middlewares;

interface

uses
  System.Generics.Collections,
  Orion.Bindings.Interfaces;

type
  TOrionBindingsMiddlewares = class
  private
    FMiddlewares : TList<iOrionMiddleware>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddMiddleware(aMiddleware : iOrionMiddleware);
    function Middlewares : TList<iOrionMiddleware>;
  end;

implementation

uses
  Orion.Bindings.Types;

{ TOrionBindingsMiddlewares }

procedure TOrionBindingsMiddlewares.AddMiddleware(aMiddleware: iOrionMiddleware);
begin
  if FMiddlewares.Contains(aMiddleware) then
    raise OrionBindingsException.Create('Error Message');

  FMiddlewares.Add(aMiddleware);
end;

constructor TOrionBindingsMiddlewares.Create;
begin
  FMiddlewares := TList<iOrionMiddleware>.Create;
end;

destructor TOrionBindingsMiddlewares.Destroy;
begin
  FMiddlewares.DisposeOf;
  inherited;
end;

function TOrionBindingsMiddlewares.Middlewares: TList<iOrionMiddleware>;
begin
  Result := FMiddlewares;
end;

end.
