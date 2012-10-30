package FakePlugin;

use Moose;
use FakeCache;
use FakeLog;
use Carp;
extends 'OpusVL::AppKit::Plugin::AppKit';

has debug => (isa => 'Bool', is => 'ro', default => '0');
has config => (isa => 'HashRef', is => 'ro', default => sub { {} } );
has cache => (is => 'ro', default => sub { FakeCache->new() } );
has components => (is => 'ro', isa => 'HashRef', default => sub { {} } );
has schema => (is => 'ro');

sub model
{
    my $self = shift;
    my $model = shift;
    my ($rs_name) = $model =~ /\:\:(.*)$/;
    my $rs = $self->schema($rs_name);
    croak "Unable to find model $model" unless $rs;
    return $rs;
}

has log => (is => 'ro', default => sub { FakeLog->new() } );


1;
