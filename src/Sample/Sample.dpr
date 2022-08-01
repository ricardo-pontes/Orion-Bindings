program Sample;

uses
  System.StartUpCopy,
  FMX.Forms,
  View in 'View.pas' {Form1},
  Customer in 'Customer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
