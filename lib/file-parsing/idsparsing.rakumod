unit module file-parsing::idsparsing;

use databasehandling::orderedlist;
use databasehandling::CJKDecompositionDB;

sub get-ordered-cjk-frequencies-count() is export {
    my $db = get-db();
    my @ordered = get-ordered-cjk-frequencies($db);
    return @ordered.elems();
}

sub get-ids-recur(Str $single-char --> Str) is export {
    my @lookup = get-decompositions($single-char);
    say @lookup.raku;
    return “5”;
}
