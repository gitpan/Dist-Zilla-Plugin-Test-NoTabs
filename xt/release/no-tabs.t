use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs <self>

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Dist/Zilla/Plugin/NoTabsTests.pm',
    'lib/Dist/Zilla/Plugin/Test/NoTabs.pm',
    't/00-report-prereqs.t',
    't/01-basic.t'
);

notabs_ok($_) foreach @files;
done_testing;
