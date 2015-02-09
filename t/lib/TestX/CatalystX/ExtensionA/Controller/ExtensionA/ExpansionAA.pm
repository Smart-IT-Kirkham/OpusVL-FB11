package TestX::CatalystX::ExtensionA::Controller::ExtensionA::ExpansionAA;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name                 => 'ExtensionA',
    fb11_order                => 10,
    fb11_icon                 => 'static/images/flagA.jpg',
    fb11_myclass              => 'TestX::CatalystX::ExtensionA::ExpansionAA',
    fb11_method_group         => 'Extension A sub controller',
    fb11_method_group_order   => 1,
    fb11_shared_module        => 'ExtensionA',
);

sub home
    :Path
    :Args(0)
    :NavigationName('Expanded Action')
    :FB11Feature('Extension A')
    :NavigationOrder(1)
#    :FB11RolesAllowed('Administrator')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'extensiona.tt';
    $c->stash->{custom_string} = 'The is the home action from the ExpansionAA subcontroler in ExtensionA';
}

sub startchain
    :Chained('/')
    :PathPart('start')
    :CaptureArgs(0)
    :FB11Feature('Extension A')
#    :FB11RolesAllowed('Administrator')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'extensiona.tt';
    $c->stash->{custom_string} = 'Start Chained actions...';
}
sub midchain
    :Chained('startchain')
    :PathPart('mid')
    :CaptureArgs(0)
#    :FB11RolesAllowed('Administrator')
    :FB11Feature('Extension A')
{
    my ($self, $c) = @_;
    $c->stash->{custom_string} .= 'Middle of Chained actions...';
}
sub endchain
    :Chained('midchain')
    :PathPart('end')
    :Args(0)
    :NavigationName('Expanded Chained Action')
    :NavigationOrder(2)
    :FB11Feature('Extension A')
#    :FB11RolesAllowed('Administrator')
{
    my ($self, $c) = @_;
    $c->stash->{custom_string} .= 'End of Chained actions.';
}

1;
__END__
