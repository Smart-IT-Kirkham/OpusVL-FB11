#!/usr/bin/env perl

use inc::Module::Install;

name 'OpusVL-AppKit';
all_from 'lib/OpusVL/AppKit.pm';

requires 'Moose';
requires 'File::ShareDir';
requires 'File::Spec';
requires 'List::Util';

requires 'Catalyst::Runtime' => '5.8002';
requires 'Catalyst::Action::RenderView';

requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::Download';

requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::CustomErrorMessage';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Authorization::ACL';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';

requires 'CatalystX::AppBuilder';
requires 'CatalystX::VirtualComponents';
requires 'CatalystX::SimpleLogin';

requires 'parent';
requires 'Config::General';

catalyst;

#install_script glob('script/*.pl');
auto_install;
WriteAll;
