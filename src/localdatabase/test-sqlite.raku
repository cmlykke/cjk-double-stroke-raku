use DB::SQLite;
use JSON::Fast;

# Target the actual database
my $db-path = $*PROGRAM.parent.parent.parent.add('resources/database/cjk-decompositions.db');

unless $db-path.e {
    die "Database file not found at: $db-path.absolute()\nPlease build it first with: raku -I src scripts/build-cjk-decompositions-db.raku";
}

my $db = DB::SQLite.new(:filename($db-path.absolute));

say "✅ DB::SQLite loaded and database opened successfully!";
say "SQLite version: ", $db.query('SELECT sqlite_version()').value;

# Test query on the actual table
my $char = '偬';
my $result = $db.query('SELECT decomps_json FROM cjk_decompositions WHERE char = ?', $char).value;

if $result {
    say "Successfully found data for character '$char':";
    say "Raw JSON: $result";
    my @decomps = from-json($result);
    for @decomps -> $pair {
        say "  Left: {$pair[0]}   Right: {$pair[1]}";
    }
} else {
    say "❌ Character '$char' not found in the database.";
}

$db.finish;
say "Verification completed successfully.";