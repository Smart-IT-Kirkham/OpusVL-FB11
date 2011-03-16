package OpusVL::AppKit::Controller::AppKit::User;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; };
with 'OpusVL::AppKit::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    appkit_myclass              => 'OpusVL::AppKit',
);

=head2 change_password

=cut

sub change_password
    : Path('changepword')
    : Args(0)
    : AppKitForm("appkit/user/change_password.yml")
    : AppKitFeature('Password Change')
{
    my ($self, $c ) = @_;

    if ( $c->stash->{form}->submitted_and_valid )
    {   
        $c->user->update( { password => $c->req->params->{'password'} } );
        $c->stash->{hide_form} = 1;
    }
}
    
=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
