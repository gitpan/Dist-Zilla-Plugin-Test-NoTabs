package Dist::Zilla::Plugin::Test::NoTabs;
BEGIN {
  $Dist::Zilla::Plugin::Test::NoTabs::AUTHORITY = 'cpan:FLORA';
}
# git description: v0.06-11-g7b13e41
$Dist::Zilla::Plugin::Test::NoTabs::VERSION = '0.07';
# ABSTRACT: Release tests making sure hard tabs aren't used
# vim: set ts=8 sw=4 tw=78 et :

use Moose;
use Path::Tiny;
use Sub::Exporter::ForMethods 'method_installer'; # method_installer returns a sub.
use Data::Section 0.004 # fixed header_re
    { installer => method_installer }, '-setup';
use Moose::Util::TypeConstraints;
use namespace::autoclean;

with
    'Dist::Zilla::Role::FileGatherer',
    'Dist::Zilla::Role::FileMunger',
    'Dist::Zilla::Role::TextTemplate',
    'Dist::Zilla::Role::FileFinderUser' => {
        method          => 'found_module_files',
        finder_arg_names => [ 'module_finder' ],
        default_finders => [ ':InstallModules' ],
    },
    'Dist::Zilla::Role::FileFinderUser' => {
        method          => 'found_script_files',
        finder_arg_names => [ 'script_finder' ],
        default_finders => [ ':ExecFiles', ':TestFiles' ],
            # TODO: really ought to be scanning xt/ as well; best to wait
            # until we have a builtin finder that can do that
    },
    'Dist::Zilla::Role::PrereqSource';

has files => (
    isa => 'ArrayRef[Str]',
    traits => ['Array'],
    handles => { files => 'elements' },
    lazy => 1,
    default => sub { [] },
);

has _file_obj => (
    is => 'rw', isa => role_type('Dist::Zilla::Role::File'),
);

sub mvp_multivalue_args { qw(files) }
sub mvp_aliases { return { file => 'files' } }

around dump_config => sub
{
    my ($orig, $self) = @_;
    my $config = $self->$orig;

    $config->{+__PACKAGE__} = {
         module_finder => $self->module_finder,
         script_finder => $self->script_finder,
    };
    return $config;
};

sub register_prereqs
{
    my $self = shift;
    $self->zilla->register_prereqs(
        {
            type  => 'requires',
            phase => 'develop',
        },
        'Test::More' => 0,
        'Test::NoTabs' => 0,
    );
}

sub gather_files
{
    my $self = shift;

    require Dist::Zilla::File::InMemory;

    $self->add_file(
        $self->_file_obj(
            Dist::Zilla::File::InMemory->new(
            name => 'xt/release/no-tabs.t',
            content => ${$self->section_data('xt/release/no-tabs.t')},
        ))
    );
}

sub munge_files
{
    my $self = shift;

    my $file = $self->_file_obj;

    my @filenames = map { path($_->name)->relative('.')->stringify }
        (@{ $self->found_module_files }, @{ $self->found_script_files });
    push @filenames, $self->files;

    $self->log_debug('adding file ' . $_) foreach @filenames;

    $file->content(
        $self->fill_in_string(
            $file->content,
            {
                dist => \($self->zilla),
                plugin => \$self,
                filenames => \@filenames,
            }
        )
    );

    return;
}
__PACKAGE__->meta->make_immutable;

#pod =pod
#pod
#pod =for Pod::Coverage::TrustPod
#pod     mvp_aliases
#pod     register_prereqs
#pod     gather_files
#pod     munge_files
#pod
#pod =head1 SYNOPSIS
#pod
#pod In your F<dist.ini>:
#pod
#pod     [Test::NoTabs]
#pod     module_finder = my_finder
#pod     script_finder = other_finder
#pod
#pod =head1 DESCRIPTION
#pod
#pod This is a plugin that runs at the L<gather files|Dist::Zilla::Role::FileGatherer> stage,
#pod providing the file F<xt/release/no-tabs.t>, a standard L<Test::NoTabs> test.
#pod
#pod This plugin accepts the following options:
#pod
#pod =over 4
#pod
#pod =item * C<module_finder>
#pod
#pod =for stopwords FileFinder
#pod
#pod This is the name of a L<FileFinder|Dist::Zilla::Role::FileFinder> for finding
#pod modules to check.  The default value is C<:InstallModules>; this option can be
#pod used more than once.
#pod
#pod Other predefined finders are listed in
#pod L<Dist::Zilla::Role::FileFinderUser/default_finders>.
#pod You can define your own with the
#pod L<[FileFinder::ByName]|Dist::Zilla::Plugin::FileFinder::ByName> plugin.
#pod
#pod =item * C<script_finder>
#pod
#pod =for stopwords executables
#pod
#pod Just like C<module_finder>, but for finding scripts.  The default value is
#pod C<:ExecFiles> (see also L<Dist::Zilla::Plugin::ExecDir>) and C<:TestFiles>.
#pod
#pod =item * C<file>: a filename to also test, in addition to any files found
#pod earlier. This option can be repeated to specify multiple additional files.
#pod
#pod =back
#pod
#pod =cut

=pod

=encoding UTF-8

=for :stopwords Florian Ragwitz Karen Etheridge FileFinder executables

=head1 NAME

Dist::Zilla::Plugin::Test::NoTabs - Release tests making sure hard tabs aren't used

=head1 VERSION

version 0.07

=head1 SYNOPSIS

In your F<dist.ini>:

    [Test::NoTabs]
    module_finder = my_finder
    script_finder = other_finder

=head1 DESCRIPTION

This is a plugin that runs at the L<gather files|Dist::Zilla::Role::FileGatherer> stage,
providing the file F<xt/release/no-tabs.t>, a standard L<Test::NoTabs> test.

This plugin accepts the following options:

=over 4

=item * C<module_finder>

=for Pod::Coverage::TrustPod mvp_aliases
    register_prereqs
    gather_files
    munge_files

This is the name of a L<FileFinder|Dist::Zilla::Role::FileFinder> for finding
modules to check.  The default value is C<:InstallModules>; this option can be
used more than once.

Other predefined finders are listed in
L<Dist::Zilla::Role::FileFinderUser/default_finders>.
You can define your own with the
L<[FileFinder::ByName]|Dist::Zilla::Plugin::FileFinder::ByName> plugin.

=item * C<script_finder>

Just like C<module_finder>, but for finding scripts.  The default value is
C<:ExecFiles> (see also L<Dist::Zilla::Plugin::ExecDir>) and C<:TestFiles>.

=item * C<file>: a filename to also test, in addition to any files found
earlier. This option can be repeated to specify multiple additional files.

=back

=head1 AUTHOR

Florian Ragwitz <rafl@debian.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Florian Ragwitz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 CONTRIBUTOR

Karen Etheridge <ether@cpan.org>

=cut

__DATA__
___[ xt/release/no-tabs.t ]___
use strict;
use warnings;

# this test was generated with {{ ref($plugin) . ' ' . ($plugin->VERSION || '<self>') }}

use Test::More 0.88;
use Test::NoTabs;

my @files = (
{{ join(",\n", map { "    '" . $_ . "'" } map { s/'/\\'/g; $_ } sort @filenames) }}
);

notabs_ok($_) foreach @files;
done_testing;
