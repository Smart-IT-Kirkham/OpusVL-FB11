package TestX::CatalystX::ExtensionA::Controller::ExtensionA;

use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name                 => 'ExtensionA',
    fb11_icon                 => 'static/images/flagA.jpg',
    fb11_myclass              => 'TestX::CatalystX::ExtensionA',
    fb11_method_group         => 'Extension A',
    fb11_method_group_order   => 2,
    fb11_shared_module        => 'ExtensionA',
);

sub home
    :Path
    :Args(0)
    :NavigationHome
    :FB11Feature('Extension A')
#    :FB11RolesAllowed('Administrator')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'extensiona.tt';
}

sub table
    : Local
    : Args(0)
    : NavigationName('Table test')
    : FB11Feature('Extension A')
{
    my ($self, $c) = @_;
}

__END__
