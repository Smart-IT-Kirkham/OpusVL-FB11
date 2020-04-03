package OpusVL::FB11::Plugin::SetLoginTime;

our $VERSION = '2';

use Moose::Role;
use namespace::autoclean;
use DateTime;

requires 'set_authenticated';

after set_authenticated => sub {
    my ($self, $user) = @_;

    # TODO configure field name
    if ($user->has_column('last_login_time')) {
        $user->update({
            last_login_time => DateTime->now
        });
    }
};


1;

=head1 NAME

OpusVL::FB11::Plugin::SetLoginTime - automatically set login time

=head1 SYNOPSIS

    package MyApp::Builder;

    use Moose;
    extends 'OpusVL::FB11::Builder';
    override _build_plugins => sub {
        my $plugins = super();
        push @$plugins, qw/
            +OpusVL::FB11::Plugin::SetLoginTime
        /;
    };
    
=head1 DESCRIPTION

Works with L<Catalyst::Plugin::Authentication> or any plugin that provides a
C<set_authenticated> on the Catalyst object. When called, sets the
C<last_login_time> field on the user object to now.

The method is assumed to be called with the user object as the first parameter;
and it is expected to be a DBIC result object, or compatible.

=head1 TODO

=over

=item Configure the field name

=back
