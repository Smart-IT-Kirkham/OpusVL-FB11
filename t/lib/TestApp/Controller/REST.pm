package TestApp::Controller::REST;

use 5.010;
use Moose;
use Data::Dumper;
use Try::Tiny;

BEGIN {
    extends 'Catalyst::Controller::REST';
    with 'OpusVL::FB11::RolesFor::Controller::GUI';
}

__PACKAGE__->config(
    fb11_name               => 'Vehicles',
    fb11_shared_module      => 'Vehicle',
    fb11_myclass            => 'Cygnus::FB11X::Vehicle',
    fb11_method_group       => 'Manage vehicles',
);

sub vehicle
    : Local
    : ActionClass('REST')
    : Args(1) 
    : FB11Feature('Raise VMA')
{ }

sub vehicle_GET
    : FB11Feature('Raise VMA')
{
    my ($self, $c, $id) = @_;

    unless($id > 10)
    {
        $self->status_not_found($c, message => 'Vehicle not found');
        $c->detach;
    }
    $self->status_ok(
        $c,
        entity => {
            stock_id => $id,
            source_code => 'Test',
        },
    );
}

sub no_permission
    : Local
    : ActionClass('REST')
    : Args(1) 
    : FB11Feature('Feature Not allowed')
{ }

sub no_permission_GET
{
    my ($self, $c, $id) = @_;

    die 'This is just a test action to prove the permissions work, you shouldn\'t be able to run this code.';
}

1;

