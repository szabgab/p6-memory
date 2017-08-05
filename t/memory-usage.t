use v6;
use Test;

plan 3;

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


# Sanity (selftest)
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
    ok  $change < 377_000, "Memory grows by less than ..." or diag "Memory diff is $change";
    # Memory diff is 56164 on This is Rakudo version 2017.07 built on MoarVM version 2017.07 on OSX
    # On Travis-CI 155,724
    # On Travis-CI 376,920  (another run)
}

# Sanity (selftest)
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
    # On Travis-CI 287_288
}

# Regex
subtest {
    plan 1;

    my $before = get_memory();
    for 0..2000 {
        "abc 23 xy" ~~ /(\d+)/;
    }
    my $after = get_memory();
    my $change = $after<vsz> - $before<vsz>;
    diag "Memory diff is $change";
    ok  $change < 8_500, "Memory grows by less than ..." or diag "Memory diff is $change";
    # Memory diff is 8,440 on This is Rakudo version 2017.07 built on MoarVM version 2017.07 on OSX
    # Subsequent runs showed much lower memory change
    # Without the capturing () it only grew by 224 bytes
    # On Travis-CI 124 bytes
}


