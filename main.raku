say "CJK Double Stroke Raku project is alive!";
# Tell Raku where to find our module (the 'filemanipulation' folder)

use lib 'filemanipulation';
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
say %result.raku;        # or use dd %result; for debugging



#my $fh = $path.IO.open(:r, :enc<utf8>);

#for ^995 {
#    my $line = $fh.get or last;
#    next if $line.starts-with('#');
#    say $line;
#}

#$fh.close;


