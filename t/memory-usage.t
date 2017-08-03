use v6;
use Test;

plan 2;

sub get_memory() {
    # ps axuw on OSX
    # Linux same columns, thought the titles are a bit different
    # USER               PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMMAND
    my @lines = QX('ps axuw').split(/\n/).map({ .split(/\s+/, 11) });
    my ($this) = @lines[1..*].grep({ $_[1] !=== Nil }).grep({ $_[1] eq $*PID });
    return({
        vsz => $this[4],
        rss => $this[5],
    });
}

my $start = get_memory();

subtest {
    ok $start<vsz>:exists;
    ok $start<rss>:exists;
    like $start<vsz>, rx/^\d+$/;
    like $start<rss>, rx/^\d+$/;
}


for 0..20 {
    my $res = get_memory();
}

my $end = get_memory();
my $change = $end<vsz> - $start<vsz>;
diag "Memory diff is $change";
ok  $change < 1161000, "Memory grows by less than ..." or diag "Memory diff is $change";

