
say "CJK Double Stroke Raku project is alive!";

# === Run database test as a separate script (this actually works) ===
#my $test-script = $*PROGRAM.IO.parent.add('src/localdatabase/test-sqlite.raku');

#if $test-script.e {
#    say "Running database setup from:";
#    say "   $test-script";
#    run 'raku', $test-script.absolute;   # <-- This is the key
#} 
#else {
#    say "❌ Could not find test-sqlite.raku at:";
#    say "   $test-script";
#}



use AddOfficialFilesToDatabase;


# Better path handling — relative to the main script
my $script-dir = $*PROGRAM.IO.dirname.IO;
my $data-file  = $script-dir.add('resources/official-cjk-files/babelstone-co-uk-cjk-ids.txt');

unless $data-file.e {
    die "Error: Data file not found!\nExpected at: $data-file";
}

my $fh = $data-file.open(:r, :enc('UTF-8'));

my %result = parse-cjk-decompositions($fh);
$fh.close;

say "Successfully parsed {%result.elems} characters.";
say %result.head;        
say %result.tail; 


#my $fh = $path.IO.open(:r, :enc<utf8>);

#for ^995 {
#    my $line = $fh.get or last;
#    next if $line.starts-with('#');
#    say $line;
#}

#$fh.close;


