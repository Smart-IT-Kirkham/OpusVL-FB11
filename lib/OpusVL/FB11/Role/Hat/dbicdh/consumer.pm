package OpusVL::FB11::Role::Hat::dbicdh::consumer;

# ABSTRACT: Wear one of these hats to be auto-deployed by DH
our $VERSION = '0';

use v5.24;
use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

=head1 DESCRIPTION

If you add the DH manager brain into your Hive it will, on initialisation, look
for brains wearing one of these hats. For each one discovered, it will deploy
its schema by means of L<OpusVL::FB11::DeploymentHandler>.

In fact, it will look for anything that says it wears a C<dbicdh::consumer> hat,
which I<should> implement this role, but, this being Perl, doesn't have to.

=head1 REQUIRED METHODS

=head2 schema

Returns a I<connected> schema. The schema must implement C<schema_version>.

=head1 OPTIONAL METHODS

=head2 priority

This defaults to 10, but you can increase this number to increase your niceness.

The value 0 is reserved for the core L<OpusVL::FB11::Schema::FB11AuthDB> schema,
which I<must> be installed before everything else.

(If you don't have the Auth DB in your Hive, your deployment will fail.)

=head2 start_at

Sometimes we accidentally break version 1 of a schema, so we end up with the
first deployment being not-1. In most cases we end up fixing it up so we can
assume it starts at 1, but sometimes we haven't got round to it yet.

Override this method to change which version we deploy.

We always upgrade to the current version according to C<schema_version>.

=cut

requires 'schema';

sub priority {10}
sub start_at {1}

1;
