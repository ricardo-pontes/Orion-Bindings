unit View.SeparatedBindList;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.Generics.Collections,
  Customer,
  Orion.Bindings.Interfaces,
  Orion.Bindings,
  Orion.Bindings.VisualFrameworks.FMX.Native, FMX.Edit;

type
  TViewSeparatedBindList = class(TForm)
    Button1: TButton;
    ListView1: TListView;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private

    FContacts : TObjectList<TContact>;
    FBinds : iOrionBindings;
  public
    { Public declarations }
  end;

var
  ViewSeparatedBindList: TViewSeparatedBindList;

implementation

{$R *.fmx}

procedure TViewSeparatedBindList.Button1Click(Sender: TObject);
begin
  FBinds.BindToView;
end;

procedure TViewSeparatedBindList.Button2Click(Sender: TObject);
var
  lContact : TContact;
begin
  lContact := TContact.Create;
  lContact.ID := Edit1.Text.ToInteger;
  lContact.Description := Edit2.Text;
  FContacts.Add(lContact);
end;

procedure TViewSeparatedBindList.FormCreate(Sender: TObject);
var
  lContact : TContact;
begin
  FContacts := TObjectList<TContact>.Create;
  FBinds := TOrionBindings.New;

  lContact := TContact.Create;
  lContact.ID := 1;
  lContact.Description := 'Ricardo Pontes da Cunha';
  FContacts.Add(lContact);

  lContact := TContact.Create;
  lContact.ID := 2;
  lContact.Description := 'Gigiva';
  FContacts.Add(lContact);

  lContact := TContact.Create;
  lContact.ID := 3;
  lContact.Description := 'Dodô';
  FContacts.Add(lContact);

  FBinds.Use(TOrionBindingsVisualFrameworkFMXNative.New);
  FBinds.View(Self);

  FBinds.ListBinds.Init(True);
  FBinds.ListBinds.ComponentName(ListView1.Name);
  FBinds.ListBinds.ObjectList(FContacts);
  FBinds.ListBinds.AddListBind('ID', 'ID');
  FBinds.ListBinds.AddListBind('Description', 'Description');
  FBinds.ListBinds.Finish;
end;

procedure TViewSeparatedBindList.FormDestroy(Sender: TObject);
begin
  FContacts.DisposeOf;
end;

end.
