package OpusVL::FB11::Role::Hat::dbicdh::manager;

# ABSTRACT: A hat for a brain that manages DH schemata
our $VERSION = '0';
use Moose::Role;

with 'OpusVL::FB11::Role::Hat';

=head1 DESCRIPTION

Hats of this type are worn to declare a service that will manage schemata that
implement DeploymentHandler. The counterpart is
L<OpusVL::FB11::Role::Hat::dbicdh::consumer>.

It should be safe to deploy all schemas at the C<hive_init> stage of Hive
initialisation. A Brain may use this hook to find this service and run
L</deploy_and_upgrade>.

=head1 REQUIRED METHODS

=head2 deploy_and_upgrade

This method must find all C<dbicdh::consumer> hats and deploy and upgrade the
schemas in them.

There seems to be only really one way to do this, but we avoid making that
assumption in this role.

=cut

requires 'deploy_and_upgrade';
1;
