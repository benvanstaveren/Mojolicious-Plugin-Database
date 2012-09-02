use strict;
use warnings;
package Mojolicious::Plugin::Database;
use Mojo::Base 'Mojolicious::Plugin';
use DBI;

sub register {
    my $self = shift;
    my $app  = shift;
    my $conf = shift || {};

    die ref($self), ': missing dsn parameter', "\n" unless($conf->{dsn});

    my $dbh_connect = sub { DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{options}) };

    $app->attr('dbh' => $dbh_connect);

    my $helper_name = $conf->{helper} || 'db';
    $app->helper($helper_name => sub { return shift->app->dbh });
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Database - "proper" handling of DBI based connections in Mojolicious

=head1 SYNOPSIS

Provides "sane" handling of DBI connections so problems with pre-forking (Hypnotoad, etc.) will not occur. 

    use Mojolicious::Plugin::Database;

    sub startup {
        my $self = shift;

        $self->plugin('database', { 
            dsn      => 'dbi:Pg:dbname=foo',
            username => 'myusername',
            password => 'mypassword',
            options  => { 'pg_enable_utf8' => 1, AutoCommit => 0 },
            helper   => 'db',
            });
    }

=head1 CONFIGURATION

The only required option is the 'dsn' one, which should contain a valid DBI dsn to connect to your database of choice.

=head1 METHODS/HELPERS

A helper is created with a name you specified (or 'db' by default) that can be used to get the active DBI connection. 


=head1 AUTHOR

Ben van Staveren, C<< <madcat at cpan.org> >>

=head1 BUGS/CONTRIBUTING

Please report any bugs or feature requests to through the web interface at L<https://github.com/benvanstaveren/mojolicious-plugin-database/issues>.
If you want to contribute changes or otherwise involve yourself in development, feel free to fork the Git repository from L<https://github.com/benvanstaveren/mojolicious-plugin-database/>.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::Database


You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-Database>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-Database>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-Database/>

=back

=head1 ACKNOWLEDGEMENTS

Based on a small example by sri and his request if someone could please write a plugin for this stuff.

alabamapaul (github) for fixing the tests to work on Windows

=head1 LICENSE AND COPYRIGHT

Copyright 2011, 2012 Ben van Staveren.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
