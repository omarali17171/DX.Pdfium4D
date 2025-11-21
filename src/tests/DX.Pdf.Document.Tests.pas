{*******************************************************************************
  Unit: DX.Pdf.Document.Tests

  Part of DX Pdfium4D - Delphi Cross-Platform Wrapper für Pdfium
  https://github.com/omonien/DX-Pdfium4D

  Description:
    Unit tests for DX.Pdf.Document wrapper classes.
    Tests PDF document loading, metadata extraction, and rendering.

  Author: Olaf Monien
  Copyright (c) 2025 Olaf Monien
  License: MIT - see LICENSE file
*******************************************************************************}
unit DX.Pdf.Document.Tests;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  FMX.Graphics,
  DX.Pdf.API,
  DX.Pdf.Document;

{$M+}

type
  [TestFixture]
  TPdfDocumentTests = class
  private
    FTestPdfPath: string;
    procedure CreateSimpleTestPdf;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestLibraryInitialization;

    [Test]
    procedure TestDocumentCreation;

    [Test]
    procedure TestLoadNonExistentFile;

    [Test]
    procedure TestLoadValidPdf;

    [Test]
    procedure TestPageCount;

    [Test]
    procedure TestGetPage;

    [Test]
    procedure TestPageDimensions;

    [Test]
    procedure TestCloseDocument;

    [Test]
    procedure TestMultipleDocuments;

    [Test]
    procedure TestPdfVersion;

    [Test]
    procedure TestGetMetadata;

    [Test]
    procedure TestGetPdfAInfo;

    [Test]
    procedure TestStringHelperCompatibility;
  end;

implementation

{ TPdfDocumentTests }

procedure TPdfDocumentTests.Setup;
begin
  FTestPdfPath := TPath.Combine(TPath.GetTempPath, 'test_document.pdf');
  CreateSimpleTestPdf;
end;

procedure TPdfDocumentTests.TearDown;
begin
  if TFile.Exists(FTestPdfPath) then
    TFile.Delete(FTestPdfPath);
end;

procedure TPdfDocumentTests.CreateSimpleTestPdf;
const
  // Minimal valid PDF with one blank page (A4 size: 595x842 points)
  C_SIMPLE_PDF =
    '%PDF-1.4'#10 +
    '1 0 obj'#10 +
    '<< /Type /Catalog /Pages 2 0 R >>'#10 +
    'endobj'#10 +
    '2 0 obj'#10 +
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>'#10 +
    'endobj'#10 +
    '3 0 obj'#10 +
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R /Resources << >> >>'#10 +
    'endobj'#10 +
    '4 0 obj'#10 +
    '<< /Length 0 >>'#10 +
    'stream'#10 +
    'endstream'#10 +
    'endobj'#10 +
    'xref'#10 +
    '0 5'#10 +
    '0000000000 65535 f '#10 +
    '0000000009 00000 n '#10 +
    '0000000058 00000 n '#10 +
    '0000000115 00000 n '#10 +
    '0000000229 00000 n '#10 +
    'trailer'#10 +
    '<< /Size 5 /Root 1 0 R >>'#10 +
    'startxref'#10 +
    '277'#10 +
    '%%EOF';
var
  LStream: TFileStream;
  LBytes: TBytes;
begin
  LBytes := TEncoding.ANSI.GetBytes(C_SIMPLE_PDF);
  LStream := TFileStream.Create(FTestPdfPath, fmCreate);
  try
    LStream.WriteBuffer(LBytes, Length(LBytes));
  finally
    LStream.Free;
  end;
end;

procedure TPdfDocumentTests.TestLibraryInitialization;
begin
  TPdfLibrary.Initialize;
  Assert.IsTrue(TPdfLibrary.IsInitialized, 'PDFium library should be initialized');
  TPdfLibrary.Finalize;
end;

procedure TPdfDocumentTests.TestDocumentCreation;
var
  LDocument: TPdfDocument;
begin
  LDocument := TPdfDocument.Create;
  try
    Assert.IsNotNull(LDocument, 'Document should be created');
    Assert.IsFalse(LDocument.IsLoaded, 'Document should not be loaded initially');
    Assert.AreEqual(0, LDocument.PageCount, 'Page count should be 0 for unloaded document');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestLoadNonExistentFile;
var
  LDocument: TPdfDocument;
  LExceptionRaised: Boolean;
begin
  LDocument := TPdfDocument.Create;
  try
    LExceptionRaised := False;
    try
      LDocument.LoadFromFile('nonexistent_file.pdf');
    except
      on E: EPdfLoadException do
        LExceptionRaised := True;
    end;
    Assert.IsTrue(LExceptionRaised, 'Should raise EPdfLoadException for non-existent file');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestLoadValidPdf;
var
  LDocument: TPdfDocument;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);
    Assert.IsTrue(LDocument.IsLoaded, 'Document should be loaded');
    Assert.AreEqual(FTestPdfPath, LDocument.FileName, 'File name should match');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestPageCount;
