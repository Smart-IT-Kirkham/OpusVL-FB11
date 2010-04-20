package OpusVL::AppKit::LoginValidator;

use Moose;

has formfu  => ( is => 'rw',    isa => 'HashRef', lazy_build => 1 );
sub _build_formfu
{
    my $self    = shift;
    return {};
}

sub validate
{
    my $self    = shift;
    my ($c)     = @_;
};

sub pre_validate
{
    my $self    = shift;
    my ($c)     = @_;
}
sub post_validate
{
    my $self    = shift;
    my ($c)     = @_;
}

1;
__END__
