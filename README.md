# cjk-double-stroke-raku

## First time setup
- READMEfiles/README-firstTimeSetup.md

Has a focus on setting up file protection

## Recompile on windows:
- PS C:\Users\CMLyk\RakuProjects\cjk-double-stroke-raku> Remove-Item -Recurse -Force .precomp -ErrorAction SilentlyContinue
- PS C:\Users\CMLyk\RakuProjects\cjk-double-stroke-raku> Remove-Item -Recurse -Force src\filemanipulation\.precomp -ErrorAction SilentlyContinue

## Running the project
- if you are in a WSL linux terminal, run: powershell.exe
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku>  raku main.raku

## Run tests
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku> raku -I src/filemanipulation test/filemanipulation_test.raku

## How to use the SQlite database
- src/localdatabase/README-database.md

- Verify that the database is running and works:
- run `raku src/localdatabase/test-sqlite.raku`


## Running tests
- run: `raku -I src test/filemanipulation_test.raku`

## Used Files

### IDS File
- **Filename:** `cjk-double-stroke-raku\resources\official-cjk-files\babelstone-co-uk-cjk-ids.txt`
- **Source:** https://www.babelstone.co.uk/CJK/IDS.TXT
