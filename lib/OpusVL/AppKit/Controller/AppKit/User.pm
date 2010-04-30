package OpusVL::AppKit::Controller::AppKit::User;

use Moose;
use namespace::autoclean;

BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }
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
{
    my ($self, $c ) = @_;

    if ( $c->stash->{form}->submitted_and_valid )
    {   
        $c->user->update( { password => $c->req->params->{'password'} } );
        $c->stash->{status_msg} = "Your password was updated.";
    }
}

1;
__END__
