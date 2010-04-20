package OpusVL::AppKit::Controller::AppKit::ValidateLogin;

use Moose;
use namespace::autoclean;

BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }
__PACKAGE__->config
(
    appkit_myclass              => 'OpusVL::AppKit',
);

=head2 sms
=cut
sub sms
    : Local
    : Args(0)
    : AppKitForm("appkit/validatelogin/sms.yml")
{
    my ( $self, $c ) = @_;

    if ( $c->stash->{form}->submitted_and_valid )
    { 

    }

    $c->session->{validated_sms} = 1; # for testing..

    $c->stash->{template} = "appkit/validatelogin/validation_form.tt";

}

1;
__END__
