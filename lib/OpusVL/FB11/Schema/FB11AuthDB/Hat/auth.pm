package OpusVL::FB11::Schema::FB11AuthDB::Hat::auth;

# ABSTRACT: Provides auth via the FB11AuthDB
# DEBT: is a hack to make TokenProcessor work, but a hack in the right
# direction, I hope

use Moose;
with 'OpusVL::FB11::Role::Hat';

sub user {
    my $self = shift;
    my $id = shift;

    return $self->__brain->resultset('User')->find($id);
}

1;
