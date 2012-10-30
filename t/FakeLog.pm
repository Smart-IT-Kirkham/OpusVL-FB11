package FakeLog;

use Test::More;
use Moose;

sub debug
{
    my $self = shift;
    my $message = shift;
    note $message;
}

sub warn
{
    my $self = shift;
    my $message = shift;
    diag $message;
}

1;
