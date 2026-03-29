#| Provides clean access to the CJK decomposition SQLite database.
#| The database stores decompositions as JSON for easy round-tripping.

unit module CJKDecompositionDB;

use DB::SQLite;
use JSON::Fast;

my $db-path = %*ENV<CJK_DB_PATH> 
    ?? %*ENV<CJK_DB_PATH>.IO.absolute
    !! 'resources/database/cjk-decompositions.db'.IO.absolute;
my $db;   # lazy singleton

sub get-db(--> DB::SQLite) is export {
    unless $db {
        $db = DB::SQLite.new(:filename($db-path));
        ensure-table($db);
    }
    $db
}

sub ensure-table(DB::SQLite $db) {
    $db.execute(q:to/SQL/);
        CREATE TABLE IF NOT EXISTS cjk_decompositions (
            char          TEXT PRIMARY KEY,
            decomps_json  TEXT NOT NULL
        );
    SQL
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