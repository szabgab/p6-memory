unit module Memory:ver<0.0.1>;

sub get_memory() is export {
    # ps axuw on OSX
    # Linux same columns, thought the titles are a bit different
    # USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT beforeED      TIME COMMAND
    my @lines = QX('ps axuw').split(/\n/).map({ .split(/\s+/, 11) });
    my ($this) = @lines[1..*].grep({ $_[1] !=== Nil }).grep({ $_[1] eq $*PID });
    return({
        vsz => $this[4],
        rss => $this[5],
    });
}

my $start;

sub start() is export {
    $start = get_memory();
}

sub end() is export {
    my $end = get_memory();
    my $change = {
        vsz => $end<vsz> - $start<vsz>,
        rss => $end<rss> - $start<rss>,
    }
    return $change;
}

