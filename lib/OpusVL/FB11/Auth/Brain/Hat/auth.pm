package OpusVL::FB11::Auth::Brain::Hat::auth;
# ABSTRACT: Provides auth via the FB11AuthDB
# DEBT: is a hack to make TokenProcessor work, but a hack in the right
# direction, I hope

our $VERSION = '1';

use Moose;
with 'OpusVL::FB11::Role::Hat';

sub user {
    my $self = shift;
    my $id = shift;

    return $self->__brain->schema->resultset('User')->find($id);
}

1;
