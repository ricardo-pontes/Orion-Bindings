unit View;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,
  System.JSON.Writers,
  Rest.Json,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.StdCtrls,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.EditBox,
  FMX.NumberBox,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.Layouts,

  Customer,
  Orion.Bindings.Interfaces,
  Orion.Bindings,
  Orion.Bindings.VisualFrameworks.FMX.Native,
  Orion.Bindings.Middleware.CPF,
  Orion.Bindings.Middleware.CNPJ,
  Orion.Bindings.Middleware.FormatCurrency,
  Orion.Bindings.Middleware.ZeroIfEmptyStr;

type
  TForm1 = class(TForm)
    EditID: TEdit;
    EditName: TEdit;
    EditLastName: TEdit;
    EditSalary: TEdit;
    EditBirthDate: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    ListView1: TListView;
    GroupBox1: TGroupBox;
    EditCPFCNPJ: TEdit;
    Layout1: TLayout;
    EditContactID: TEdit;
    EditContactDescription: TEdit;
    Button3: TButton;
    Layout2: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
      const ItemObject: TListItemDrawable);
  private
    FCustomer : TCustomer;
    FBinds : iOrionBindings;
    procedure CreateCustomer;
    procedure ConfigOrionBindings;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  FBinds.BindToView;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  lContact: TContact;
begin
  FBinds.BindToEntity;

  Memo1.Lines.AddPair('ID', FCustomer.ID.ToString);
  Memo1.Lines.AddPair('Name', FCustomer.Name);
  Memo1.Lines.AddPair('LastName', FCustomer.LastName);
  Memo1.Lines.AddPair('Salary', FCustomer.Salary.ToString);
  Memo1.Lines.AddPair('Birthdate', DateToStr(FCustomer.BirthDate));
  Memo1.Lines.AddPair('Document.Number', FCustomer.Document.Number);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Contacts');
  for lContact in FCustomer.Contacts do begin
    Memo1.Lines.Add(Format('ID=%d | Description=%s', [lContact.ID, lContact.Description]));
  end;
  Memo1.Lines.Add('--------------------------------');

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  lListItem : TListViewItem;
begin
  lListItem := ListView1.Items.Add;
  TListItemText(lListItem.Objects.FindDrawable('ID')).Text := EditContactID.Text;
  TListItemText(lListItem.Objects.FindDrawable('Description')).Text := EditContactDescription.Text;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CreateCustomer;
  ConfigOrionBindings;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FCustomer.DisposeOf;
end;

procedure TForm1.ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
begin
  if not Assigned(ItemObject) then
    Exit;
  if ItemObject.Name = 'Delete' then begin
    TListView(Sender).Items.Delete(iTemIndex);
  end;

end;

procedure TForm1.CreateCustomer;
var
  lContact: TContact;
begin
  FCustomer := TCustomer.Create;
  FCustomer.ID := 1;
  FCustomer.Name := 'Ricardo';
  FCustomer.LastName := 'Pontes da Cunha';
  FCustomer.Salary := 5000.57;
  FCustomer.BirthDate := StrToDate('24/06/1987');
  FCustomer.Document.Number := '11111111111';

  lContact := TContact.Create;
  lContact.ID := 1;
  lContact.Description := 'Test';
  FCustomer.Contacts.Add(lContact);

  lContact := TContact.Create;
  lContact.ID := 2;
  lContact.Description := 'Test 2';
  FCustomer.Contacts.Add(lContact);
end;

procedure TForm1.ConfigOrionBindings;
begin
  FBinds := TOrionBindings.New;
  FBinds.Use(TOrionBindingsMiddlewaresFMXNative.New);
  FBinds.View(Self);
  FBinds.Entity(FCustomer);
  FBinds.AddBind('EditID', 'ID');
  FBinds.AddBind('EditName', 'Name');
  FBinds.AddBind('EditLastName', 'LastName');
  FBinds.AddBind('EditSalary', 'Salary', [FormatCurrency]);
  FBinds.AddBind('EditBirthDate', 'BirthDate');
  FBinds.AddBind('EditCPFCNPJ', 'Document.Number', [CPF, CNPJ]);

  FBinds.ListBinds.Init;
  FBinds.ListBinds.ComponentName('ListView1');
  FBinds.ListBinds.ObjectListPropertyName('Contacts');
  FBinds.ListBinds.ClassType(TContact);
  FBinds.ListBinds.Primarykey('ID');
  FBinds.ListBinds.AddListBind('ID', 'ID');
  FBinds.ListBinds.AddListBind('Description', 'Description');
  FBinds.ListBinds.Finish;
end;

end.
