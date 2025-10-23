# 📄 DX PDF-Viewer

> A minimalist, elegant PDF viewer for Windows
> Developed with Embarcadero Delphi FireMonkey (FMX)

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📖 **PDF Display** | Displays PDF files using Google's PDFium engine |
| 🖱️ **Drag & Drop** | Drag PDF files directly into the window |
| ⌨️ **Command Line** | Opens PDF files directly at startup via parameters |
| 🎨 **Minimalist** | Clean design without unnecessary features |
| ⚡ **Fast** | Native rendering with PDFium library |
| 🌍 **Cross-Platform Ready** | Architecture supports Windows, macOS, Linux, iOS, Android |

---

## 🚀 Usage

### 📂 Opening PDF Files

There are **three simple ways** to open a PDF file:

#### 1️⃣ Drag & Drop
Simply drag a PDF file onto the application window.

#### 2️⃣ Command Line
```bash
DxPdfViewer.exe "C:\Path\to\File.pdf"
```

#### 3️⃣ File Association
Associate `.pdf` files with DxPdfViewer.exe in Windows Explorer.

---

### 🧪 Testing with the Demo PDF

The project includes a **`readme.pdf`** (this file) that you can use for testing:

```bash
# 🎯 Simple with starter script
run-demo.bat

# 🔧 Or with PowerShell
.\run-demo.ps1

# ⚙️ Or manually
Win32\Debug\DxPdfViewer.exe readme.pdf
```

**Demo Features:**
- ✅ Formatted text with Markdown styling
- ✅ Tables and lists
- ✅ Code blocks
- ✅ Emojis and symbols

---

### 🔧 Technical Details

