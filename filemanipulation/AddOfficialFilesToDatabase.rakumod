#| Parses a file containing CJK character decomposition data in a specific format.
#|
#| Expected line format (example):
#|     U+506C  偬      ^⿰亻怱$(GHTJKP)
#|
#| - Lines starting with '#' are treated as comments and skipped.
#| - Each valid line must contain exactly one CJK Unified Ideograph.
#| - Decomposition patterns must appear in the form: ^LEFT$(RIGHT)
#|
#| Returns a hash where keys are CJK characters and values are arrays of
#| [left-part, right-part] pairs.

#| Parses CJK character decomposition data.
#| Supports lines with multiple decomposition sections, such as:
#|   U+4EE4 令 ^⿱⿵𠆢丶龴$(G[P][V][U][B]) ^⿱{88}龴$(H[M]TPV) ^⿱{88}𰆊$(JK[S])
#|
#| Returns a Hash where:
#|   key   = CJK character (Str)
#|   value = Array of Array[Str]   →  [left-part, right-part] for each decomposition
unit module AddOfficialFilesToDatabase;


sub parse-cjk-decompositions(IO::Handle $fh --> Hash) is export {
    my %result;

    for $fh.lines.kv -> $line-no, $raw-line {
        my $line = $raw-line.trim;
        next if $line eq '' || $line.starts-with('#');

        # Extract the CJK character
        my $char = extract-cjk-character($line);
        unless $char {
            note "FAIL (line { $line-no + 1 }): $raw-line\n  Reason: No valid CJK character found.";
            next;
        }

        unless is-cjk-unified-ideograph($char) {
            note "FAIL (line { $line-no + 1 }): $raw-line\n  Reason: '$char' is not a CJK Unified Ideograph.";
            next;
        }

        # Extract all ^...$(...) sections
        my @sections = extract-decomposition-sections($line);

        unless @sections {
            note "FAIL (line { $line-no + 1 }): $raw-line\n  Reason: No ^...$(...) sections found.";
            next;
        }

        # Parse each section
        my @parsed = parse-decomposition-sections(@sections, $raw-line, $line-no);

        # Only store if all sections parsed successfully
        if @parsed {
            %result{$char} = @parsed;
        }
    }

    return %result;
}


sub extract-cjk-character(Str $line --> Str) {
    $line ~~ / <.ws> (<:CJK_Unified_Ideographs>) / 
        ?? ~$0 
        !! Nil
}


sub is-cjk-unified-ideograph(Str $char --> Bool) {
    my $cp = $char.ord;
    0x4E00 ≤ $cp ≤ 0x9FFF
}


#| Extracts every occurrence of ^LEFT$(RIGHT) from the line
sub extract-decomposition-sections(Str $line --> Array) {
    $line.match(:global, / '^' ( <-[ $ ]>+ ) '$(' ( <-[ ) ]>+ ) ')' / )».List».Str
    # Returns list of [left, right-inside-parens] for each match
}


#| Parses the sections into clean [left, '$(right)'] pairs
sub parse-decomposition-sections(@sections, Str $original-line, Int $line-no --> Array) {
    my @parsed;

    for @sections -> $match {
        my ($left, $inside) = $match;

        # Reconstruct the right part exactly as '$(...)'
        my $right = '$(' ~ $inside ~ ')';

        # Basic validation: left part should not be empty
        if $left.trim eq '' {
            note "FAIL (line { $line-no + 1 }): $original-line\n  Reason: Empty left part in section '^$left\$($inside)'";
            return ();   # skip entire line
        }

        @parsed.push: [$left, $right];
    }

    @parsed
}


# ==================== USAGE ====================

# my $fh = open "decompositions.txt", :r;
# my %result = parse-cjk-decompositions($fh);
# $fh.close;

# say "Successfully parsed {%result.elems} characters.";
# say %result.raku;        # or use dd %result; for debugging
