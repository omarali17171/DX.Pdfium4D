program DxPdfViewer;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main.Form in 'Main.Form.pas' {MainForm},
  DX.Pdf.API in 'src\DX.Pdf.API.pas',
  DX.Pdf.Document in 'src\DX.Pdf.Document.pas',
  DX.Pdf.Viewer.FMX in 'src\DX.Pdf.Viewer.FMX.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

