unit Orion.Bindings.Framework.FMX.Native;

interface

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Types,
  System.Rtti,
  System.Classes,
  System.SysUtils;

type
  TOrionBindingsMiddlewaresFMXNative = class(TInterfacedObject, iOrionLibraryFramework)
  private

  public
    class function New : iOrionLibraryFramework;
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
  end;

implementation

uses
  FMX.Edit,
  FMX.StdCtrls,
  FMX.NumberBox,
  FMX.ListView,
  FMX.ListView.Types,
  FMX.ListView.Appearances;

var
  FListViewItem : TListViewItem;

{ TOrionBindingsMiddlewaresFMXNative }

class function TOrionBindingsMiddlewaresFMXNative.New: iOrionLibraryFramework;
begin
  Result := Self.Create;
end;

procedure TOrionBindingsMiddlewaresFMXNative.Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
var
  lValue : TValue;
  lListViewItemObject : TListItemDrawable;
begin
  case aCommand of
    TOrionMiddlewareCommand.BindToEntity:
    begin
      if aComponent is TEdit then
        aValue := TEdit(aComponent).Text
      else if aComponent is TLabel then
        aValue := TLabel(aComponent).Text
      else if aComponent is TNumberBox then
        aValue := TNumberBox(aComponent).Value
      else
        raise OrionBindingsException.Create(Format('%s: %s not supported', [OrionBindingsException.ClassName, aComponent.ClassName]));
    end;
    TOrionMiddlewareCommand.BindToView:
    begin
      if aComponent is TEdit then
        TEdit(aComponent).Text := aValue.ToString
      else if aComponent is TLabel then
        TLabel(aComponent).Text := aValue.ToString
      else if aComponent is TNumberBox then
        TNumberBox(aComponent).Text := aValue.AsString
      else
        raise OrionBindingsException.Create(Format('%s: %s not supported', [OrionBindingsException.ClassName, aComponent.ClassName]));
    end;
    TOrionMiddlewareCommand.BindToViewListBindClear:
    begin
      if aComponent is TListView then
        TListView(aComponent).Items.Clear
    end;
    TOrionMiddlewareCommand.BindToViewListBindAddRow:
    begin
      if aComponent is TListView then
        FListViewItem := TListView(aComponent).Items.Add
    end;
    TOrionMiddlewareCommand.BindToEntityListBindNextRow: ;
    TOrionMiddlewareCommand.ListBindUpdateValue:
    begin
      if aComponent is TListView then begin
        lListViewItemObject := FListViewItem.Objects.FindDrawable(TOrionBindSyncList(aValue.AsObject).ComponentName);
        if lListViewItemObject is TListItemText then
          TListItemText(lListViewItemObject).Text := TorionBindSyncList(aValue.AsObject).Value.ToString;
      end;
    end;
  end;
end;

end.
