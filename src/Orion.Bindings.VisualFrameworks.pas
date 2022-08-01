unit Orion.Bindings.VisualFrameworks;

interface

uses
  System.Generics.Collections,
  Orion.Bindings.Interfaces;

type
  TOrionBindingsVisualFrameworks = class
  private
    FMiddlewares : TList<iOrionVisualFramework>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddFramework(aFramework : iOrionVisualFramework);
    function Frameworks : TList<iOrionVisualFramework>;
  end;

implementation

uses
  Orion.Bindings.Types;

{ TOrionBindingsVisualFrameworks }

procedure TOrionBindingsVisualFrameworks.AddFramework(aFramework: iOrionVisualFramework);
begin
  if FMiddlewares.Contains(aFramework) then
    raise OrionBindingsException.Create('Error Message');

  FMiddlewares.Add(aFramework);
end;

constructor TOrionBindingsVisualFrameworks.Create;
begin
  FMiddlewares := TList<iOrionVisualFramework>.Create;
end;

destructor TOrionBindingsVisualFrameworks.Destroy;
begin
  FMiddlewares.DisposeOf;
  inherited;
end;

function TOrionBindingsVisualFrameworks.Frameworks: TList<iOrionVisualFramework>;
begin
  Result := FMiddlewares;
end;

end.
