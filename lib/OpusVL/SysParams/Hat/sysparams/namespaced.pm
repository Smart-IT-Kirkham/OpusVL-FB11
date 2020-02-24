package OpusVL::SysParams::Hat::sysparams::namespaced;

our $VERSION = '1';

# ABSTRACT: Uses the component name as a namespace for parameters

use Moose;
with 'OpusVL::FB11::Role::Hat::sysparams';

use OpusVL::SysParams::Reader;

sub for_component {
    OpusVL::SysParams::Reader->new({
        manager => OpusVL::SysParams::Manager::Namespaced->new({
            namespace => $_[1],
            schema => $_[0]->__brain->schema,
            __brain => $_[0]->__brain
        })
    });
}

sub for_all_components {
    OpusVL::SysParams::Reader->new({
        manager => OpusVL::SysParams::Manager::Namespaced->new({
            schema => $_[0]->__brain->schema,
            __brain => $_[0]->__brain
        })
    });
}

1;

=head1 DESCRIPTION

Wear this hat to provide sysparams using the namespacing concept. This is the
one where all the params are in the same table and we use C<::> in the param
name to namespace them.

=head1 SYNOPSIS

    sub hats { qw/sysparams/ }
    sub provided_services {
        sysparams => {
            class => 'sysparams::namespaced'
        }
    }
