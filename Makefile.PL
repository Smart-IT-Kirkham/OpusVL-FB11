#!/usr/bin/env perl

use inc::Module::Install;

name 'OpusVL-AppKit';
all_from 'lib/OpusVL/AppKit.pm';

requires 'Moose';
requires 'File::ShareDir';
requires 'File::Spec';
requires 'List::Util';
requires 'XML::Simple';
requires 'Getopt::Compact';
requires 'Tree::Simple';
requires 'Tree::Simple::View';
requires 'Tree::Simple::VisitorFactory';
requires 'Crypt::Eksblowfish::Bcrypt';
requires 'HTML::FormFu::Model::DBIC';
requires 'DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt';
requires 'Template::Plugin::DateTime';
requires 'parent';
requires 'Config::General';
requires 'DBIx::Class::TimeStamp';
requires 'String::MkPasswd';

# Base Catalyst components
requires 'Catalyst::Runtime' => '5.8002';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Store::DBIx::Class';

# Catalyst views
requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::Download';
requires 'Catalyst::View::PDF::Reuse';

# Catalyst plugins
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::CustomErrorMessage';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Authorization::ACL';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Static::Simple';

# really test dependencies.
requires 'Catalyst::Engine::PSGI';
requires 'Plack';
requires 'Child';

# Catalyst models
requires 'Catalyst::Model::DBIC::Schema';

# Catalyst controllers
requires 'Catalyst::Controller::HTML::FormFu';

# CatalystX components
requires 'CatalystX::AppBuilder';
requires 'CatalystX::VirtualComponents';
requires 'CatalystX::SimpleLogin';

requires 'Test::DBIx::Class';

catalyst;

install_share 'lib/auto';

#install_script glob('script/*.pl');
auto_install;
WriteAll;
