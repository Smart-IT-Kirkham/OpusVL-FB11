package OpusVL::FB11::Role::Hat::sysparams;

use Moose::Role;
with "OpusVL::FB11::Role::Hat";

# ABSTRACT: Defines a sysparams hat.

=head1 DESCRIPTION

A sysparams hat is actually a proxy because different components might have
their sysparams stored differently. The core behaviour for sysparams is that
each parameter will be stored the same but namespaced by the component's
friendly name. This architecture allows us to support different storage or
legacy data that doesn't have any namespacing in it.

The current implementation of sysparams is in L<OpusVL::SysParams>, which is
bundled with FB11, so you should be able to just use that as your brain and
access the services that way.

=cut

requires qw/for_component for_all_components/;


1;
