# 🏗️ DX PDF-Viewer Architecture

> Clean, testable, and maintainable 3-layer architecture

---

## 📐 Overview

The DX PDF-Viewer follows a **layered architecture** pattern, separating concerns into three distinct layers:

```
┌─────────────────────────────────────────┐
│   Layer 3: FMX Viewer Component         │
│   (DX.Pdf.Viewer.FMX.pas)               │
│   - Visual component                    │
│   - User interaction                    │
│   - Drag & Drop support                 │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│   Layer 2: Document Wrapper             │
│   (DX.Pdf.Document.pas)                 │
│   - Object-oriented API                 │
│   - Resource management                 │
│   - Exception handling                  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│   Layer 1: PDFium API Bindings          │
│   (DX.Pdf.API.pas)                      │
│   - C-API declarations                  │
│   - Platform-independent                │
│   - Direct DLL imports                  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│   PDFium Library (pdfium.dll)           │
│   - Google's PDF rendering engine       │
│   - Cross-platform binaries             │
└─────────────────────────────────────────┘
```

---

## 📦 Layer 1: PDFium API (`DX.Pdf.API.pas`)

### Purpose
Provides **low-level bindings** to the PDFium C library.

### Responsibilities
- Declare PDFium C functions and types
- Handle platform-specific library names
- Provide helper functions for type conversions

### Key Features
- ✅ **Platform-independent**: Supports Windows, macOS, Linux, iOS, Android
- ✅ **Type-safe**: Uses Delphi type system for C types
- ✅ **Minimal**: Only essential PDFium functions exposed

### Example Usage
```pascal
uses DX.Pdf.API;

var
  LDoc: FPDF_DOCUMENT;
begin
  FPDF_InitLibrary;
  try
    LDoc := FPDF_LoadDocument('test.pdf', nil);
    if LDoc <> nil then
    begin
      ShowMessage('Page count: ' + IntToStr(FPDF_GetPageCount(LDoc)));
      FPDF_CloseDocument(LDoc);
    end;
  finally
    FPDF_DestroyLibrary;
  end;
end;
```

### Platform-Specific Library Names
```pascal
{$IFDEF MSWINDOWS}
  const PDFIUM_DLL = 'pdfium.dll';
{$ENDIF}
{$IFDEF MACOS}
  const PDFIUM_DLL = 'libpdfium.dylib';
{$ENDIF}
{$IFDEF LINUX}
  const PDFIUM_DLL = 'libpdfium.so';
{$ENDIF}
```

---

## 📚 Layer 2: Document Wrapper (`DX.Pdf.Document.pas`)

### Purpose
Provides an **object-oriented wrapper** around the PDFium API with automatic resource management.

### Responsibilities
- Manage PDFium library initialization/finalization
- Provide high-level classes for documents and pages
- Handle resource cleanup automatically
- Provide meaningful exception messages

### Key Classes

#### `TPdfLibrary` (Singleton)
- Manages PDFium library lifecycle
- Reference counting for multiple instances
- Thread-safe initialization

#### `TPdfDocument`
- Represents a PDF document
- Loads from file or stream
- Provides page access
- Automatic cleanup on destruction

#### `TPdfPage`
- Represents a single PDF page
- Provides page dimensions and rotation
- Renders page to FMX bitmap
- Automatic cleanup on destruction

### Example Usage
```pascal
uses DX.Pdf.Document;

var
  LDoc: TPdfDocument;
  LPage: TPdfPage;
  LBitmap: TBitmap;
begin
  LDoc := TPdfDocument.Create;
  try
    LDoc.LoadFromFile('test.pdf');
    ShowMessage('Pages: ' + IntToStr(LDoc.PageCount));
    
    LPage := LDoc.GetPageByIndex(0);
    try
      LBitmap := TBitmap.Create;
      try
        LPage.RenderToBitmap(LBitmap);
        Image1.Bitmap.Assign(LBitmap);
      finally
        LBitmap.Free;
      end;
    finally
      LPage.Free;
    end;
  finally
    LDoc.Free;
  end;
end;
```

### Exception Hierarchy
```
EPdfException
├── EPdfLoadException    (file not found, invalid format, etc.)
├── EPdfPageException    (invalid page index, etc.)
└── EPdfRenderException  (rendering errors)
```

---

## 🖼️ Layer 3: FMX Viewer (`DX.Pdf.Viewer.FMX.pas`)

### Purpose
Provides a **visual FMX component** for displaying PDF documents in applications.

