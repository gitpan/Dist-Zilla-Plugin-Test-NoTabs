package Dist::Zilla::Plugin::Test::NoTabs;
BEGIN {
  $Dist::Zilla::Plugin::Test::NoTabs::AUTHORITY = 'cpan:FLORA';
}
{
  $Dist::Zilla::Plugin::Test::NoTabs::VERSION = '0.05';
}
# git description: v0.04-1-gff87e8c

# ABSTRACT: Release tests making sure hard tabs aren't used

use Moose;
use Path::Tiny;
use Sub::Exporter::ForMethods 'method_installer'; # method_installer returns a sub.
use Data::Section 0.004 # fixed header_re
    { installer => method_installer }, '-setup';
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
        default_finders => [ ':ExecFiles' ],
    },
    'Dist::Zilla::Role::PrereqSource';

around dump_config => sub
{
    my ($orig, $self) = @_;
    my $config = $self->$orig;

    $config->{'' . __PACKAGE__} = {
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

    $self->add_file( Dist::Zilla::File::InMemory->new(
        name => 'xt/release/no-tabs.t',
        content => ${$self->section_data('xt/release/no-tabs.t')},
    ));
}

sub munge_file
{
    my ($self, $file) = @_;

    my $filename = $file->name;
    return unless $filename eq 'xt/release/no-tabs.t'
        or $filename eq 't/release-no-tabs.t';  # ExtraTests may have renamed us

    my @filenames = map { path($_->name)->relative('.')->stringify }
        (@{ $self->found_module_files }, @{ $self->found_script_files });

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

=pod

=encoding utf-8

=for :stopwords Florian Ragwitz Karen Etheridge FileFinder executables

=head1 NAME

Dist::Zilla::Plugin::Test::NoTabs - Release tests making sure hard tabs aren't used

=head1 VERSION

version 0.05

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

=for Pod::Coverage::TrustPod register_prereqs
    gather_files
    munge_file

This is the name of a L<FileFinder|Dist::Zilla::Role::FileFinder> for finding
modules to check.  The default value is C<:InstallModules>; this option can be
used more than once.

Other predefined finders are listed in
L<Dist::Zilla::Role::FileFinderUser/default_finders>.
You can define your own with the
L<[FileFinder::ByName]|Dist::Zilla::Plugin::FileFinder::ByName> plugin.

=item * C<script_finder>

Just like C<module_finder>, but for finding scripts.  The default value is
C<:ExecFiles> (see also L<Dist::Zilla::Plugin::ExecDir>, to make sure these
files are properly marked as executables for the installer).

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
