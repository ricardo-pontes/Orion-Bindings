unit Orion.Bindings.VisualFrameworks.FMX.Native;

interface

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Types,
  System.Rtti,
  System.Classes,
  System.SysUtils;

type
  TOrionBindingsMiddlewaresFMXNative = class(TInterfacedObject, iOrionVisualFramework)
  private

  public
    class function New : iOrionVisualFramework;
    procedure Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
  end;

implementation

uses
  FMX.Edit,
  FMX.StdCtrls,
  FMX.NumberBox,
  FMX.ListView,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.Graphics,
  FMX.Objects;

var
  FListViewItem : TListViewItem;

{ TOrionBindingsMiddlewaresFMXNative }

class function TOrionBindingsMiddlewaresFMXNative.New: iOrionVisualFramework;
begin
  Result := Self.Create;
end;

procedure TOrionBindingsMiddlewaresFMXNative.Synchronize(aCommand : TOrionMiddlewareCommand; aComponent : TComponent; var aValue : TValue);
var
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
      else if aComponent is TSwitch then
        aValue := TSwitch(aComponent).IsChecked
      else if aComponent is TText then
        aValue := TText(aComponent).Text
      else if aComponent is TCheckBox then
        aValue := TCheckBox(aComponent).IsChecked
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
        TNumberBox(aComponent).Text := aValue.ToString
      else if aComponent is TSwitch then
        TSwitch(aComponent).IsChecked := aValue.AsBoolean
      else if aComponent is TText then
        TText(aComponent).Text := aValue.ToString
      else if aComponent is TCheckBox then
        TCheckBox(aComponent).IsChecked := aValue.AsBoolean
      else
        raise OrionBindingsException.Create(Format('%s: %s not supported', [OrionBindingsException.ClassName, aComponent.ClassName]));
    end;
    TOrionMiddlewareCommand.BindToViewListBindClear:
    begin
      if aComponent is TListView then
        TListView(aComponent).Items.Clear
    end;
    TOrionMiddlewareCommand.BindToEntityGetListCount :
    begin
      aValue := TListView(aComponent).Items.Count;
    end;
    TOrionMiddlewareCommand.BindToViewListBindAddRow:
    begin
      if aComponent is TListView then begin
        FListViewItem := TListView(aComponent).Items.Add;
      end;
    end;
    TOrionMiddlewareCommand.BindToEntityListBindNextRow: ;
    TOrionMiddlewareCommand.ListBindUpdateValue:
    begin
      if aComponent is TListView then begin
        FListViewItem := TListView(aComponent).Items.Item[TOrionBindSyncList(aValue.AsObject).Index] as TListViewItem;
        lListViewItemObject := FListViewItem.Objects.FindDrawable(TOrionBindSyncList(aValue.AsObject).ComponentName);
        if lListViewItemObject is TListItemText then
          TListItemText(lListViewItemObject).Text := TorionBindSyncList(aValue.AsObject).Value.ToString
        else if lListViewItemObject is TListItemImage then
          TListItemImage(lListViewItemObject).Bitmap := TBitmap(TorionBindSyncList(aValue.AsObject).Value.AsObject);
      end;
    end;
    TOrionMiddlewareCommand.ListBindGetValue : begin
      lListViewItemObject := TListView(aComponent).Items.AppearanceItem[TOrionBindSyncList(aValue.AsObject).Index].Objects.FindDrawable(TOrionBindSyncList(aValue.AsObject).ComponentName);
      if lListViewItemObject is TListItemText then
        TOrionBindSyncList(aValue.AsObject).Value := TListItemText(lListViewItemObject).Text;
    end;
  end;
end;

end.
