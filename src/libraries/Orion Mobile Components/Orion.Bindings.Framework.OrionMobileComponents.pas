unit Orion.Bindings.Framework.OrionMobileComponents;

interface

uses
  Orion.Bindings.Interfaces,
  Orion.Bindings.Attributes,
  System.Classes,
  System.Rtti, Components.Edits.ImagesEdit;

type
  TOrionBindingsFrameworkOrionMobileComponents = class(TInterfacedObject, iOrionBindingFramework)
  private
    function GetValue(aPropRtti: TRttiProperty; aAttribute: OrionBindingComponent; aEntity : TObject): Variant;
  public
    constructor Create;
    destructor Destroy; override;
    class function New : iOrionBindingFramework;

    function BindToView(aView : TComponent; aObject : TObject) : iOrionBindingFramework;
    function BindToEntity(aView : TComponent; aObject : TObject) : iOrionBindingFramework;
  end;
implementation

uses
  System.SysUtils,
  Components.Edits.DefaultWithImageAndLabel,
  Components.Edits.Email,
  Components.Edits.LoginEdit,
  Components.Edits.Pesquisa, Components.ComboBoxes.Default,
  {$IFDEF VCL}
  VCL.Forms,
  {$ELSE}
  FMX.Forms,
  {$ENDIF}
  Components.Edits.LoginEditWithLabel;

{ TOrionBindingsFrameworkOrionMobileComponents }

function TOrionBindingsFrameworkOrionMobileComponents.BindToEntity(aView : TComponent; aObject : TObject) : iOrionBindingFramework;
var
  lContext, lContextObject : TRttiContext;
  lTyp, lTypObject : TRttiType;
  lProp : TRttiProperty;
  lField: TRttiField;
  lAttrib: TCustomAttribute;
  lComponent : TComponent;
begin
  Result := Self;
  if not Assigned(aView) then
    raise Exception.Create('No one view to bind');

  if not Assigned(aObject) then
    raise Exception.Create('No one entity to bind');

  lContext       := TRttiContext.Create;
  lContextObject := TRttiContext.Create;
  try
    lTyp := lContext.GetType(aView.ClassInfo);

    for lField in lTyp.GetFields do
    begin
      lComponent := TComponent(aView).FindComponent(lField.Name);
      if lComponent is TFrame then
        BindToEntity(lComponent, aObject);

      for lAttrib in lField.GetAttributes do
      begin
        if lAttrib is OrionBindingComponent then
        begin
          lTypObject := lContextObject.GetType(aObject.ClassInfo);
          for lProp in lTypObject.GetProperties do
          begin
            if lProp.Name = OrionBindingComponent(lAttrib).EntityPropertyName then
            begin
              lComponent := TComponent(aView).FindComponent(lField.Name);

              if lComponent is TComponentsEditsDefaultWithImageAndLabel then
                lProp.SetValue(Pointer(aObject), TValue.From<string>(TComponentsEditsDefaultWithImageAndLabel(lComponent).Text))
              else if lComponent is TComponentsEditsEmail then
                lProp.SetValue(Pointer(aObject), TValue.From<string>(TComponentsEditsEmail(lComponent).Text))
              else if lComponent is TComponentsEditsImagesEdit then
                lProp.SetValue(Pointer(aObject), TValue.From<string>(TComponentsEditsImagesEdit(lComponent).Text))
              else if lComponent is TComponentsEditsLoginEdit then
                lProp.SetValue(Pointer(aObject), TValue.From<string>(TComponentsEditsLoginEdit(lComponent).Text))
              else if lComponent is TComponentsEditsLoginEditWithLabel then
                lProp.SetValue(Pointer(aObject), TValue.From<string>(TComponentsEditsLoginEditWithLabel(lComponent).Text))
              else if lComponent is TComponentsEditsPesquisa then
                lProp.SetValue(Pointer(aObject), TValue.From<string>(TComponentsEditsPesquisa(lComponent).Text))
              else if lComponent is TComponentsComboBoxesDefault then
                lProp.SetValue(Pointer(aObject), TValue.From<integer>(TComponentsComboBoxesDefault(lComponent).Index));

              Break;
            end;
          end;
        end
      end;
    end;
  finally
    lContext.Free;
    lContextObject.Free;
  end;
