use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.02 (pre-release)

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Dist/Zilla/Plugin/NoTabsTests.pm',
    'lib/Dist/Zilla/Plugin/Test/NoTabs.pm'
);

notabs_ok($_) foreach @files;
done_testing;
