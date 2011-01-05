package OpusVL::AppKit::Form::Login;

use strict;
use warnings;
use Moose;

use CatalystX::SimpleLogin::Form::Login;
extends 'CatalystX::SimpleLogin::Form::Login';

override 'validate' => sub 
{
    my $self = shift;

    my %values = %{$self->values}; # copy the values
    $DB::single = 1;
    my $rs = $self->ctx->model('AppKitAuthDB::User')->search(
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

