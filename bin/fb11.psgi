#!perl

use strict;
use warnings;
no warnings 'experimental::signatures';;

use OpusVL::FB11::Hive::Initialise qw<configure_and_initialise_global_hive>;

configure_and_initialise_global_hive(
    scriptname => 'fb11.psgi',
);

our $VERSION = '0';

OpusVL::FB11::Hive->service('fb11::app')->psgi;
