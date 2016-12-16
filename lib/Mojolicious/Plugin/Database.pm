use strict;
use warnings;
package Mojolicious::Plugin::Database;

use Mojo::Base 'Mojolicious::Plugin';
use DBI;

sub single {
    my $self = shift;
    my $app  = shift;
    my $conf = shift;

    die ref($self), ': missing dsn parameter', "\n" unless($conf->{dsn});



    my $dbh_connect = sub {
      my $dbh = DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{options});
      $conf->{on_connect}($dbh) if $conf->{on_connect};
      return $dbh;
    };

    my $helper_name = $conf->{helper} || 'db';

    $app->attr("_dbh_$helper_name" => $dbh_connect);
    $app->attr("_dbh_check_connection_threshold_$helper_name" => $conf->{connection_check_threshold} || 30 );
    $app->attr("_dbh_connection_last_check_$helper_name" => time );

    $app->helper($helper_name => sub {
        my $self = shift;
        my $attr = "_dbh_$helper_name";
        my $last_check_attr = "_dbh_connection_last_check_$helper_name";
        my $threshold_check_attr = "_dbh_check_connection_threshold_$helper_name";
        my $dbh = $self->app->$attr();

        if( time - $self->app->$last_check_attr() > $self->app->$threshold_check_attr() ) {
            $self->app->$last_check_attr( time );
            unless( $dbh->ping ) {
                $dbh = $dbh_connect->();
                $self->app->$attr($dbh);
            }
        }
        return $dbh;
    });
}

sub multi {
    my $self = shift;
    my $app  = shift;
    my $conf = shift;

    # databases should be a hashref
    die ref($self), ': databases is not a hash reference', "\n" unless(ref($conf->{databases}) eq 'HASH');

    foreach my $helper (keys(%{$conf->{databases}})) {
        my $dbconf = $conf->{databases}->{$helper};
        die ref($self), ': missing dsn parameter for ' . $helper, "\n" unless(defined($dbconf->{dsn}));
        my $attr_name = '_dbh_' . $helper;
        my $last_check_attr_name = "_dbh_connection_last_check_$helper";
        my $threshold_check_attr_name = "_dbh_check_connection_threshold_$helper";
        my $default = sub {
            my $dbh = DBI->connect($dbconf->{dsn}, $dbconf->{username}, $dbconf->{password}, $dbconf->{options});
            $dbconf->{on_connect}($dbh) if $dbconf->{on_connect};
            return $dbh;
        };
        $app->attr($attr_name => $default );
        $app->attr( $threshold_check_attr_name => $dbconf->{connection_check_threshold} || 30 );
        $app->attr( $last_check_attr_name => time );
        $app->helper(
            $helper => sub {
                my $self = shift;
                my $dbh = $self->app->$attr_name();

                if( time - $self->app->$last_check_attr_name() > $self->app->$threshold_check_attr_name() ) {
                    $self->app->$last_check_attr_name( time );
                    unless( $dbh->ping ) {
                        $dbh = $default->();
                        $self->app->$attr_name( $dbh );
                    }
                }
                return $dbh;
            }
        );
    }
}

sub register {
    my $self = shift;
    my $app  = shift;
    my $conf = shift || {};

    if(defined($conf->{databases})) {
        $self->multi($app, $conf);
    } else {
        # old-style connect
        $self->single($app, $conf);
    }
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
            dsn                        => 'dbi:Pg:dbname=foo',
            username                   => 'myusername',
            password                   => 'mypassword',
            options                    => { 'pg_enable_utf8'   => 1, AutoCommit => 0 },
            helper                     => 'db',
            connection_check_threshold => 10,
            });

        # or if you require multiple databases at the same time
        $self->plugin('database', {
            databases => {
                'db1' => {
                    dsn                        => 'dbi:Pg:dbname=foo',
                    username                   => 'myusername',
                    password                   => 'mypassword',
                    connection_check_threshold => 10,
                },
                'db2' => {
                    dsn                        => 'dbi:MySQL:dbname=bar',
                    username                   => 'othername',
                    password                   => 'otherpassword',
                    connection_check_threshold => 10,
                },
            },
        });
    }

=head1 CONFIGURATION

=head2 CONNECTING TO A SINGLE DATABASE

When connecting to a single database, the following configuration options are recognised:

=over 4

=item 'dsn'                         should contain the DSN string required by DBI

=item 'username'                    the username that should be used to authenticate

=item 'password'                    the password that should be used to authenticate

=item 'options'                     options to pass to the DBD driver

=item 'helper'                      the name of the helper to associate with this database (default: db)

=item 'connection_check_threshold'  interval in seconds at which state of the connection will be checked, to reconnect if needed ( default: 30 seconds )

=back

The only required option is 'dsn', every other option is optional.

=head2 CONNECTING TO MULTIPLE DATABASES

When you have the need to connect to multiple databases (or different RDBMS types), the following options are recognised:

=over 4

=item 'databases'   A hash reference whose key is the helper name, and the value is another hash reference containing connection options.

=back

=head1 METHODS/HELPERS

A helper is created with a name you specified (or 'db' by default) that can be used to get the active DBI connection. When using multiple databases, you also get multiple helpers.

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

alabamapaul (github) for fixing the tests to work on Windows.

Babatope Aloba for pointing out it'd be really useful to be able to connect to multiple databases at once.

=head1 LICENSE AND COPYRIGHT

Copyright 2011-2015 Ben van Staveren.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
