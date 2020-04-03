package OpusVL::FB11::Hive::Initialise;
# ABSTRACT: Utilities to configure and initialise the hive in standard ways
use Exporter::Easy (
    OK => [qw<configure_and_initialise_global_hive>],
);

our $VERSION = '2';

use v5.20;
use strict;
use warnings;
no warnings 'experimental::signatures';;

use OpusVL::FB11::Hive;
use OpusVL::FB11::Utils qw/load_config getenv_or_throw/;

=head1 FUNCTIONS

=head2 configure_and_initialise_global_hive

Configure and initialise the global hive L<OpusVL::FB11::Hive>,
taking into consideration the environment variables C<FB11_HIVE_CONFIG> and
C<FB11_HIVE_CONFIG_PATH>.

Required named parameters:

=over 4

=item scriptname

The name of the script calling this for log messages,
e.g. C<'fb11.psgi'> or C<'foo-script'>

=back

=cut

sub configure_and_initialise_global_hive
{
    my %params = @_;
    my $scriptname = $params{scriptname};
    print STDERR "$scriptname: Configure and initialise hive...\n";
    my $hive_config_filename = getenv_or_throw('FB11_HIVE_CONFIG');
    my $hive_config_key_path = $ENV{FB11_HIVE_CONFIG_PATH};
    OpusVL::FB11::Hive
        ->configure(
            load_config($hive_config_filename, $hive_config_key_path))
        ->init;
    print STDERR "$scriptname: finished hive initialisation\n";
}

1;
