#!/usr/bin/env raku
#| Rebuilds the CJK decomposition database from the official source file.
#| Run this whenever the official data changes.

use databasehandling::AddOfficialFilesToDatabase;
use databasehandling::parseJundaAndTzaiToDatabase;

use DB::SQLite;
use JSON::Fast;

# ========================= CONFIG =========================
my $source-file = $*PROGRAM.parent.parent.add('resources/official-cjk-files/babelstone-co-uk-cjk-ids.txt');
my $junda-file  = $*PROGRAM.parent.parent.add('resources/official-cjk-files/Junda2005.txt');
my $tzai-file   = $*PROGRAM.parent.parent.add('resources/official-cjk-files/Tzai2006.txt');
my $db-path     = $*PROGRAM.parent.parent.add('resources/database/cjk-decompositions.db');

unless $source-file.e {
    die "Source file not found:\n  $source-file";
}
unless $junda-file.e {
    die "Junda file not found:\n  $junda-file";
}
unless $tzai-file.e {
    die "Tzai file not found:\n  $tzai-file";
}
# =========================================================

say "=== Starting CJK database rebuild ===";
say "Decomp Source  : $source-file";
say "Junda Source   : $junda-file";
say "Tzai Source    : $tzai-file";
say "Target         : $db-path";

# 1. Parse the official file using your existing logic
say "Parsing decompositions...";
my $fh = open $source-file, :r;
my %parsed = parse-cjk-decompositions($fh);
$fh.close;

say "Parsed {%parsed.elems} characters with decompositions.";

# 2. Parse Junda and Tzai frequency data
say "Parsing frequency data...";
my %frequencies = parse-junda-and-tzai($junda-file.IO, $tzai-file.IO);
say "Parsed {%frequencies.elems} characters with frequency data.";

# 3. Ensure database directory exists
$db-path.parent.mkdir;

# 4. Open DB and rebuild tables (drop + recreate for clean rebuild)
my $db = DB::SQLite.new(:filename($db-path.absolute));

$db.execute("DROP TABLE IF EXISTS cjk_decompositions");
$db.execute("DROP TABLE IF EXISTS cjk_frequencies");

$db.execute(q:to/SQL/);
    CREATE TABLE cjk_decompositions (
        char          TEXT PRIMARY KEY,
        decomps_json  TEXT NOT NULL
    );
SQL

$db.execute(q:to/SQL/);
    CREATE TABLE cjk_frequencies (
        char        TEXT PRIMARY KEY,
        junda_ord   INTEGER,
        junda_freq  REAL,
        tzai_ord    INTEGER,
        tzai_freq   REAL
    );
SQL

# 5. Bulk insert with transaction
say "Inserting data into SQLite...";

my $conn = $db.db;
$conn.execute('BEGIN TRANSACTION');

# Insert decompositions
my $sth-decomp = $conn.prepare('INSERT INTO cjk_decompositions (char, decomps_json) VALUES (?, ?)');
for %parsed.kv -> $char, $decomps {
    my $json = to-json($decomps, :!pretty);
    $sth-decomp.execute($char, $json);
}

# Insert frequencies
my $sth-freq = $conn.prepare('INSERT INTO cjk_frequencies (char, junda_ord, junda_freq, tzai_ord, tzai_freq) VALUES (?, ?, ?, ?, ?)');
for %frequencies.kv -> $char, %data {
    $sth-freq.execute(
        $char,
        %data<junda-ord> // Nil,
        %data<junda-freq> ?? %data<junda-freq>.Num !! Nil,
        %data<tzai-ord> // Nil,
        %data<tzai-freq> ?? %data<tzai-freq>.Num !! Nil
    );
}

$conn.execute('COMMIT');

say "✅ Successfully built database.";
say "Decompositions: {%parsed.elems}";
say "Frequencies:    {%frequencies.elems}";

$db.finish;
