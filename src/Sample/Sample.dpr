program Sample;

uses
  System.StartUpCopy,
  FMX.Forms,
  View in 'View.pas' {Form1},
  Customer in 'Customer.pas',
  View.SeparatedBindList in 'View.SeparatedBindList.pas' {ViewSeparatedBindList};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TViewSeparatedBindList, ViewSeparatedBindList);
  Application.Run;
end.
