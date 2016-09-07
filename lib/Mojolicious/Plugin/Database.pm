package Mojolicious::Plugin::Database;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '1.11';

use DBI;

sub single {
  my ($self, $app, $conf) = @_;

  die ref($self) . ": missing dsn parameter\n" unless $conf->{dsn};

  my $helper = $conf->{helper} || 'db';
  my $attr_name = '_dbh_' . $helper;
  $attr_name =~ s/\./_/g;

  $app->attr($attr_name => sub {
    my $dbh = DBI->connect($conf->{dsn}, $conf->{username}, $conf->{password}, $conf->{options});
    $conf->{on_connect}($dbh) if $conf->{on_connect};
    return $dbh;
  });

  $app->helper($helper => sub { shift->app->$attr_name });
}

sub register {
  my ($self, $app, $conf) = @_;

  if (defined($conf->{databases})) {
    die ref($self) . ": databases is not a hash reference\n" unless ref $conf->{databases} eq 'HASH';
    for (keys %{$conf->{databases}}) {
      $conf->{databases}->{$_}->{helper} = $_;
      $self->single($app, $conf->{databases}->{$_});
    }
  }
  else {
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
            dsn      => 'dbi:Pg:dbname=foo',
            username => 'myusername',
            password => 'mypassword',
            options  => { 'pg_enable_utf8' => 1, AutoCommit => 0 },
            helper   => 'db',
            });

        # or if you require multiple databases at the same time
        $self->plugin('database', {
            databases => {
                'db1' => {
                    dsn      => 'dbi:Pg:dbname=foo',
                    username => 'myusername',
                    password => 'mypassword',
                },
                'db2' => {
                    dsn      => 'dbi:MySQL:dbname=bar',
                    username => 'othername',
                    password => 'otherpassword',
                },
            },
        });
    }

=head1 CONFIGURATION

=head2 CONNECTING TO A SINGLE DATABASE

When connecting to a single database, the following configuration options are recognised:

=over 4

=item 'dsn'         should contain the DSN string required by DBI

=item 'username'    the username that should be used to authenticate

=item 'password'    the password that should be used to authenticate

=item 'options'     options to pass to the DBD driver

=item 'helper'      the name of the helper to associate with this database (default: db)

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
