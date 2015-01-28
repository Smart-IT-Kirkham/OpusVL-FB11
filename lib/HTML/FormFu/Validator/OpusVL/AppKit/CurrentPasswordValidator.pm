package HTML::FormFu::Validator::OpusVL::FB11::CurrentPasswordValidator;

use strict;
use warnings;

use base 'HTML::FormFu::Validator';

sub validate_value {
    my ( $self, $value, $params ) = @_;

    my $c = $self->form->stash->{context};

    return 1 if($c->authenticate({ username => $c->user->username, password => $value }));

    die HTML::FormFu::Exception::Validator->new({
            message => 'Invalid password',
        });
}

1;
