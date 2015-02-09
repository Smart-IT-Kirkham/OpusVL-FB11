package OpusVL::FB11::Form::Login;

use strict;
use warnings;
use Moose;
use HTML::FormHandler::Moose;

use CatalystX::SimpleLogin::Form::Login;
extends 'CatalystX::SimpleLogin::Form::Login';

has '+widget_wrapper' => ( default => 'Bootstrap3' );
has_field '+password' => ( element_attr => { class => 'off' } );

has_field 'submit'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => '<i class="fa fa-lock"></i> Login',
    element_attr => { class => ['btn', 'btn-primary'] }
);

override 'validate' => sub 
{
    my $self = shift;

    my %values = %{$self->values}; # copy the values
    my $rs = $self->ctx->model('FB11AuthDB::User')->search(
        \[
            'lower(username) = ?', [ dummy => lc ($self->values->{username}) ]
        ]
    );
    unless (
        $self->ctx->authenticate(
            {
                password => $self->values->{password},
                dbix_class => {
                    resultset => $rs,
                }
            },
            ($self->has_authenticate_realm ? $self->authenticate_realm : ()),
        )
    ) {
        $self->add_auth_errors;
        return;
    }
    return 1;
};

1;

