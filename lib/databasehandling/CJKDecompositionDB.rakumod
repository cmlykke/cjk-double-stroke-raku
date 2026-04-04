#| Provides clean access to the CJK decomposition SQLite database.

unit module databasehandling::CJKDecompositionDB;

use DB::SQLite;
use JSON::Fast;

# Default path (used in normal operation)
my $default-db-path = %*ENV<CJK_DB_PATH>
    ?? %*ENV<CJK_DB_PATH>.IO.absolute
    !! 'resources/database/cjk-decompositions.db'.IO.absolute;

my $db;   # lazy singleton for normal use

#| Get database connection. Accepts optional :path for testing.
sub get-db(:$path = $default-db-path --> DB::SQLite) is export {
    # If a specific path is given, always create a fresh connection (important for tests)
    if $path ne $default-db-path {
        my $test-db = DB::SQLite.new(:filename($path.Str));
        ensure-table($test-db);
        return $test-db;
    }

    # Normal singleton behavior for production code
    unless $db {
        $db = DB::SQLite.new(:filename($default-db-path.Str));
        ensure-table($db);
    }
    $db
}
# ensure-table stays exactly the same
sub ensure-table(DB::SQLite $db) is export {
    $db.execute(q:to/SQL/);
        CREATE TABLE IF NOT EXISTS cjk_decompositions (
            char          TEXT PRIMARY KEY,
            decomps_json  TEXT NOT NULL
        );
    SQL

    $db.execute(q:to/SQL/);
        CREATE TABLE IF NOT EXISTS cjk_frequencies (
            char        TEXT PRIMARY KEY,
            junda_ord   INTEGER,
            junda_freq  REAL,
            tzai_ord    INTEGER,
            tzai_freq   REAL
        );
    SQL
}

#| Returns the frequency data for a character:
#|   junda_ord   (Int)
#|   junda_freq  (Rat)
#|   tzai_ord    (Int)
#|   tzai_freq   (Rat)
sub get-frequencies(Str $char --> Hash) is export {
    my $row = get-db.query(
        'SELECT junda_ord, junda_freq, tzai_ord, tzai_freq FROM cjk_frequencies WHERE char = ?',
        $char
    ).hash;

    return {} unless $row;

    return {
        junda-ord  => $row<junda_ord>,
        junda-freq => $row<junda_freq>.Rat,
        tzai-ord   => $row<tzai_ord>,
        tzai-freq  => $row<tzai_freq>.Rat,
    };
}

#| Returns the full hashmaps for all character frequencies.
sub get-all-frequencies(--> Hash) is export {
    my %result;
    my $db = get-db();
    my $res = $db.query('SELECT char, junda_ord, junda_freq, tzai_ord, tzai_freq FROM cjk_frequencies');

    my @rows = $res.hashes;
    for @rows -> $row {
        %result{$row<char>} = {
            junda-ord  => $row<junda_ord>,
            junda-freq => $row<junda_freq> ?? $row<junda_freq>.Rat !! 0.Rat,
            tzai-ord   => $row<tzai_ord>,
            tzai-freq  => $row<tzai_freq> ?? $row<tzai_freq>.Rat !! 0.Rat,
        };
    }
    return %result;
}

#| Returns the decomposition data exactly as your parser produced it:
#|   Array of Array[Str]  →  [ [left1, '$(right1)'], [left2, '$(right2)'], ... ]
sub get-decompositions(Str $char --> Array) is export {
    my $row = get-db.query(
        'SELECT decomps_json FROM cjk_decompositions WHERE char = ?',
        $char
    ).row;

    return () unless $row;                 # not found → empty list
    from-json($row[0])                     # returns Array[Array[Str]]
}

#| Returns the full hashmaps for all character decompositions.
sub get-all-decompositions(--> Hash) is export {
    my %result;
    my $db = get-db();
    my $res = $db.query('SELECT char, decomps_json FROM cjk_decompositions');

    my @rows = $res.hashes;
    for @rows -> $row {
        %result{$row<char>} = from-json($row<decomps_json>);
    }
    return %result;
}

#| Optional: get raw JSON if you ever need it
sub get-decompositions-json(Str $char --> Str) is export {
    get-db.query(
        'SELECT decomps_json FROM cjk_decompositions WHERE char = ?',
        $char
    ).value // ''
}

#| Convenience: check if a character exists in the DB
sub has-decompositions(Str $char --> Bool) is export {
    get-db.query(
        'SELECT 1 FROM cjk_decompositions WHERE char = ?',
        $char
    ).value.Bool
}