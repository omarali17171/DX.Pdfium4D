unit Main.Form;

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
  FMX.Objects,
  FMX.StdCtrls,
  System.IOUtils,
  DX.Pdf.Viewer.FMX,
  DX.Pdf.Document;

type
  TMainForm = class(TForm)
    DropPanel: TPanel;
    DropLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPdfViewer: TPdfViewer;
    FCurrentPdfPath: string;
    procedure HideDropPanel;
    procedure ShowDropPanel;
    procedure CreatePdfViewer;
  protected
    procedure LoadPdfFile(const AFilePath: string);
    procedure ProcessCommandLineParams;
  public
    procedure DragOver(const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation); override;
    procedure DragDrop(const Data: TDragObject; const Point: TPointF); override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'DX PDF-Viewer 1.0';
  FCurrentPdfPath := '';

  // Create PDF viewer dynamically
  CreatePdfViewer;

  // Show drop panel initially
  ShowDropPanel;

  // Process command line parameters
  ProcessCommandLineParams;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FPdfViewer);
end;

procedure TMainForm.CreatePdfViewer;
begin
  FPdfViewer := TPdfViewer.Create(Self);
  FPdfViewer.Parent := Self;
  FPdfViewer.Align := TAlignLayout.Client;
  FPdfViewer.BackgroundColor := TAlphaColors.White;
  FPdfViewer.SendToBack; // Send behind DropPanel
end;

procedure TMainForm.HideDropPanel;
begin
  DropPanel.Visible := False;
  DropPanel.HitTest := False;
end;

procedure TMainForm.ShowDropPanel;
begin
  DropPanel.Visible := True;
  DropPanel.HitTest := False;  // Let drag events pass through to form
  DropPanel.BringToFront;
end;

procedure TMainForm.ProcessCommandLineParams;
var
  LFilePath: string;
begin
  // Check if a parameter was passed
  if ParamCount > 0 then
  begin
    LFilePath := ParamStr(1);

    // Check if the file exists and is a PDF
    if TFile.Exists(LFilePath) and
       (LowerCase(TPath.GetExtension(LFilePath)) = '.pdf') then
    begin
      LoadPdfFile(LFilePath);
    end;
  end;
end;

procedure TMainForm.LoadPdfFile(const AFilePath: string);
begin
  if not TFile.Exists(AFilePath) then
  begin
    ShowMessage('File not found: ' + AFilePath);
    Exit;
  end;

  try
    // Load PDF in viewer
    FPdfViewer.LoadFromFile(AFilePath);

    FCurrentPdfPath := AFilePath;

    // Hide drop panel when PDF is loaded
    HideDropPanel;

    // Update window title
    Caption := 'DX PDF-Viewer 1.0 - ' + TPath.GetFileName(AFilePath);
  except
    on E: EPdfException do
    begin
      ShowMessage('Error loading PDF: ' + E.Message);
      ShowDropPanel;
    end;
  end;
end;

procedure TMainForm.DragOver(const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  // Check if we have files and if it's a PDF file
  if (Length(Data.Files) > 0) and
     (LowerCase(TPath.GetExtension(Data.Files[0])) = '.pdf') then
  begin
    Operation := TDragOperation.Copy;
  end
  else
  begin
    Operation := TDragOperation.None;
  end;
end;

procedure TMainForm.DragDrop(const Data: TDragObject; const Point: TPointF);
begin
  // Check if we have files
  if Length(Data.Files) > 0 then
  begin
    // Check if it's a PDF file
    if LowerCase(TPath.GetExtension(Data.Files[0])) = '.pdf' then
    begin
      LoadPdfFile(Data.Files[0]);
    end
    else
    begin
      ShowMessage('Please drop PDF files only.');
    end;
  end;
end;

end.

