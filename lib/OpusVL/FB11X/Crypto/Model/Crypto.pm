package OpusVL::FB11X::Crypto::Model::Crypto;

our $VERSION = '1';

use Moose;
use OpusVL::FB11::Hive;
extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'OpusVL::SimpleCrypto' );

has short_name => (
    is => 'ro',
    default => 'simplecrypto',
    lazy => 1,
);

around COMPONENT => sub {
    my $orig = shift;
    my $self = shift;

    my $instance = $self->$orig(@_);

    OpusVL::FB11::Hive->register_brain($instance);

    return $instance;
};

with 'OpusVL::FB11::Role::Brain';

sub hats {
    qw/crypto/
}

sub provided_services {
    qw/crypto/
}

package OpusVL::FB11X::Crypto::Model::Crypto::Hat::crypto;

use Moose;
with 'OpusVL::FB11::Role::Hat::crypto';

sub encrypt { shift->__brain->encrypt(@_) }
sub encrypt_deterministic { shift->__brain->encrypt_deterministic(@_) }
sub decrypt { shift->__brain->decrypt(@_) }

1;
