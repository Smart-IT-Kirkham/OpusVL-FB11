package OpusVL::FB11::Role::Hat::augments_object;

use Moose::Role;
use Scalar::Util qw/refaddr/;
with "OpusVL::FB11::Role::Hat";

# ABSTRACT: Tells other components that this one may augment an object

our $VERSION = '1';

my %cache;

requires 'augment';

around augment => sub {
    my $orig = shift;
    my $self = shift;
    my $obj = shift;

    my $aug = $self->$orig($obj);

    $self->cache($obj, $aug) if $aug;

    return $aug;
};

sub cache {
    my $self = shift;
    my $obj = shift;
    my $aug = shift;

    die ref $self . " must override the cache method"
        if not ref $aug;

    $cache{refaddr $aug} = $obj;
}

sub get_original {
    my $self = shift;
    my $aug = shift;

    die ref $self . " must override the get_original method"
        if not ref $aug;

    return $cache{refaddr $aug};
}

1;

=head1 DESCRIPTION

In most cases, wearers of this hat will be requested directly.

    OpusVL::FB11::Hive->hat('component', 'augments_object');

This is because you can only make use of augmented data if you know the
interface of the augmented data. That means you need to know which component is
augmenting it.

There may be some cases where a generic comprehension of all augmented data
makes sense, so this being a Hat enables that.

=head1 METHODS

=head2 augment

B<Arguments>: C<$arbitrary_data>

B<Returns>: C<$augmented_data>

Returns augmented data for a given object. This interface makes no promises or
prescriptions about how that should work. In particular, individual
implementations are free to:

=over

=item Return anything as C<$augmented_data>

=item Return nothing at all

=item Break the interface of the input object

=item Return a wrapped version of the input object

=item Die

=back

=head2 cache

B<Arguments>: C<$original_data>, C<$augmented_data>

Caches the response from C<augment> against the C<refaddr> of C<$original_data>.

B<Wrap this method> if your implementation I<returns> non-refs from C<augment>,
since refaddr will be undef.

=head2 get_original

B<Arguments>: C<$augmented_data>

B<Returns>: C<$original_object>

Tries to find the data this augmented object came from and returns it.

B<Wrap this method> if your implementation creates non-refs, because it's then
up to you to cache it.
