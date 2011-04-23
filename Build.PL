use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Mojolicious::Plugin::Database',
    license             => 'perl',
    dist_author         => q{Ben van Staveren <madcat@cpan.org>},
    dist_version_from   => 'lib/Mojolicious/Plugin/Database.pm',
    dist_abstract       => 'Mojolicious plugin to make usage of DBI a bit easier',
    configure_requires  => {
        'Module::Build' => '0.38',
    },
    build_requires => {
        'Test::More'    =>  0,
        'Test::Mojo'    =>  0,
    },
    requires => {
        'Mojolicious'   =>  '1.21',
    },
    add_to_cleanup      => [ 'Mojolicious-Plugin-Database-*' ],
);

$builder->create_build_script();
