#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use_ok 'OpusVL::AppKit';
use_ok 'OpusVL::AppKit::View::SimpleXML';
use_ok 'HTML::FormFu::Validator::OpusVL::AppKit::CurrentPasswordValidator';
use_ok 'OpusVL::AppKit::TraitFor::Controller::Login::SetHomePageFlag';

done_testing;
