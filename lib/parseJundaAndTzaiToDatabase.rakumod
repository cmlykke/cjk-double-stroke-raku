unit module parseJundaAndTzaiToDatabase;

sub parse-junda-and-tzai(IO::Path $junda-path, IO::Path $tzai-path --> Hash) is export {
    my %result;

    # Parse Junda2005.txt
    my $junda-total = 0;
    my @junda-records;
    for $junda-path.lines -> $line {
        my @fields = $line.split(/\t/);
        next if @fields.elems < 3;
        my $rank = @fields[0].Int;
        my $char = @fields[1];
        my $occurrence = @fields[2].Int;
        $junda-total += $occurrence;
        @junda-records.push({ :$rank, :$char, :$occurrence });
    }

    # Parse Tzai2006.txt
    my $tzai-total = 0;
    my @tzai-records;
    my $tzai-rank = 0;
    for $tzai-path.lines -> $line {
        my @fields = $line.split(/\s+/, :skip-empty);
        next if @fields.elems < 2;
        $tzai-rank++;
        my $char = @fields[0];
        my $occurrence = @fields[1].Int;
        $tzai-total += $occurrence;
        @tzai-records.push({ :rank($tzai-rank), :$char, :$occurrence });
    }

    # Combine results
    for @junda-records -> $item {
        my $char = $item<char>;
        %result{$char}<junda-ord> = $item<rank>;
        %result{$char}<junda-freq> = Rat.new($item<occurrence>, $junda-total);
    }

    for @tzai-records -> $item {
        my $char = $item<char>;
        %result{$char}<tzai-ord> = $item<rank>;
        %result{$char}<tzai-freq> = Rat.new($item<occurrence>, $tzai-total);
    }

    return %result;
}
