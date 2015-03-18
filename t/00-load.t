#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use_ok 'OpusVL::FB11::Form::Login';
use_ok 'OpusVL::FB11';
use_ok 'OpusVL::FB11::View::SimpleXML';
use_ok 'OpusVL::FB11::TraitFor::Controller::Login::SetHomePageFlag';
use_ok 'OpusVL::FB11::View::Excel';

done_testing;
