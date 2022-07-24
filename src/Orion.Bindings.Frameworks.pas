unit Orion.Bindings.Frameworks;

interface

uses
  System.Generics.Collections,
  Orion.Bindings.Interfaces;

type
  TOrionBindingsFrameworks = class
  private
    FMiddlewares : TList<iOrionLibraryFramework>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddFramework(aFramework : iOrionLibraryFramework);
    function Frameworks : TList<iOrionLibraryFramework>;
  end;

implementation

uses
  Orion.Bindings.Types;

{ TOrionBindingsFrameworks }

procedure TOrionBindingsFrameworks.AddFramework(aFramework: iOrionLibraryFramework);
begin
  if FMiddlewares.Contains(aFramework) then
    raise OrionBindingsException.Create('Error Message');

  FMiddlewares.Add(aFramework);
end;

constructor TOrionBindingsFrameworks.Create;
begin
  FMiddlewares := TList<iOrionLibraryFramework>.Create;
end;

destructor TOrionBindingsFrameworks.Destroy;
begin
  FMiddlewares.DisposeOf;
  inherited;
end;

function TOrionBindingsFrameworks.Frameworks: TList<iOrionLibraryFramework>;
begin
  Result := FMiddlewares;
end;

end.
