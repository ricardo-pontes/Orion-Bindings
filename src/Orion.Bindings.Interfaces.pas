unit Orion.Bindings.Interfaces;

interface

uses
  FMX.Forms, System.Classes;

type
  iOrionBindingFramework = interface;

  iOrionBinding = interface
    ['{6C5E7644-4367-488E-A8FB-5796D60A1499}']
    function Use(aFramework : iOrionBindingFramework) : iOrionBinding;
    function Entity(aEntity : TObject) : iOrionBinding;
    function View(aView : TComponent) : iOrionBinding;
    function BindToView : iOrionBinding;
    function BindToEntity : iOrionBinding;
  end;

  iOrionBindingFramework = interface
    ['{01002A37-FF51-4F8A-B146-39E05FD53EAC}']
    function BindToView(aView : TComponent; aObject : TObject) : iOrionBindingFramework;
    function BindToEntity(aView : TComponent; aObject : TObject) : iOrionBindingFramework;
  end;

implementation

end.