### Responsibilities
- Display PDF pages in FMX applications
- Handle user interactions (navigation, resize)
- Support drag & drop of PDF files
- Provide events for page changes

### Key Features
- ✅ **FMX Integration**: Inherits from `TControl`
- ✅ **Automatic Rendering**: Re-renders on resize
- ✅ **Page Navigation**: Next, Previous, First, Last
- ✅ **Drag & Drop**: Works correctly (unlike TWebBrowser!)
- ✅ **Customizable**: Background color, events

### Example Usage
```pascal
// Create viewer dynamically (no component installation required)
type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    FPdfViewer: TPdfViewer;
  end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Create viewer dynamically
  FPdfViewer := TPdfViewer.Create(Self);
  FPdfViewer.Parent := Self;
  FPdfViewer.Align := TAlignLayout.Client;
  FPdfViewer.BackgroundColor := TAlphaColors.White;

  // Load PDF
  FPdfViewer.LoadFromFile('document.pdf');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  FPdfViewer.NextPage;
end;
```

> **Note:** The viewer is created dynamically in code, so **no component installation** is required!

### Properties
- `CurrentPageIndex: Integer` - Current page (0-based)
- `PageCount: Integer` - Total number of pages
- `BackgroundColor: TAlphaColor` - Background color
- `Document: TPdfDocument` - Access to underlying document

### Methods
- `LoadFromFile(FileName, Password)` - Load PDF from file
- `Close` - Close current document
- `NextPage`, `PreviousPage` - Navigate pages
- `FirstPage`, `LastPage` - Jump to first/last page

### Events
- `OnPageChanged: TNotifyEvent` - Fired when page changes

---

## ✅ Testing Strategy

### Unit Tests (`DX.Pdf.Document.Tests.pas`)
Tests for Layer 2 (Document Wrapper):

- ✅ Library initialization
- ✅ Document creation and loading
- ✅ Error handling (invalid files, etc.)
- ✅ Page access and dimensions
- ✅ Multiple document instances
- ✅ Resource cleanup

### Test Execution
```bash
# Compile and run tests
cd tests
dcc32 DxPdfViewerTests.dpr
DxPdfViewerTests.exe
```

---

## 🌍 Cross-Platform Support

### Current Status
- ✅ **Windows (Win32/Win64)**: Fully supported and tested
- 🔄 **macOS**: Architecture ready, needs testing
- 🔄 **Linux**: Architecture ready, needs testing
- 🔄 **iOS/Android**: Architecture ready, needs mobile-specific UI

### Adding Platform Support
1. Download PDFium binaries for target platform
2. Extract to `lib/pdfium-bin/<platform>/`
3. Update `copy-pdfium-dll.bat` for new platform
4. Test on target platform

---

## 🔧 Extending the Architecture

### Adding New Features

#### Example: Add Zoom Support

**Layer 2 (Document):**
```pascal
// DX.Pdf.Document.pas
procedure TPdfPage.RenderToBitmap(ABitmap: TBitmap; 
  ABackgroundColor: TAlphaColor; AZoomFactor: Single);
begin
  // Scale bitmap size by zoom factor
  ABitmap.SetSize(Round(FWidth * AZoomFactor), 
                  Round(FHeight * AZoomFactor));
  // ... rest of rendering
end;
```

**Layer 3 (Viewer):**
```pascal
// DX.Pdf.Viewer.FMX.pas
type
  TPdfViewer = class(TControl)
  private
    FZoomFactor: Single;
    procedure SetZoomFactor(const AValue: Single);
  published
    property ZoomFactor: Single read FZoomFactor write SetZoomFactor;
  end;
```

---

## 📊 Benefits of This Architecture

| Benefit | Description |
|---------|-------------|
| 🧪 **Testability** | Each layer can be tested independently |
| 🔧 **Maintainability** | Clear separation of concerns |
| 📈 **Extensibility** | Easy to add features without breaking existing code |
| 🌍 **Portability** | Layers 1 & 2 are platform-independent |
| ♻️ **Reusability** | Document layer can be used in VCL projects |
| 📚 **Understandability** | Clear dependencies and responsibilities |

---

## 🔗 Related Documentation

- [README.md](README.md) - Project overview and usage
- [Delphi Style Guide](https://github.com/omonien/DelphiStandards) - Coding standards
- [PDFium API Documentation](https://pdfium.googlesource.com/pdfium/+/refs/heads/main/public/)

---

**Made with ❤️ and Delphi**

