#!perl

use strict;
use warnings;

use OpusVL::FB11::Hive;
use OpusVL::FB11::Utils qw/load_config/;

OpusVL::FB11::Hive
    ->configure(load_config $ENV{FB11_HIVE_CONFIG}, $ENV{FB11_HIVE_CONFIG_PATH})
    ->init;

our $VERSION = '0';

OpusVL::FB11::Hive->service('fb11::app')->psgi;

