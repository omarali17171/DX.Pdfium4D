# PDF Association Cheat Sheets Test

## Übersicht

Der Test `DX.Pdf.CheatSheets.Tests` lädt automatisch die PDF Association Cheat Sheets herunter und testet, ob sie ohne Fehler in den TPdfViewer geladen werden können.

## Warum dieser Test?

Die PDF Association Cheat Sheets sind öffentlich verfügbare, hochwertige PDF-Dokumente, die verschiedene PDF-Features demonstrieren. Sie eignen sich perfekt zum Testen, da sie:

- ✅ Verschiedene PDF-Versionen und Features abdecken
- ✅ Öffentlich verfügbar sind (keine Lizenzprobleme)
- ✅ Regelmäßig aktualisiert werden
- ✅ Professionell erstellt sind

## Wichtig: Lizenz

**Die Cheat Sheet PDFs dürfen NICHT ins Repository committed werden!**

Die Lizenz der PDFs ist nicht eindeutig geklärt, daher werden sie:
- Zur Laufzeit heruntergeladen
- Im temporären Verzeichnis gespeichert
- Nach dem Test automatisch gelöscht

## URLs aktualisieren

Die URLs der Cheat Sheets können sich ändern. Um sie zu aktualisieren:

1. Besuchen Sie: https://pdfa.org/resource/pdf-cheat-sheets/
2. Finden Sie die aktuellen Download-Links
3. Aktualisieren Sie die URLs in `DX.Pdf.CheatSheets.Tests.pas` in der Methode `GetCheatSheetUrls`

### Beispiel für URL-Struktur:

```pascal
Result := [
  'https://pdfa.org/wp-content/uploads/YYYY/MM/PDF20-CheatSheet-Basics.pdf',
  'https://pdfa.org/wp-content/uploads/YYYY/MM/PDF20-CheatSheet-Structure.pdf',
  // ... weitere URLs
];
```

## Test ausführen

```batch
cd src\tests
build-and-run-tests.bat
```

Der Test wird:
1. Die PDFs herunterladen
2. Jeden PDF in TPdfDocument laden
3. Prüfen, dass keine Fehler auftreten
4. Die Anzahl der Seiten ausgeben
5. Die temporären Dateien löschen

## Fehlerbehandlung

Wenn der Test fehlschlägt:

### HTTP 404 Fehler
- Die URLs sind veraltet
- Aktualisieren Sie die URLs wie oben beschrieben

### Download-Fehler
- Prüfen Sie Ihre Internetverbindung
- Prüfen Sie, ob die PDF Association Website erreichbar ist

### PDF-Ladefehler
- Dies deutet auf einen Bug in DX.Pdfium4D hin
- Laden Sie das PDF manuell herunter und testen Sie es
- Erstellen Sie einen Bug-Report mit dem problematischen PDF

## Alternativen

Falls die PDF Association Cheat Sheets nicht mehr verfügbar sind, können Sie:

1. Andere öffentliche PDF-Sammlungen verwenden
2. Die URLs in `GetCheatSheetUrls` anpassen
3. Eigene Test-PDFs erstellen (aber nicht ins Repo committen!)

## Technische Details

- **Test-Framework:** DUnitX
- **HTTP-Client:** System.Net.HttpClient
- **Temp-Verzeichnis:** `%TEMP%\DX.Pdfium4D.CheatSheets`
- **Cleanup:** Automatisch nach jedem Test

