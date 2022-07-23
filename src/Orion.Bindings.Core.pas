unit Orion.Bindings.Core;

interface

uses
  Orion.Bindings.Container,
  Orion.Bindings.Data,
  Orion.Bindings.Middlewares;

type
  TOrionBindingsCore = class
  private
    FContainer : TOrionBindingsContainer;
    FData : TOrionBindingsData;
    FMiddlewares : TOrionBindingsMiddlewares;
  public
    constructor Create(aContainer : TOrionBindingsContainer; aData : TOrionBindingsData; aMiddlewares : TorionBindingsMiddlewares);
    destructor Destroy; override;
    procedure BindToView;
    procedure BindToEntity;
  end;

implementation

{ TOrionBindingsCore }

procedure TOrionBindingsCore.BindToEntity;
begin

end;

procedure TOrionBindingsCore.BindToView;
begin

end;

constructor TOrionBindingsCore.Create(aContainer: TOrionBindingsContainer; aData: TOrionBindingsData;
  aMiddlewares: TorionBindingsMiddlewares);
begin
  FContainer   := aContainer;
  FData        := aData;
  FMiddlewares := aMiddlewares;
end;

destructor TOrionBindingsCore.Destroy;
begin

  inherited;
end;

end.
