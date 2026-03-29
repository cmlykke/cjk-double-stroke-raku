
## Install SQLite
- go to https://www.sqlite.org/download.html
  and download the appropriate precompiled binary,
  eg. sqlite-dll-win-x64-3510300.zip
- Extract it, so you get a sqlite3.dll file
- place the file here:
  C:\rakubrew\versions\moar-2026.02\bin\
  (or whereever you /bin folder is)
- run: zef install DB::SQLite
- run: zef install DB::SQLite --force-test

## Make VS code use Windows termianal
It is nessasary to make VS code use the Windows terminal
(not cmd or powershell) in order to display chinese characters.
- Open VS Code Settings
- open user settings (Ctrl+Shift+p User settings)
- Insert the following lines in the file:

  "terminal.external.windowsExec": "wt.exe"

ie.

    "terminal.integrated.defaultProfile.windows": "PowerShell 7",
    "terminal.external.windowsExec": "wt.exe",
    "powershell.powerShellAdditionalExePaths": {
        "PowerShell 7": "C:\\Program Files\\PowerShell\\7\\pwsh.exe"
    },

- ensure that VScode terminal is using pwsh (PowerShell, not Windows powerShell)
- execute this:
  [Console]::OutputEncoding
- if it it doesnt say utf-8 then do this:
- run: code $PROFILE
- inside the file, add this line:
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
- Restart VScode
- in the terminal (should still be pwsh) run this: [Console]::OutputEncoding
- if you see these lines, it should be working:
  EncodingName : Unicode (UTF-8)
  WebName : utf-8
  CodePage : 65001
  IsSingleByte : False

## Building the CJK Decomposition Database
To (re)build the database from the official source files:
- run: `raku -I src scripts\build-cjk-decompositions-db.raku`

This will:
1. Parse the official IDS file in `resources/official-cjk-files/`.
2. Create/Recreate `resources/database/cjk-decompositions.db`.
3. Populate the database with the parsed data.

## Using the Database in Code
You can use the `localdatabase::CJKDecompositionDB` module to access the data:

```raku
use lib 'src';
use localdatabase::CJKDecompositionDB;

my @decomps = get-decompositions("偬");

if @decomps {
    say "Decompositions for 偬:";
    for @decomps -> $pair {
        say "  Left: {$pair[0]}   Right: {$pair[1]}";
    }
}
```

## Verify that the database is running and works
- run `raku src/localdatabase/test-sqlite.raku`

This script verifies that the database exists and can be queried for a test character ('偬').