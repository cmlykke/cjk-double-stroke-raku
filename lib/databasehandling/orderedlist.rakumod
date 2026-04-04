unit module databasehandling::orderedlist;

use DB::SQLite;

sub get-ordered-cjk-shared-frequencies(DB::SQLite $db) is export {
    my @rows = $db.query(q:to/SQL/).arrays;
        SELECT char, junda_ord, tzai_ord
        FROM cjk_frequencies
        WHERE junda_ord IS NOT NULL
          AND tzai_ord IS NOT NULL
        ORDER BY
            MIN(junda_ord, tzai_ord) ASC,
            MAX(junda_ord, tzai_ord) ASC,
            char ASC;
    SQL

    my @orderedlist;
    for @rows -> $row {
        my ($char, $junda, $tzai) = $row;

        if $junda <= $tzai {
            # Junda rank is smaller (better) → junda first
            @orderedlist.push: [$char, "junda", $junda, "tzai", $tzai];
        }
        else {
            # Tzai rank is smaller (better) → tzai first
            @orderedlist.push: [$char, "tzai", $tzai, "junda", $junda];
        }
    }

    return @orderedlist;
}


sub get-ordered-cjk-frequencies(DB::SQLite $db) is export {
my @rows = $db.query(q:to/SQL/).arrays;
        SELECT char, junda_ord, tzai_ord
        FROM cjk_frequencies
        ORDER BY
            -- 1. Primary: best (lowest) available rank
            COALESCE(
                CASE
                    WHEN junda_ord IS NULL THEN tzai_ord
                    WHEN tzai_ord IS NULL THEN junda_ord
                    ELSE MIN(junda_ord, tzai_ord)
                END,
                999999999
            ) ASC,

            -- 2. Secondary: prefer characters that have BOTH ranks (1 = has both, 0 = missing one)
            -- We use CASE so that "has both" explicitly comes first regardless of SQLite's boolean quirks
            CASE
                WHEN junda_ord IS NOT NULL AND tzai_ord IS NOT NULL THEN 0
                ELSE 1
            END ASC,

            -- 3. Tertiary: among same "has-both" status, sort by the worse rank
            COALESCE(
                CASE
                    WHEN junda_ord IS NULL THEN tzai_ord
                    WHEN tzai_ord IS NULL THEN junda_ord
                    ELSE MAX(junda_ord, tzai_ord)
                END,
                999999999
            ) ASC,

            -- 4. Final tie-breaker
            char ASC;
    SQL

    my @orderedlist;
    for @rows -> $row {
        my ($char, $junda, $tzai) = $row;

        # Handle NULLs gracefully
        if $junda.defined && $tzai.defined {
            if $junda <= $tzai {
                @orderedlist.push: [$char, "junda", $junda, "tzai", $tzai];
            }
            else {
                @orderedlist.push: [$char, "tzai", $tzai, "junda", $junda];
            }
        }
        elsif $junda.defined {
            # Only junda has a value → junda is better
            @orderedlist.push: [$char, "junda", $junda, "tzai", Nil];
        }
        elsif $tzai.defined {
            # Only tzai has a value → tzai is better
            @orderedlist.push: [$char, "tzai", $tzai, "junda", Nil];
        }
        else {
            # Both NULL → still include, but with no ranks
            @orderedlist.push: [$char, Nil, Nil, Nil, Nil];
        }
    }

    return @orderedlist;
}