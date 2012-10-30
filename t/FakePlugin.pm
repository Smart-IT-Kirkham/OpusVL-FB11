package FakePlugin;

use Moose;
use FakeCache;
use FakeLog;
extends 'OpusVL::AppKit::Plugin::AppKit';

has debug => (isa => 'Bool', is => 'ro', default => '0');
has config => (isa => 'HashRef', is => 'ro', default => sub { {} } );
has cache => (is => 'ro', default => sub { FakeCache->new() } );
has components => (is => 'ro', isa => 'HashRef', default => sub { {} } );

has log => (is => 'ro', default => sub { FakeLog->new() } );


1;
