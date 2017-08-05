use v6;
use Test;
use Memory;

plan 1;

# Sanity (selftest)
subtest {
    plan 5;

    start();
    my $change = end();
    ok $change<vsz>:exists;
    ok $change<rss>:exists;
    like $change<vsz>.Str, rx/^\d+$/;
    like $change<rss>.Str, rx/^\d+$/;

    diag "Memory diff is {$change.perl}";
    ok  $change<vsz> < 60_000, "Memory grows by less than ..." or diag "Memory diff is {$change.perl}";
    # Memory diff is 57056 on This is Rakudo version 2017.07 built on MoarVM version 2017.07 on OSX
    # On Travis-CI 
}

