use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Mojolicious::Plugin::Database',
    AUTHOR              => q{Ben van Staveren <madcat@cpan.org>},
    VERSION_FROM        => 'lib/Mojolicious/Plugin/Database.pm',
    ABSTRACT_FROM       => 'lib/Mojolicious/Plugin/Database.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'DBI'        => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Mojolicious-Plugin-Database-*' },
);