var
  LDocument: TPdfDocument;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);
    Assert.AreEqual(1, LDocument.PageCount, 'Test PDF should have 1 page');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestGetPage;
var
  LDocument: TPdfDocument;
  LPage: TPdfPage;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);
    LPage := LDocument.GetPageByIndex(0);
    try
      Assert.IsNotNull(LPage, 'Page should be loaded');
      Assert.AreEqual(0, LPage.PageIndex, 'Page index should be 0');
    finally
      LPage.Free;
    end;
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestPageDimensions;
var
  LDocument: TPdfDocument;
  LPage: TPdfPage;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);
    LPage := LDocument.GetPageByIndex(0);
    try
      // A4 size is 595x842 points
      Assert.AreEqual(595.0, LPage.Width, 0.1, 'Page width should be 595 points (A4)');
      Assert.AreEqual(842.0, LPage.Height, 0.1, 'Page height should be 842 points (A4)');
    finally
      LPage.Free;
    end;
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestCloseDocument;
var
  LDocument: TPdfDocument;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);
    Assert.IsTrue(LDocument.IsLoaded, 'Document should be loaded');
    
    LDocument.Close;
    Assert.IsFalse(LDocument.IsLoaded, 'Document should not be loaded after Close');
    Assert.AreEqual(0, LDocument.PageCount, 'Page count should be 0 after Close');
    Assert.AreEqual('', LDocument.FileName, 'File name should be empty after Close');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestMultipleDocuments;
var
  LDocument1: TPdfDocument;
  LDocument2: TPdfDocument;
begin
  LDocument1 := TPdfDocument.Create;
  LDocument2 := TPdfDocument.Create;
  try
    LDocument1.LoadFromFile(FTestPdfPath);
    LDocument2.LoadFromFile(FTestPdfPath);
    
    Assert.IsTrue(LDocument1.IsLoaded, 'Document 1 should be loaded');
    Assert.IsTrue(LDocument2.IsLoaded, 'Document 2 should be loaded');
    Assert.AreEqual(1, LDocument1.PageCount, 'Document 1 should have 1 page');
    Assert.AreEqual(1, LDocument2.PageCount, 'Document 2 should have 1 page');
  finally
    LDocument2.Free;
    LDocument1.Free;
  end;
end;

procedure TPdfDocumentTests.TestPdfVersion;
var
  LDocument: TPdfDocument;
  LVersion: Integer;
  LVersionString: string;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);

    LVersion := LDocument.GetFileVersion;
    LVersionString := LDocument.GetFileVersionString;

    Assert.IsTrue(LVersion > 0, 'PDF version should be greater than 0');
    Assert.AreEqual('1.4', LVersionString, 'PDF version string should be 1.4');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestGetMetadata;
var
  LDocument: TPdfDocument;
  LTitle: string;
  LAuthor: string;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);

    // Test metadata retrieval (may be empty for minimal PDF)
    LTitle := LDocument.GetMetadata('Title');
    LAuthor := LDocument.GetMetadata('Author');

    // Should not raise exception, even if empty
    Assert.Pass('Metadata retrieval works without errors');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestGetPdfAInfo;
var
  LDocument: TPdfDocument;
  LPdfAInfo: string;
begin
  LDocument := TPdfDocument.Create;
  try
    LDocument.LoadFromFile(FTestPdfPath);

    // Test PDF/A detection (should be empty for minimal PDF)
    LPdfAInfo := LDocument.GetPdfAInfo;

    // Should return empty string for non-PDF/A documents
    Assert.AreEqual('', LPdfAInfo, 'Minimal PDF should not be PDF/A');
  finally
    LDocument.Free;
  end;
end;

procedure TPdfDocumentTests.TestStringHelperCompatibility;
var
  LTestString: string;
  LUpperString: string;
  LLowerString: string;
  LTrimmedString: string;
begin
  // Test String Helper methods used in PDF/A detection
  LTestString := '  PDF/A-1b  ';

  // Test ToUpper (replaces UpperCase)
  LUpperString := LTestString.ToUpper;
  Assert.IsTrue(LUpperString.Contains('PDF/A'), 'ToUpper should work correctly');

  // Test ToLower (replaces LowerCase)
  LLowerString := LTestString.ToLower;
  Assert.IsTrue(LLowerString.Contains('pdf/a'), 'ToLower should work correctly');

  // Test Trim
  LTrimmedString := LTestString.Trim;
  Assert.AreEqual('PDF/A-1b', LTrimmedString, 'Trim should remove whitespace');

  // Test Contains (replaces Pos > 0)
  Assert.IsTrue(LUpperString.Contains('PDF/A-1'), 'Contains should find substring');
  Assert.IsFalse(LUpperString.Contains('PDF/A-2'), 'Contains should not find non-existent substring');

  // Test chaining
  Assert.IsTrue(LTestString.Trim.ToUpper.Contains('PDF/A-1'), 'String helper chaining should work');
end;

initialization
  TDUnitX.RegisterTestFixture(TPdfDocumentTests);

end.

