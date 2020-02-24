package OpusVL::FB11::Hat::fb11::simple_app;

# ABSTRACT: A Hat for a simple FB11 app
our $VERSION = '1';

use Moose;
use Module::Runtime qw/use_module/;

with 'OpusVL::FB11::Role::Hat::fb11::app';

=head1 DESCRIPTION

You can use this hat to implement the L<fb11::app> service. We'll try to keep
C<auth_feature_list> up to date so that it returns whatever we end up deciding
it should return.

=head1 SYNOPSIS

    package MyBrain;

    ...

    sub provided_services {
        'fb11::app' => {
            class => '+OpusVL::FB11::Role::Hat::fb11::app',
            constructor => {
                appname => 'MyApp'
            }
        }
    }

=cut

has appname => (
    is => 'ro',
    required => 1,
);

sub psgi {
    my $self = shift;
    my $appname = $self->appname;

    use_module $appname;
    $appname->apply_default_middlewares($appname->psgi_app);
}

sub auth_feature_list {
    my $self = shift;
    use_module($self->appname)->fb11_features->feature_list;
}

1;
