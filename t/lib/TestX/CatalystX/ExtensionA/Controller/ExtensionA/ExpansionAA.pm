package TestX::CatalystX::ExtensionA::Controller::ExtensionA::ExpansionAA;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::AppKit::RolesFor::Controller::GUI';

sub home
    :Path
    :Args(0)
    :NavigationName('Expanded Action')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'extensiona.tt';
    $c->stash->{custom_string} = 'The is the home action from the ExpansionAA subcontroler in ExtensionA';
}

sub startchain
    :Chained('/')
    :PathPart('start')
    :CaptureArgs(0)
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'extensiona.tt';
    $c->stash->{custom_string} = 'Start Chained actions...';
}
sub midchain
    :Chained('startchain')
    :PathPart('mid')
    :CaptureArgs(0)
{
    my ($self, $c) = @_;
    $c->stash->{custom_string} .= 'Middle of Chained actions...';
}
sub endchain
    :Chained('midchain')
    :PathPart('end')
    :Args(0)
    :NavigationName('Expanded Chained Action')
{
    my ($self, $c) = @_;
    $c->stash->{custom_string} .= 'End of Chained actions.';
}

1;
__END__
