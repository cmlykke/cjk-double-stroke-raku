#!/usr/bin/env raku
#| Rebuilds the CJK decomposition database from the official source file.
#| Run this whenever the official data changes.

use lib $*PROGRAM.parent.parent.add('src').absolute;
use filemanipulation::AddOfficialFilesToDatabase;

use DB::SQLite;
use JSON::Fast;

# ========================= CONFIG =========================
my $source-file = $*PROGRAM.parent.parent.add('resources/official-cjk-files/babelstone-co-uk-cjk-ids.txt');
my $db-path     = $*PROGRAM.parent.parent.add('resources/database/cjk-decompositions.db');

unless $source-file.e {
    die "Source file not found:\n  $source-file";
}
# =========================================================

say "=== Starting CJK decomposition DB rebuild ===";
say "Source : $source-file";
say "Target : $db-path";

# 1. Parse the official file using your existing logic
my $fh = open $source-file, :r;
my %parsed = parse-cjk-decompositions($fh);
$fh.close;

say "Parsed {%parsed.elems} characters successfully.";

# 2. Ensure database directory exists
$db-path.parent.mkdir;

# 3. Open DB and rebuild table (drop + recreate for clean rebuild)
my $db = DB::SQLite.new(:filename($db-path.absolute));

$db.execute("DROP TABLE IF EXISTS cjk_decompositions");
$db.execute(q:to/SQL/);
    CREATE TABLE cjk_decompositions (
        char          TEXT PRIMARY KEY,
        decomps_json  TEXT NOT NULL
    );
SQL

# 4. Bulk insert with transaction (much faster)
say "Inserting data into SQLite...";

my $conn = $db.db;
$conn.execute('BEGIN TRANSACTION');

my $sth = $conn.prepare('INSERT INTO cjk_decompositions (char, decomps_json) VALUES (?, ?)');

for %parsed.kv -> $char, $decomps {
    my $json = to-json($decomps, :!pretty);   # compact JSON
    $sth.execute($char, $json);
}

$conn.execute('COMMIT');

say "✅ Successfully built database with {%parsed.elems} characters.";
say "You can now use CJKDecompositionDB in your code.";

$db.finish;
