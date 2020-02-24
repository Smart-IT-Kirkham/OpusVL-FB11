#!perl

use strict;
use warnings;

use OpusVL::FB11::Hive;
use OpusVL::FB11::Utils qw/load_config getenv_or_throw/;

print STDERR "fb11.psgi: Configure and initialise hive...\n";

my $hive_config_filename = getenv_or_throw('FB11_HIVE_CONFIG');
my $hive_config_key_path = $ENV{FB11_HIVE_CONFIG_PATH};

OpusVL::FB11::Hive
    ->configure(
        load_config($hive_config_filename, $hive_config_key_path))
    ->init;

our $VERSION = '0';

OpusVL::FB11::Hive->service('fb11::app')->psgi;

