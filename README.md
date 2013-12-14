# NAME

Dist::Zilla::Plugin::Test::NoTabs - Release tests making sure hard tabs aren't used

# VERSION

version 0.06

# SYNOPSIS

In your `dist.ini`:

    [Test::NoTabs]
    module_finder = my_finder
    script_finder = other_finder

# DESCRIPTION

This is a plugin that runs at the [gather files](https://metacpan.org/pod/Dist::Zilla::Role::FileGatherer) stage,
providing the file `xt/release/no-tabs.t`, a standard [Test::NoTabs](https://metacpan.org/pod/Test::NoTabs) test.

This plugin accepts the following options:

- `module_finder`

    This is the name of a [FileFinder](https://metacpan.org/pod/Dist::Zilla::Role::FileFinder) for finding
    modules to check.  The default value is `:InstallModules`; this option can be
    used more than once.

    Other predefined finders are listed in
    ["default_finders" in Dist::Zilla::Role::FileFinderUser](https://metacpan.org/pod/Dist::Zilla::Role::FileFinderUser#default_finders).
    You can define your own with the
    [[FileFinder::ByName]](https://metacpan.org/pod/Dist::Zilla::Plugin::FileFinder::ByName) plugin.

- `script_finder`

    Just like `module_finder`, but for finding scripts.  The default value is
    `:ExecFiles` (see also [Dist::Zilla::Plugin::ExecDir](https://metacpan.org/pod/Dist::Zilla::Plugin::ExecDir), to make sure these
    files are properly marked as executables for the installer).

- `file`: a filename to also test, in addition to any files found
earlier. This option can be repeated to specify multiple additional files.

# AUTHOR

Florian Ragwitz <rafl@debian.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Florian Ragwitz.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# CONTRIBUTOR

Karen Etheridge <ether@cpan.org>
