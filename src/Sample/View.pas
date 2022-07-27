unit View;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.Edit,
  Customer,
  FMX.StdCtrls,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  Rest.Json,
  System.JSON,
  System.JSON.Writers,
  Orion.Bindings.Interfaces,
  Orion.Bindings,
  Orion.Bindings.Framework.FMX.Native,
  Orion.Bindings.Middleware.CPF,
  Orion.Bindings.Middleware.CNPJ,
  Orion.Bindings.Middleware.FormatCurrency, FMX.EditBox, FMX.NumberBox, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView;

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FCustomer : TCustomer;
    FBinds : iOrionBindings;
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
begin
  FBinds.BindToEntity;

  Memo1.Lines.AddPair('ID', FCustomer.ID.ToString);
  Memo1.Lines.AddPair('Name', FCustomer.Name);
  Memo1.Lines.AddPair('LastName', FCustomer.LastName);
  Memo1.Lines.AddPair('Salary', FCustomer.Salary.ToString);
  Memo1.Lines.AddPair('Birthdate', DateToStr(FCustomer.BirthDate));
  Memo1.Lines.AddPair('Document.Number', FCustomer.Document.Number);
  Memo1.Lines.Add('--------------------------------');
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  lContact : TContact;
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

//  FBinds.ListBinds.Init;
//  FBinds.ListBinds.ComponentName('ListView1');
//  FBinds.ListBinds.ObjectListPropertyName('Contacts');
//  FBinds.ListBinds.AddListBind('ID', 'ID');
//  FBinds.ListBinds.AddListBind('Description', 'Description');
//  FBinds.ListBinds.Finish;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FCustomer.DisposeOf;
end;

end.
