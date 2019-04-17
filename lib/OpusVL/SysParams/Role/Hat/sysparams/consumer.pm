package OpusVL::SysParams::Role::Hat::sysparams::consumer;

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

requires 'parameter_spec';
sub namespace {}

1;
