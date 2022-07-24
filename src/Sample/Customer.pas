unit Customer;

interface

type
  TDocument = class;

  TCustomer = class
  private
    FID: integer;
    FName: string;
    FLastName: string;
    FSalary: Extended;
    FBirthDate: TDateTime;
    FDocument: TDocument;
  public
    constructor Create;
    destructor Destroy; override;

    property ID: integer read FID write FID;
    property Name: string read FName write FName;
    property LastName: string read FLastName write FLastName;
    property Salary: Extended read FSalary write FSalary;
    property BirthDate: TDateTime read FBirthDate write FBirthDate;
    property Document: TDocument read FDocument write FDocument;
  end;

  TDocument = class
  private
    FNumber: string;
  public
    property Number: string read FNumber write FNumber;
  end;

implementation

uses
  System.SysUtils,
  System.MaskUtils;

{ TCustomer }

constructor TCustomer.Create;
begin
  FDocument := TDocument.Create;
end;

destructor TCustomer.Destroy;
begin
  FDocument.DisposeOf;
  inherited;
end;

end.
