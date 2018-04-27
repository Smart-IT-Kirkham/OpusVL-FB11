package OpusVL::FB11X::Preferences::Controller::Preferences;

use Moose;
use namespace::autoclean;
use v5.24;

BEGIN { extends "Catalyst::Controller" };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name          => "Object Preferences",
    fb11_icon          => '/static/images/audit-icon-small.png',
    fb11_myclass       => 'OpusVL::FB11X::Preferences',  
    fb11_shared_module => 'Admin',
    fb11_method_group  => 'Configuration',
);


sub index
    :Path
    :Args(0)
    :NavigationName('Object Preferences')
    :FB11Feature('Object Preferences')
{
}


1;
