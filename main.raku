
use lib 'lib';
use CJKDecompositionDB;
use orderedlist;
my $db = get-db();

say "CJK Double Stroke Raku project is alive!";

my %freq = get-frequencies('知');

say "ordered frequency list";


my @ordered = get-ordered-cjk-frequencies($db);

my @miniordered = @ordered.head(5);

for @miniordered -> $entry {
    my ($char, $shortname,$short, $longname,$long) = $entry;
    say "Char: $char  →  short rank $shortname: $short, long rank $longname: $long";
}


