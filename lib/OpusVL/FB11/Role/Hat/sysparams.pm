package OpusVL::FB11::Role::Hat::sysparams;

use Moose::Role;
with "OpusVL::FB11::Role::Hat";

# ABSTRACT: Defines a sysparams hat.

our $VERSION = '2';

=head1 DESCRIPTION

The core behaviour for sysparams is that each parameter will be stored the same
way (i.e. all in the same table), but namespaced by the component's friendly
name.

We use the hat to take in your component name and return an object that
understands the namespace idea.

The current implementation of sysparams is in L<OpusVL::SysParams>, which is
bundled with FB11, so you should be able to just use that as your brain and
access the services that way.

=cut

requires qw/for_component for_all_components/;


1;
