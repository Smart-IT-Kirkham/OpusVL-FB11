package OpusVL::FB11X::Parameters::Controller::Parameters;

use Moose;
use namespace::autoclean;
use v5.24;

BEGIN { extends "Catalyst::Controller" };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name          => "Object Parameters",
    fb11_icon          => '/static/images/audit-icon-small.png',
    fb11_myclass       => 'OpusVL::FB11X::Parameters',  
    fb11_shared_module => 'Admin',
    fb11_method_group  => 'Configuration',
);


sub index
    :Path
    :Args(0)
    :NavigationName('Object Parameters')
    :FB11Feature('Object Parameters')
{
}


1;
