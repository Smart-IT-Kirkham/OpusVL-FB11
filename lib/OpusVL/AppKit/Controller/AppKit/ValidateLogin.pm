package OpusVL::AppKit::Controller::AppKit::ValidateLogin;

use Moose;
use namespace::autoclean;

BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }
__PACKAGE__->config->{appkit_myclass} = 'OpusVL::AppKit';

=head2 validation_check
    Checks the logged in user to see if they need validation.
    If they do this handles the storing of values and the redirection.
=cut
sub validation_check
{
    my ($self, $c) = @_;

    if ( $c->controller eq $c->controller('AppKit::ValidateLogin') )
    {
        $c->log->debug(" Logged in user " . $c->user->username  . " currently using the Login Validator" );
        # ensure the flash key we stored remains until we need it..
        $c->keep_flash ( 'validation_request_path' );
    }
    else
    {
        # does the logged in user require validation?...if so, of what type?
        my $validation_method = 0;
        foreach ( keys %{ $c->user->params_hash } )
        {
            if ( $_ =~ m/^Login Validation via (.+?)$/ )
            {
                $validation_method = $1;
            }
        }

        # check to see if the validation has already been done...
        if ( $validation_method && $c->session->{'validated_' . $validation_method } )
        {
            $c->log->debug("User " . $c->user->username . " logged in and validated");
        }
        elsif ( $validation_method )
        {
            $c->log->debug("Sending user " . $c->user->username . " to be validated via $validation_method");

            $c->flash->{validation_request_path} = $c->req->base . $c->req->path;

            $c->res->redirect( $c->uri_for( $c->controller('AppKit::ValidateLogin')->action_for( 'validate'), $validation_method ) ) ;
            $c->detach();
        }
        else
        {
            $c->log->debug("User " . $c->user->username . " requires no validation");
        }
    }
}

=head2 post_validation_redirect
=cut
sub post_validation_redirect
{
    my ($self, $c, $validator) = @_;

    $c->log->debug("Post Validation ($validator) redirecting to " . $c->flash->{validation_request_path} );

    $c->session->{'validated_' . $validator }  = 1;
    $c->res->redirect(  $c->flash->{validation_request_path} ) ;
    $c->detach();
}

=head2 validate
    Run the validation.
=cut
sub validate
    : Path('')
    : Args(1)
{
    my ( $self, $c, $validator ) = @_;

    my $class               = $c->loaded_validators->{$validator};
    my $validator_object    = $class->new;

    # build the formfu (we have used the FormFu controller in the Base Class controller)...
    my $form = $self->form;
    $form->populate( $validator_object->formfu );
    $form->process();
    $c->stash->{form} = $form;

    if ( $c->stash->{form}->submitted_and_valid )
    {
        if ( $validator_object->validate( $c ) )
        {
            $validator_object->post_validate( $c );
            $self->post_validation_redirect( $c, $validator );
        }
        else
        {
            $c->stash->{error_msg} = "Sorry, your validation data was incorrect";
        }
    }
    elsif ( $c->stash->{form}->submitted )
    {
        # do nothing.. formfu should report any problems..
    }
    else
    {
        $validator_object->pre_validate ( $c );
    }

    $c->stash->{template} = "appkit/validatelogin/validation_form.tt";
}

1;
__END__
