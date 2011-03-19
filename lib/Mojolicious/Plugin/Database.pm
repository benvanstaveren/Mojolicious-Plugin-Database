package Mojolicious::Plugin::Database;

use Mojo::Base 'Mojolicious::Plugin';
use version;
use DBI;

our $VERSION = qv(0.01);

has 'dbh';

sub register {
    my $self = shift;
    my $app  = shift;
    my $conf = shift || {};

    die ref($self), ': missing dsn parameter', "\n" unless($conf->{dsn});

    $self->dbh(DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{options}));

    die ref($self), ': failed to connect to database: ', $DBI::errstr, "\n" unless($self->dbh); 

    my $helper_name = $conf->{helper} || 'db';

    $app->helper($helper_name => sub { $self->dbh } );
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Database - "proper" handling of DBI based connections in Mojolicious

=head1 VERSION

Version 0.01

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

The only required option is the 'dsn' one, which should contain a valid DBI dsn to connect to your database of choice. The actual connection is made when the plugin is registered. 

=head1 METHODS/HELPERS

A helper is created with a name you specified (or 'db' by default) that can be used to get the active DBI connection. 

=head1 AUTHOR

Ben van Staveren, C<< <madcat at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojolicious-plugin-database at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-Database>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::Database


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-Database>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-Database>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-Database>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-Database/>

=back

=head1 ACKNOWLEDGEMENTS

Based on a small example by sri and his request if someone could please write a plugin for this stuff.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Ben van Staveren.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
