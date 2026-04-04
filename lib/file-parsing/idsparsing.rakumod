unit module file-parsing::idsparsing;

use databasehandling::orderedlist;
use databasehandling::CJKDecompositionDB;

sub get-ordered-cjk-frequencies-count() is export {
    my $db = get-db();
    my @ordered = get-ordered-cjk-frequencies($db);
    return @ordered.elems();
}
