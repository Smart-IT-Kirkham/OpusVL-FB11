package OpusVL::FB11::Hive::Config;

use v5.24;
use Module::Runtime 'use_package_optimistically';
use Safe::Isa;
use Scalar::IfDefined qw/lifdef/;
use Try::Tiny;

use failures qw/
    fb11::hive::config
/;

our $VERSION = '0.043';

# ABSTRACT: At least one function for configuring a hive

=head1 DESCRIPTION

Utility package for configuration methods. Intended to allow different configuration methods in the future.

Each function in this package is a Klingon function that can be passed to L<OpusVL::FB11::Hive/transform>.

=head1 FUNCTIONS

=head2 configure_hive

B<Arguments>: C<Hive $hive>, C<$config>

B<Returns>: C<Hive $new_hive>

See L</CONFIGURATION>.

Exceptions under the C<failure::fb11::hive> namespace will be collated. If any
such exceptions are caught, a new exception is thrown of type
C<failure::fb11::hive::config>, whose payload contains the C<config> hashref and
the array of C<errors> produced.

=cut

sub configure_hive {
    # Hive will be cloned for us by the mutator methods
    my $hive = shift;
    my $config = shift;

    my @problems;

    if ($config->{brains}) {
        for my $b_conf ($config->{brains}->@*) {
            try {
                $b_conf->{class} // failure::fb11::hive::config->throw({
                    msg => "Brain configured without class parameter",
                    payload => {
                        specific_config => $b_conf
                    }
                });

                use_package_optimistically($b_conf->{class});
                my $br = $b_conf->{class}->new(
                    +{
                        hive => $hive,
                        lifdef {%$_} $b_conf->{constructor}
                    }
                );
                $hive = $hive->with_brain_registered($br);
            }
            catch {
                if ($_->$_isa('failure::fb11::hive')) {
                    push @problems, $_
                }
                else {
                    die $_
                }
            }
        }
    }
    if ($config->{services}) {
        for my $s_name (keys $config->{services}->%*) {
            my $s_conf = $config->{services}->{$s_name};
            try {
                $hive = $hive->with_service_set($s_name, $s_conf->{brain});
            }
            catch {
                if ($_->$_isa('failure::fb11::hive')) {
                    push @problems, $_
                }
                else {
                    die $_
                }
            }
        }
    }

    if (@problems) {
        my $all_msgs = join "\n", map $_->msg, @problems;
        failure::fb11::hive::config->throw({
            msg => "Errors while configuring Hive!\n$all_msgs",
            payload => {
                config => $config,
                errors => \@problems
            }
        });
    }

    $hive;
}

=head1 CONFIGURATION

Configuration does some high-level checking for consistency but one can always
run L<OpusVL::FB11::Hive::Instance/check> on the hive to perform more thorough
checks. The user will also need to call
L<OpusVL::FB11::Hive::Instance/initialised> before the hive can be used, which
can also throw its own errors.

The hashref looks something like this:

    {
        brains => [
            {
                # This class will be instantiated and registered for you
                class => "OpusVL::FB11::Brain::SysParams",
                # This will be passed to the constructor
                constructor => {
                    ...
                }
        ],
        services => {
            sysparams => {
                # This is the short_name of the brain you want to provide this
                # service.
                brain => 'sysparams'
            }
        },
    }

=head2 Properties

=head3 brains

An array of brain configuration hashrefs. Each contains:

B<class>: The class name of the brain

B<constructor>: Hashref for the constructor of the brain.

It is assumed your brain is a Moose object because of the Brain role, and
therefore can be constructed by hashref. Behaviour otherwise is unsupported.

=head3 services

A hash of service names. The values are more hashrefs:

B<brain>: The C<short_name> of the brain you want to use for this service.


