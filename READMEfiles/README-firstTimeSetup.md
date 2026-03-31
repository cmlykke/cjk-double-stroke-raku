
## Install dependencies
This project uses several libraries. Since Raku does not automatically install dependencies from a file like `package.json` in Node.js, you must install them manually or using `zef`:

- **Required Libraries:**
    - `DB::SQLite`
    - `JSON::Fast`

To install all dependencies, run:
- `zef install . --deps-only`

Alternatively, you can install them individually:
- `zef install DB::SQLite JSON::Fast`
- `zef install App::Prove6`

If these are not installed, you will get an error when running `prove6 -I. t/`.


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