# cjk-double-stroke-raku

## Recompile on windows:
- PS C:\Users\CMLyk\RakuProjects\cjk-double-stroke-raku> Remove-Item -Recurse -Force .precomp -ErrorAction SilentlyContinue
- PS C:\Users\CMLyk\RakuProjects\cjk-double-stroke-raku> Remove-Item -Recurse -Force src\filemanipulation\.precomp -ErrorAction SilentlyContinue

## Running the project
- if you are in a WSL linux terminal, run: powershell.exe
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku>  raku main.raku

## Run tests
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku> raku -I src/filemanipulation test/filemanipulation_test.raku

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

## run script to read offical files into the SQlite database
- the file is here: filemanipulation\AddOfficialFilesToDatabase.raku
- run: 

## running tests

## Used Files

### IDS File
- **Filename:** `cjk-double-stroke-raku\resources\official-cjk-files\babelstone-co-uk-cjk-ids.txt`
- **Source:** https://www.babelstone.co.uk/CJK/IDS.TXT

## File Protection

### Protecting Official CJK Data Files
A guide for contributors

This project includes a set of official CJK reference files that should never be modified locally. To prevent accidental edits, we use Git's skip-worktree mechanism, which tells Git:

"Pretend this file never changes, even if the user edits it."

This guide explains how to enable, verify, and disable that protection.

#### What this system does
Some files in `resources/official-cjk-files/` are authoritative reference data. To avoid accidental edits, we mark them as skip-worktree, which means:

- Git will ignore local modifications
- `git status` will not show changes to these files
- Contributors can still open and read them normally
- The files remain tracked in the repository

This is ideal for large, stable datasets that should not be edited manually.

#### Files covered
All `.txt` files inside:

`resources/official-cjk-files/`

Example:

`resources/official-cjk-files/babelstone-co-uk-cjk-ids.txt`

#### How to enable protection
Run the provided PowerShell script:

```powershell
./scripts/protect-official-files.ps1
```

If it succeeds, it prints no output.

To verify that protection is active:

```powershell
git ls-files -v resources/official-cjk-files
```

You should see:

```
s resources/official-cjk-files/babelstone-co-uk-cjk-ids.txt
```

The lowercase `s` means:

- `s` = skip-worktree enabled
- Git will ignore local edits

#### How the script works (for the curious)
The script expands all `.txt` files in the folder and applies:

```powershell
git update-index --skip-worktree <file>
```

This is the correct way to apply skip-worktree on Windows, where Git does not expand wildcards automatically.

#### How to disable protection (unprotect files)
If you need to edit the official files (e.g., updating the dataset), you can remove the skip-worktree flag.

**Option A — Unprotect a single file**

```powershell
git update-index --no-skip-worktree resources/official-cjk-files/<filename>.txt
```

**Option B — Unprotect all official files**

Run:

```powershell
./scripts/unprotect-official-files.ps1
```

(If this script does not exist yet, it can be added using the same pattern as the protect script.)

Verify:

```powershell
git ls-files -v resources/official-cjk-files
```

You should now see:

```
H resources/official-cjk-files/babelstone-co-uk-cjk-ids.txt
```

`H` means the file is tracked normally again.

#### How to check whether protection is active
Run:

```powershell
git ls-files -v resources/official-cjk-files
```

Interpretation:

| Letter | Meaning |
|--------|---------|
| s | Protected (skip-worktree active) |
| H | Normal tracked file |
| M | Modified |
| - | Normal file, unchanged |

#### Notes
- Skip-worktree is local only. It does not affect other contributors.
- You can still open and read protected files normally.
- If you edit a protected file, Git will silently ignore the change.