end;

function TOrionBindingsFrameworkOrionMobileComponents.BindToView(aView: TComponent;
  aObject: TObject): iOrionBindingFramework;
var
  lContext, lContextObject : TRttiContext;
  lTyp, lTypObject : TRttiType;
  lProp : TRttiProperty;
  lField: TRttiField;
  lAttrib: TCustomAttribute;
  lComponent : TComponent;
begin
  Result := Self;
  if not Assigned(aView) then
    raise Exception.Create('No one view to bind');

  if not Assigned(aObject) then
    raise Exception.Create('No one entity to bind');

  lContext       := TRttiContext.Create;
  lContextObject := TRttiContext.Create;
  try
    lTyp := lContext.GetType(aView.ClassInfo);

    for lField in lTyp.GetFields do
    begin
      lComponent := TComponent(aView).FindComponent(lField.Name);
      if lComponent is TFrame then
        BindToView(lComponent, aObject);

      for lAttrib in lField.GetAttributes do
      begin
        if lAttrib is OrionBindingComponent then
        begin
          lTypObject := lContextObject.GetType(aObject.ClassInfo);
          for lProp in lTypObject.GetProperties do
          begin
            if lProp.Name = OrionBindingComponent(lAttrib).EntityPropertyName then
            begin
              lComponent := TComponent(aView).FindComponent(lField.Name);
                if lComponent is TComponentsEditsDefaultWithImageAndLabel then
                  TComponentsEditsDefaultWithImageAndLabel(lComponent).Text(GetValue(lProp, OrionBindingComponent(lAttrib), aObject))
                else if lComponent is TComponentsEditsEmail then
                  TComponentsEditsEmail(lComponent).Text(GetValue(lProp, OrionBindingComponent(lAttrib), aObject))
                else if lComponent is TComponentsEditsImagesEdit then
                  TComponentsEditsImagesEdit(lComponent).Text(GetValue(lProp, OrionBindingComponent(lAttrib), aObject))
                else if lComponent is TComponentsEditsLoginEdit then
                  TComponentsEditsLoginEdit(lComponent).Text(GetValue(lProp, OrionBindingComponent(lAttrib), aObject))
                else if lComponent is TComponentsEditsPesquisa then
                  TComponentsEditsPesquisa(lComponent).Text(GetValue(lProp, OrionBindingComponent(lAttrib), aObject))
                else if lComponent is TComponentsComboBoxesDefault then
                  TComponentsComboBoxesDefault(lComponent).Index(GetValue(lProp, OrionBindingComponent(lAttrib), aObject));

              Break;
            end;
          end;
        end
        else if lAttrib is OrionBindingComboBox then
        begin
          lTypObject := lContextObject.GetType(aObject.ClassInfo);
          for lProp in lTypObject.GetProperties do
          begin
            if lProp.Name = OrionBindingComboBox(lAttrib).EntityPropertyKeyName then
            begin
              lComponent := TComponent(aView).FindComponent(lField.Name);

            end;
          end;
        end;
      end;
    end;
  finally
    lContext.Free;
    lContextObject.Free;
  end;
end;

constructor TOrionBindingsFrameworkOrionMobileComponents.Create;
begin

end;

destructor TOrionBindingsFrameworkOrionMobileComponents.Destroy;
begin

  inherited;
end;

function TOrionBindingsFrameworkOrionMobileComponents.GetValue(aPropRtti: TRttiProperty;
  aAttribute: OrionBindingComponent; aEntity : TObject): Variant;
var
  lResult : string;
  lValue : string;
begin
  lResult := '';
  if aAttribute.Prefix.Trim <> '' then
    lResult := aAttribute.Prefix;

  if aAttribute.Format.Trim <> '' then
    lValue := FormatCurr(aAttribute.Format, StrToCurr(aPropRtti.GetValue(Pointer(aEntity)).AsVariant))
  else
    lValue := aPropRtti.GetValue(Pointer(aEntity)).AsVariant;

  lResult := lResult + lValue;

  if aAttribute.Sufix.Trim <> '' then
    lResult := lResult + aAttribute.Sufix;

  Result := lResult;
end;

class function TOrionBindingsFrameworkOrionMobileComponents.New: iOrionBindingFramework;
begin
  Result := Self.Create;
end;

end.
