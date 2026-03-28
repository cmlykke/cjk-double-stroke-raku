use DB::SQLite;

# Correct way to open/create the database with DB::SQLite
my $db-path = $*PROGRAM.parent.add('src/localdatabase/test-chinese.db');

my $db = DB::SQLite.new(:filename($db-path));


# Create test table
$db.execute(q:to/SQL/);
    CREATE TABLE IF NOT EXISTS test (
        char TEXT PRIMARY KEY,
        data TEXT
    );
SQL
say "✅ DB::SQLite loaded and database opened successfully on Windows!";
say "SQLite version: ", $db.query('SELECT sqlite_version()').value;

# Optional quick test with a Chinese character
$db.execute("INSERT OR IGNORE INTO test (char, data) VALUES ('测试', 'It works!')");
my $result = $db.query("SELECT data FROM test WHERE char = '测试'").value;
say "Chinese test lookup: ", $result;

$db.finish;
say "Test completed successfully. You can now use this setup.";