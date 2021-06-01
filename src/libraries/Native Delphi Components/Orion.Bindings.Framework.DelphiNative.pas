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
    function GetValue(aPropRtti : TRttiProperty; aAttribute : OrionBindingComponent) : Variant;
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

  FView   := aView;
  FEntity := aObject;

  lContext       := TRttiContext.Create;
  lContextObject := TRttiContext.Create;
  try
    lTyp := lContext.GetType(aView.ClassInfo);

    for lField in lTyp.GetFields do
    begin
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
              {$IFDEF VCL}
                if lComponent is TCustomEdit then
                  TCustomEdit(lComponent).Text := GetValue(lProp, OrionBindingComponent(lAttrib))
                else if lComponent is TLabel then
                  TLabel(lComponent).Caption := GetValue(lProp, OrionBindingComponent(lAttrib));
              {$ELSE}
                if lComponent is TCustomEdit then
                  TCustomEdit(lComponent).Text := GetValue(lProp, OrionBindingComponent(lAttrib))
                else if lComponent is TLabel then
                  TLabel(lComponent).Text := GetValue(lProp, OrionBindingComponent(lAttrib))
                else if lComponent is TText then
                  TText(lComponent).Text := GetValue(lProp, OrionBindingComponent(lAttrib));
              {$ENDIF}

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

function TOrionBindingFrameworkDelphiNative.GetValue(aPropRtti : TRttiProperty; aAttribute : OrionBindingComponent) : Variant;
var
  lResult : string;
  lValue : string;
begin
  lResult := '';
  if aAttribute.Prefix.Trim <> '' then
    lResult := aAttribute.Prefix;

  if aAttribute.Format.Trim <> '' then
    lValue := FormatCurr(aAttribute.Format, StrToCurr(aPropRtti.GetValue(Pointer(FEntity)).AsVariant))
  else
    lValue := aPropRtti.GetValue(Pointer(FEntity)).AsVariant;

  lResult := lResult + lValue;

  if aAttribute.Sufix.Trim <> '' then
    lResult := lResult + aAttribute.Sufix;

  Result := lResult;
end;

end.
