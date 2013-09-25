use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;
use Path::Tiny;
use Cwd;

BEGIN {
    use Dist::Zilla::Plugin::Test::NoTabs;
    $Dist::Zilla::Plugin::Test::NoTabs::VERSION = 9999
        unless $Dist::Zilla::Plugin::Test::NoTabs::VERSION;
}


my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            'source/dist.ini' => simple_ini(
                [ GatherDir => ],
                [ ExecDir => ],
                [ 'Test::NoTabs' => ],
            ),
            path(qw(source lib Foo.pm)) => <<'MODULE',
package Foo;
use strict;
use warnings;
1;
MODULE
            path(qw(source lib Bar.pod)) => <<'POD',
package Bar;
=pod

=cut
POD
            path(qw(source bin myscript)) => <<'SCRIPT',
use strict;
use warnings;
print "hello there!\n";
SCRIPT
        },
    },
);

$tzil->build;

my $build_dir = $tzil->tempdir->subdir('build');
my $file = path($build_dir, qw(xt release no-tabs.t));
ok( -e $file, 'test created');

my $content = $file->slurp;
unlike($content, qr/[^\S\n]\n/m, 'no trailing whitespace in generated test');
unlike($content, qr/\t/m, 'no tabs in generated test');

my @files = (
    path(qw(lib Foo.pm)),
    path(qw(lib Bar.pod)),
    path(qw(bin myscript)),
);

like($content, qr/'\Q$_\E'/m, "test checks $_") foreach @files;

my $cwd = getcwd;
my $files_tested;
subtest 'run the generated test' => sub
{
    chdir $build_dir;

    do $file;
    warn $@ if $@;

    $files_tested = Test::Builder->new->current_test;
};

is($files_tested, @files, 'correct number of files were tested');

chdir $cwd;

done_testing;
