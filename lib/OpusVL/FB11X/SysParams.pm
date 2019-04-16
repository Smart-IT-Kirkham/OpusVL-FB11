package OpusVL::FB11X::SysParams;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '0.043';
# ABSTRACT: UI Module for setting the SysParams.

=head1 DESCRIPTION

If you want to use system parameters you can get a UI to edit them all by
including this FB11X component.

Alternatively, you can use the code here to see how one might create a UI
specific to one's own component. Look at
L<OpusVL::FB11X::SysParams::Controller::SysParams>, and instead of using
C<for_all_components>, simply use C<for_component('your_component_name')>.

We may in future create a controller that can be parameterised to do this for
you

=cut

after 'setup_components' => sub {
    my $class = shift;
    $class->add_paths(__PACKAGE__);

    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::SysParams::Controller::SysParams',
        as        => 'Controller::SysParams',
    );
};

1;

