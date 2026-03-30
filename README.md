# cjk-double-stroke-raku

## complete project health check:
- rebuild database:
- raku -I lib scripts\build-cjk-decompositions-db.raku

- verify that the database works:
- raku -I lib src/localdatabase/test-sqlite.raku

- run tests:
- zef test . --verbose


## First time setup
- [README-firstTimeSetup](./READMEfiles/README-firstTimeSetup.md)

Has a focus on setting up file protection

## Recompile on windows:
- PS C:\Users\CMLyk\RakuProjects\cjk-double-stroke-raku> Remove-Item -Recurse -Force .precomp -ErrorAction SilentlyContinue

## Running the project
- if you are in a WSL linux terminal, run: powershell.exe
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku>  raku -I lib main.raku

## Run tests
- Run all tests (standard Raku way):
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku> zef test .
- or
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku>  zef test . --verbose
- Run single test file:
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku> raku -I lib test/filemanipulation_test.raku
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku> raku -I lib test/parsingJundaAndTzai_test.raku
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku> raku -I lib t/database_test/cjkdecomposition_database_test.rakutest
- run: C:\Users\USER\MYPROJECTS\cjk-double-stroke-raku> raku -I lib t/database_test/cjkcharacterfrequency_database_test.rakutest

## How to use the SQlite database
- [README-database](./READMEfiles/README-database.md)

- Verify that the database is running and works:
- run `raku -I lib src/localdatabase/test-sqlite.raku`


## Running tests
- run: `zef test .`

## Used Files

### IDS File
- **Filename:** `cjk-double-stroke-raku\resources\official-cjk-files\babelstone-co-uk-cjk-ids.txt`
- **Source:** https://www.babelstone.co.uk/CJK/IDS.TXT

### Junda and Tzai Frequency Files
- **Junda:** `resources/official-cjk-files/Junda2005.txt`
- **Tzai:**  `resources/official-cjk-files/Tzai2006.txt`