| Component | Details |
|-----------|---------|
| 🎯 **Framework** | Delphi FireMonkey (FMX) |
| 📊 **PDF Rendering** | Google PDFium (Chrome's PDF engine) |
| 💻 **Platform** | Windows (Win32/Win64) - Cross-platform ready |
| 🛠️ **Delphi Version** | Delphi 12 (Athens) |
| 📦 **Dependencies** | PDFium library (included) |
| 🏗️ **Architecture** | Clean 3-layer design: API → Document → Viewer |
| ✅ **Testing** | DUnitX test suite included |
| 🔧 **Installation** | No component installation required - viewer created dynamically |

> **Note:** PDF rendering uses Google's PDFium library, the same engine used in Chrome browser.

## 📁 Project Structure

```
📦 DX-PDFViewer/
│
├── 📄 DxPdfViewer.dpr              # Main program file
├── 📋 DxPdfViewer.dproj            # Delphi project file
│
├── 📝 Main.Form.pas                # Main form (code)
├── 🎨 Main.Form.fmx                # Main form (design)
│
├── 📂 src/                         # Source code
│   ├── 🔧 DX.Pdf.API.pas           # PDFium C-API bindings
│   ├── 📚 DX.Pdf.Document.pas      # Object-oriented PDF wrapper
│   └── 🖼️ DX.Pdf.Viewer.FMX.pas   # FMX viewer component
│
├── 📂 tests/                       # Unit tests
│   ├── 🧪 DxPdfViewerTests.dpr     # Test project
│   └── ✅ DX.Pdf.Document.Tests.pas # Document tests
│
├── 📂 lib/                         # External libraries
│   ├── 📦 pdfium-binaries/         # PDFium binaries (Git submodule)
│   └── 📚 pdfium-bin/              # Extracted PDFium DLLs
│
├── 📖 readme.pdf                   # Demo PDF (this file as PDF)
├── 📘 README.md                    # This file (Markdown)
│
├── ▶️ run-demo.bat                 # Starter script (Batch)
├── ⚡ run-demo.ps1                 # Starter script (PowerShell)
├── 🔧 copy-pdfium-dll.bat          # Post-build DLL copy script
│
├── 🚫 .gitignore                   # Git ignore file
├── 📌 .gitattributes               # Git attributes file
│
└── 📂 Win32/                       # Build output
    └── 📂 Debug/
        ├── 🚀 DxPdfViewer.exe      # Compiled application
        ├── 📚 pdfium.dll           # PDFium library
        └── 📂 dcu/                 # Delphi Compiled Units
```

---

## 🔨 Compilation

### 📋 Prerequisites

1. **Clone the repository with submodules:**
   ```bash
   git clone --recursive https://github.com/yourusername/DX-PDFViewer.git
   ```

2. **Or initialize submodules after cloning:**
   ```bash
   git submodule update --init --recursive
   ```

3. **Download PDFium binaries** (if not using submodule):
   - Download from [pdfium-binaries releases](https://github.com/bblanchon/pdfium-binaries/releases/latest)
   - Extract to `lib/pdfium-bin/`

### 💻 With MSBuild (Command Line)

```powershell
# Set Delphi environment
$env:BDS='C:\Program Files (x86)\Embarcadero\Studio\23.0'

# Compile project
msbuild DxPdfViewer.dproj /p:Config=Debug /p:Platform=Win32

# Copy PDFium DLL to output directory
.\copy-pdfium-dll.bat Win32 Debug
```

**Output:** `Win32\Debug\DxPdfViewer.exe`

---

### 🎨 With Delphi IDE

| Step | Action |
|------|--------|
| 1️⃣ | Open `DxPdfViewer.dproj` in Delphi 12 |
| 2️⃣ | Select the desired platform (Win32/Win64) |
| 3️⃣ | Press **F9** to compile and run |

---

## 📂 Output Paths

The project follows the **recommended Delphi schema**:

| Type | Path | Example |
|------|------|---------|
| 🚀 **Executable** | `$(Platform)\$(Config)` | `Win32\Debug` |
| 📦 **DCU Files** | `$(Platform)\$(Config)\dcu` | `Win32\Debug\dcu` |

> This enables clean separation between platforms and configurations.

---

## 📐 Coding Standards

This project follows the **[Delphi Style Guide](https://github.com/omonien/DelphiStandards/blob/master/Delphi%20Style%20Guide%20EN.md)**

### Naming Conventions

| Element | Format | Example |
|---------|--------|---------|
| 🏛️ **Classes** | `T` + PascalCase | `TMainForm` |
| 📝 **Local Variables** | `L` + PascalCase | `LFilePath` |
| 🔒 **Fields** | `F` + PascalCase | `FCurrentPdfPath` |
| 🔧 **Methods** | PascalCase | `LoadPdfFile` |
| 📌 **Constants** | `C_` + UPPER_SNAKE | `C_MAX_SIZE` |

### Formatting

| Rule | Value |
|------|-------|
| ↹ **Indentation** | 2 spaces |
| 📏 **Line Length** | Max. 120 characters |
| 📄 **File Encoding** | UTF-8 (without BOM for .pas) |
| ↵ **Line Endings** | CRLF (Windows standard) |

---

## 🏗️ Architecture

The project follows a clean **3-layer architecture** for maintainability and testability:

### Layer 1: PDFium API (`DX.Pdf.API.pas`)
- **Low-level C-API bindings** to PDFium library
- Platform-independent declarations
- Direct function imports from `pdfium.dll` / `libpdfium.so` / `libpdfium.dylib`
- Type definitions matching PDFium's C structures

### Layer 2: Document Wrapper (`DX.Pdf.Document.pas`)
- **Object-oriented wrapper** around PDFium API
- Automatic resource management (reference counting)
- Exception handling with custom exception types
- Classes: `TPdfLibrary`, `TPdfDocument`, `TPdfPage`
- **Fully unit tested** with DUnitX

### Layer 3: FMX Viewer (`DX.Pdf.Viewer.FMX.pas`)
- **Visual FMX component** for displaying PDFs
- Inherits from `TControl` for full FMX integration
- Features:
  - Page navigation (Next, Previous, First, Last)
  - Automatic rendering on resize
  - Background color customization
  - Event notifications (`OnPageChanged`)
- **Drag & Drop support** (works correctly, unlike TWebBrowser!)

### Benefits of this Architecture

| Benefit | Description |
|---------|-------------|
| ✅ **Testability** | Each layer can be tested independently |
| ✅ **Maintainability** | Clear separation of concerns |
| ✅ **Extensibility** | Easy to add new features (zoom, search, etc.) |
| ✅ **Cross-Platform** | Layer 1 & 2 are platform-independent |
| ✅ **Reusability** | Document layer can be used in VCL projects too |

---

## 📜 License

```
MIT License

Copyright (c) 2025 DX PDF-Viewer Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👨‍💻 Development

**Developed with:**
- 🤖 [Augment Code](https://www.augmentcode.com/) - AI-Powered Development
- 🛠️ Embarcadero Delphi 12 Athens
- 💻 FireMonkey (FMX) Framework

---

## 🔗 Links

### Project Resources
- 📚 [Delphi Style Guide](https://github.com/omonien/DelphiStandards)
- 🏢 [Embarcadero Delphi](https://www.embarcadero.com/products/delphi)
- 🌐 [FireMonkey Documentation](https://docwiki.embarcadero.com/RADStudio/en/FireMonkey_Application_Platform)

### PDFium Resources
- 📖 [PDFium Official Repository](https://pdfium.googlesource.com/pdfium/)
- 📦 [PDFium Binaries by bblanchon](https://github.com/bblanchon/pdfium-binaries)
- 📚 [PDFium API Documentation](https://pdfium.googlesource.com/pdfium/+/refs/heads/main/public/)

### Testing
- ✅ [DUnitX Framework](https://github.com/VSoftTechnologies/DUnitX)

---

<div align="center">

**Made with ❤️ and Delphi**

*Version 1.0 | 2025*

</div>

