use v6;
use Test;

plan 2;

sub get_memory() {
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


subtest {
    plan 5;

    my $before = get_memory();
    ok $before<vsz>:exists;
    ok $before<rss>:exists;
    like $before<vsz>, rx/^\d+$/;
    like $before<rss>, rx/^\d+$/;

    my $after = get_memory();
    my $change = $after<vsz> - $before<vsz>;
    diag "Memory diff is $change";
    ok  $change < 160_000, "Memory grows by less than ..." or diag "Memory diff is $change";
    # Memory diff is 56164 on This is Rakudo version 2017.07 built on MoarVM version 2017.07 on OSX
    # On Travis-CI 155,724
}


subtest {
    plan 1;

    my $before = get_memory();
    for 0..20 {
        my $res = get_memory();
    }
    
    my $after = get_memory();
    my $change = $after<vsz> - $before<vsz>;
    diag "Memory diff is $change";
    ok  $change < 700_000, "Memory grows by less than ..." or diag "Memory diff is $change";
    # Memory diff is 67816 on This is Rakudo version 2017.07 built on MoarVM version 2017.07 on OSX
    # On Travis-CI 636,524
}

