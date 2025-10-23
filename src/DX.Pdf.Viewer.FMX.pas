unit DX.Pdf.Viewer.FMX;

{
  FMX PDF Viewer Component
  
  Provides a visual component for displaying PDF documents in FMX applications.
  Supports navigation, zooming, and drag-and-drop.
}

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  FMX.Types,
  FMX.Controls,
  FMX.Graphics,
  FMX.Objects,
  DX.Pdf.API,
  DX.Pdf.Document;

type
  /// <summary>
  /// FMX component for displaying PDF documents
  /// </summary>
  TPdfViewer = class(TControl)
  private
    FDocument: TPdfDocument;
    FCurrentPage: TPdfPage;
    FCurrentPageIndex: Integer;
    FImage: TImage;
    FBackgroundColor: TAlphaColor;
    FOnPageChanged: TNotifyEvent;
    procedure SetCurrentPageIndex(const AValue: Integer);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    function GetPageCount: Integer;
    procedure RenderCurrentPage;
    procedure CreateImage;
  protected
    procedure Resize; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>
    /// Loads a PDF document from a file
    /// </summary>
    procedure LoadFromFile(const AFileName: string; const APassword: string = '');

    /// <summary>
    /// Closes the currently loaded document
    /// </summary>
    procedure Close;

    /// <summary>
    /// Navigates to the next page
    /// </summary>
    procedure NextPage;

    /// <summary>
    /// Navigates to the previous page
    /// </summary>
    procedure PreviousPage;

    /// <summary>
    /// Navigates to the first page
    /// </summary>
    procedure FirstPage;

    /// <summary>
    /// Navigates to the last page
    /// </summary>
    procedure LastPage;

    /// <summary>
    /// Checks if a document is currently loaded
    /// </summary>
    function IsDocumentLoaded: Boolean;

    /// <summary>
    /// Current page index (0-based)
    /// </summary>
    property CurrentPageIndex: Integer read FCurrentPageIndex write SetCurrentPageIndex;

    /// <summary>
    /// Number of pages in the document
    /// </summary>
    property PageCount: Integer read GetPageCount;

    /// <summary>
    /// The PDF document object
    /// </summary>
    property Document: TPdfDocument read FDocument;
  published
    /// <summary>
    /// Background color for the viewer
    /// </summary>
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor default TAlphaColors.White;

    /// <summary>
    /// Event fired when the current page changes
    /// </summary>
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;

    // Inherited published properties
    property Align;
    property Anchors;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property Height;
    property HitTest default True;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TabOrder;
    property TabStop;
    property Visible default True;
    property Width;

    // Events
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnPainting;
    property OnPaint;
    property OnResize;
  end;

implementation

uses
  System.Math;

{ TPdfViewer }

constructor TPdfViewer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDocument := TPdfDocument.Create;
  FCurrentPage := nil;
  FCurrentPageIndex := -1;
  FBackgroundColor := TAlphaColors.White;
  CreateImage;
end;

destructor TPdfViewer.Destroy;
begin
  Close;
  FreeAndNil(FDocument);
  inherited;
end;

procedure TPdfViewer.CreateImage;
begin
  if FImage = nil then
  begin
    FImage := TImage.Create(Self);
    FImage.Parent := Self;
    FImage.Align := TAlignLayout.Client;
    FImage.HitTest := False;
    FImage.WrapMode := TImageWrapMode.Fit;
  end;
end;

procedure TPdfViewer.LoadFromFile(const AFileName: string; const APassword: string = '');
begin
  Close;
  FDocument.LoadFromFile(AFileName, APassword);
  if FDocument.PageCount > 0 then
    SetCurrentPageIndex(0)
  else
    FCurrentPageIndex := -1;
end;

procedure TPdfViewer.Close;
begin
  FreeAndNil(FCurrentPage);
  FCurrentPageIndex := -1;
  FDocument.Close;
  if FImage <> nil then
    FImage.Bitmap.Clear(FBackgroundColor);
  Repaint;
end;

function TPdfViewer.IsDocumentLoaded: Boolean;
begin
  Result := FDocument.IsLoaded;
end;

function TPdfViewer.GetPageCount: Integer;
begin
  if IsDocumentLoaded then
    Result := FDocument.PageCount
  else
    Result := 0;
end;

procedure TPdfViewer.SetCurrentPageIndex(const AValue: Integer);
begin
  if not IsDocumentLoaded then
    Exit;

  if (AValue < 0) or (AValue >= FDocument.PageCount) then
    Exit;

  if FCurrentPageIndex <> AValue then
  begin
    FCurrentPageIndex := AValue;
    RenderCurrentPage;
    if Assigned(FOnPageChanged) then
      FOnPageChanged(Self);
  end;
end;

procedure TPdfViewer.SetBackgroundColor(const AValue: TAlphaColor);
begin
  if FBackgroundColor <> AValue then
  begin
    FBackgroundColor := AValue;
    if IsDocumentLoaded then
      RenderCurrentPage
    else
      Repaint;
  end;
end;

procedure TPdfViewer.RenderCurrentPage;
begin
  if not IsDocumentLoaded then
    Exit;

  if (FCurrentPageIndex < 0) or (FCurrentPageIndex >= FDocument.PageCount) then
    Exit;

  FreeAndNil(FCurrentPage);
  FCurrentPage := FDocument.GetPageByIndex(FCurrentPageIndex);

  if FCurrentPage <> nil then
  begin
    FCurrentPage.RenderToBitmap(FImage.Bitmap, FBackgroundColor);
    Repaint;
  end;
end;

procedure TPdfViewer.NextPage;
begin
  if IsDocumentLoaded and (FCurrentPageIndex < FDocument.PageCount - 1) then
    SetCurrentPageIndex(FCurrentPageIndex + 1);
end;

procedure TPdfViewer.PreviousPage;
begin
  if IsDocumentLoaded and (FCurrentPageIndex > 0) then
    SetCurrentPageIndex(FCurrentPageIndex - 1);
end;

procedure TPdfViewer.FirstPage;
begin
  if IsDocumentLoaded then
    SetCurrentPageIndex(0);
end;

procedure TPdfViewer.LastPage;
begin
  if IsDocumentLoaded and (FDocument.PageCount > 0) then
    SetCurrentPageIndex(FDocument.PageCount - 1);
end;

procedure TPdfViewer.Resize;
begin
  inherited;
  if IsDocumentLoaded and (FCurrentPageIndex >= 0) then
    RenderCurrentPage;
end;

procedure TPdfViewer.Paint;
begin
  inherited;
  if not IsDocumentLoaded then
  begin
    Canvas.Fill.Color := FBackgroundColor;
    Canvas.FillRect(LocalRect, 0, 0, [], 1.0);
  end;
end;

end.

