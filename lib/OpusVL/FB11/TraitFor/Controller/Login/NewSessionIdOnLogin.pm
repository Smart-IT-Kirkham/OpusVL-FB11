package OpusVL::FB11::TraitFor::Controller::Login::NewSessionIdOnLogin;

our $VERSION = '1';

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

requires qw/
    login
    login_form_stash_key
/;

after 'login' => sub {
    my ( $self, $ctx ) = @_;

    $ctx->change_session_id;
};

1;

=head1 NAME

OpusVL::FB11::TraitFor::Controller::Login::NewSessionIdOnLogin

=head1 DESCRIPTION

Simple controller role to generate a new session id when the user
logs in.  Actually it's a little blunter than that, it forces a new
one to be generated every time the login page is visited.  That's
not a problem, even if it is a little pointless.  It's just this
is the simplest place to hook in the functionality.

=head1 METHODS

=head2 after 'login'

    $ctx->change_session_id;

=head1 SEE ALSO

=over

=item L<CatalystX::SimpleLogin::ControllerRole::Login>

=back

=head1 COPYRIGHT and LICENSE

Copyright (C) 2012 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


=cut

