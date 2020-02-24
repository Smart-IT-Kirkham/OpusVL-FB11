package OpusVL::FB11X::CustomParams;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '1';
# ABSTRACT: UI Module for defining ObjectParams schemata.

=head1 DESCRIPTION

ObjectParams is designed to allow developers to extend objects with their own data and later retrieve it.

CustomParams extends this behaviour by allowing arbitrary data to be collected
on behalf of the end user of the system. CustomParams data can only ever be read
by looking at the record page for the objects in question, until we create a
reporting module that can read CustomParams.

=cut

after 'setup_components' => sub {
    my $class = shift;
    $class->add_paths(__PACKAGE__);

    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::CustomParams::Controller::CustomParams',
        as        => 'Controller::CustomParams',
    );
};

1;

