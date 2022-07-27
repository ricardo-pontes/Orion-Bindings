unit Customer;

interface

uses
  System.Generics.Collections;

type
  TDocument = class;
  TContact = class;

  TCustomer = class
  private
    FID: integer;
    FName: string;
    FLastName: string;
    FSalary: Extended;
    FBirthDate: TDateTime;
    FDocument: TDocument;
    FContacts: TObjectList<TContact>;
  public
    constructor Create;
    destructor Destroy; override;

    property ID: integer read FID write FID;
    property Name: string read FName write FName;
    property LastName: string read FLastName write FLastName;
    property Salary: Extended read FSalary write FSalary;
    property BirthDate: TDateTime read FBirthDate write FBirthDate;
    property Document: TDocument read FDocument write FDocument;
    property Contacts: TObjectList<TContact> read FContacts write FContacts;
  end;

  TDocument = class
  private
    FNumber: string;
  public
    property Number: string read FNumber write FNumber;
  end;

  TContact = class
  private
    FDescription: string;
    FID: integer;

  public
    property ID: integer read FID write FID;
    property Description: string read FDescription write FDescription;
  end;

implementation

uses
  System.SysUtils,
  System.MaskUtils;

{ TCustomer }

constructor TCustomer.Create;
begin
  FDocument := TDocument.Create;
  FContacts := TObjectList<TContact>.Create;
end;

destructor TCustomer.Destroy;
begin
  FDocument.DisposeOf;
  FContacts.DisposeOf;
  inherited;
end;

end.
