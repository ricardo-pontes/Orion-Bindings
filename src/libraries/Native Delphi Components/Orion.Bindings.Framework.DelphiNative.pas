unit Orion.Bindings.Framework.DelphiNative;

interface

uses
  System.Rtti,
  Orion.Bindings.Interfaces,
  Orion.Bindings.Attributes,

  FMX.Forms,

  System.Classes;

type
  TOrionBindingFrameworkDelphiNative = class(TInterfacedObject, iOrionBindingFramework)
  private
    FView : TComponent;
    FEntity : TObject;
    function GetValue(aPropRtti: TRttiProperty; aEntity : TObject; aPrefix, aSufix : string): Variant;
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
  System.StrUtils,
  System.TypInfo
  {$IFDEF VCL}
   Vcl.Edit,
   Vcl.StdCtrls;
  {$ELSE}
  ,FMX.Edit,
  FMX.StdCtrls,
  FMX.Objects;
  {$ENDIF}

{ TOrionBindingFrameworkDelphiNative }

function TOrionBindingFrameworkDelphiNative.BindToEntity(aView : TComponent; aObject : TObject) : iOrionBindingFramework;
begin

end;

function TOrionBindingFrameworkDelphiNative.BindToView(aView : TComponent; aObject : TObject) : iOrionBindingFramework;
var
  lContext, lContextObject, lContextComponent : TRttiContext;
  lTyp, lTypObject, lTypComponent : TRttiType;
  lProp : TRttiProperty;
  lField: TRttiField;
  lAttrib: TCustomAttribute;
  lComponent : TComponent;
  lPrefix, lSufix : string;
  lChangePropertyProp : string;
  lChangePropertyValue : TValue;
  lPropComponent: TRttiProperty;
  lAssert : boolean;
begin
  Result := Self;
  if not Assigned(aView) then
    raise Exception.Create('No one view to bind');

  if not Assigned(aObject) then
    raise Exception.Create('No one entity to bind');

  FView   := aView;
  FEntity := aObject;

  lContext       := TRttiContext.Create;
  lContextObject := TRttiContext.Create;
  try
    lTyp := lContext.GetType(aView.ClassInfo);

    for lField in lTyp.GetFields do
    begin
      if lComponent is TFrame then
        BindToView(lComponent, aObject);

      lAssert := False;
      for lAttrib in lField.GetAttributes do
      begin
        if lAttrib is OrionBindingComponent then
          lTypObject := lContextObject.GetType(aObject.ClassInfo)
        else if lAttrib is Prefix then
          lPrefix := Prefix(lAttrib).Value
        else if lAttrib is Sufix then
          lSufix := Sufix(lAttrib).Value
        else if lAttrib is OrionBindsChangeProperty then
        begin
          lTypComponent  := lContextComponent.GetType(lField.ClassInfo);
          lPropComponent := lTypComponent.GetProperty(OrionBindsChangeProperty(lAttrib).Prop);
          lPropComponent.SetValue(lField.ClassInfo, OrionBindsChangeProperty(lAttrib).Value);
        end
        else if lAttrib is OrionBindAssertProperty then
        begin
          lAssert := true;
        end;
      end;

      for lProp in lTypObject.GetProperties do
      begin
        if lProp.Name = OrionBindingComponent(lAttrib).EntityPropertyName then
        begin
          lComponent := TComponent(aView).FindComponent(lField.Name);
          {$IFDEF VCL}
            if lComponent is TCustomEdit then
              TCustomEdit(lComponent).Text := GetValue(lProp, aObject, lPrefix, lSufix)
            else if lComponent is TLabel then
              TLabel(lComponent).Caption := GetValue(lProp, aObject, lPrefix, lSufix);
          {$ELSE}
            if lComponent is TCustomEdit then
              TCustomEdit(lComponent).Text := GetValue(lProp, aObject, lPrefix, lSufix)
            else if lComponent is TLabel then
              TLabel(lComponent).Text := GetValue(lProp, aObject, lPrefix, lSufix)
            else if lComponent is TText then
              TText(lComponent).Text := GetValue(lProp, aObject, lPrefix, lSufix);
          {$ENDIF}

          Break;
        end;
      end;

      if lAssert then
      begin
        lTypComponent  := lContextComponent.GetType(lField.ClassInfo);
        lPropComponent := lTypComponent.GetProperty(OrionBindAssertProperty(lAttrib).PropertyName);
        if OrionBindAssertProperty(lAttrib).Condition.Contains('=') then
        begin
          if lProp.PropertyType.TypeKind = tkString then
          begin
            if lPropComponent.GetValue(Pointer(lField.ClassInfo)).AsString = SplitString(OrionBindAssertProperty(lAttrib).Condition, '=')[1] then
              lPropComponent.SetValue(Pointer(lField.ClassInfo), OrionBindAssertProperty(lAttrib).TrueValue)
            else
              lPropComponent.SetValue(Pointer(lField.ClassInfo), OrionBindAssertProperty(lAttrib).FalseValue)
          end;
        end;
      end;
    end;
  finally
    lContext.Free;
    lContextObject.Free;
  end;
end;

constructor TOrionBindingFrameworkDelphiNative.Create;
begin

end;

destructor TOrionBindingFrameworkDelphiNative.Destroy;
begin

  inherited;
end;

class function TOrionBindingFrameworkDelphiNative.New: iOrionBindingFramework;
begin
  Result := Self.Create;
end;

function TOrionBindingFrameworkDelphiNative.GetValue(aPropRtti: TRttiProperty; aEntity : TObject; aPrefix, aSufix : string): Variant;
var
  lResult : string;
  lValue : string;
begin
  lResult := '';
  if aPrefix.Trim <> '' then
    lResult := aPrefix;

//  if aAttribute.Format.Trim <> '' then
//    lValue := FormatCurr(aAttribute.Format, StrToCurr(aPropRtti.GetValue(Pointer(aEntity)).AsVariant))
//  else
    lValue := aPropRtti.GetValue(Pointer(aEntity)).AsVariant;

  lResult := lResult + lValue;

  if aSufix.Trim <> '' then
    lResult := lResult + aSufix;

  Result := lResult;
end;

end.
