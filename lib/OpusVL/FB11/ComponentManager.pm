package OpusVL::FB11::ComponentManager;

# ABSTRACT: Marshals different parts of FB11 so they can communicate

=head1 DESCRIPTION

This is a fledgling attempt at making FB11 a better component-based
architecture. The way it works is to stuff everything in a big hash.

Each component has core behaviour called the brain, which holds the business
logic for that component. The component would then probably also provide an
FB11X suite of modules that would be the web UI into the brain; but with the
proper architecture, we may end up being able to merge behaviour into core pages
thanks to FormHandler.

To register your brain with this module, simply use the L<Brain
Role|OpusVL::FB11::Role::Brain> in whatever class in your component is going to
be responsible for stuff. By adding the appropriate FB11X component into your
Catalyst application, this will then be constructed and, thus, registered
automatically.

=head2 Future development

Our FB11 applications are usually scripted by just using the Catalyst
application, waiting for it to compile, and then grabbing the model out of it.
This has the benefit of automatically doing everything that is already done
automatically. It has the drawback of requiring you to compile the Catalyst
application when all you want is the business logic.

We would want to develop this further to make it easier to pull together all the
brains without having to go via Catalyst in the first place.

=cut

my %components;

=head1 CLASS METHODS

=head2 register_component

Call this to register a brain. Currently, we take the C<short_name> of the brain
and register it against that. The service architecture can come later.

=cut

sub register_component {
    my $class = shift;
    my $component = shift;

    $components{$component->short_name} = $component;
}

sub user_data_for_component {
    my $class = shift;
    my $component = shift;
    my $user = shift;

    $components{$component}->get_user_data($user);
}

1;
