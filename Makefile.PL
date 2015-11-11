#!/usr/bin/env perl

use inc::Module::Install;

name 'OpusVL-FB11';
all_from 'lib/OpusVL/FB11.pm';

requires 'Moose';
requires 'File::ShareDir';
requires 'File::Spec';
requires 'List::Util';
requires 'Net::LDAP';
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
requires 'Catalyst::View::TT::Alloy';
requires 'Catalyst::View::Excel::Template::Plus';
requires 'Template::AutoFilter';
requires 'Template::Alloy' => '1.020';
requires 'Cpanel::JSON::XS';

# Base Catalyst components
requires 'Catalyst::Runtime' => '5.90051';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Store::DBIx::Class';

# Catalyst views
requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::Download';
requires 'Catalyst::View::Thumbnail';
requires 'Catalyst::View::PDF::Reuse';

# Catalyst plugins
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Unicode::Encoding';
requires 'Catalyst::Plugin::CustomErrorMessage';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Authorization::ACL';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::Cache';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Static::Simple' => 0.30;
requires 'Catalyst::Plugin::Cache';
requires 'Cache::FastMmap';
requires 'Try::Tiny';

# really test dependencies.
requires 'Plack';
requires 'Child';

# Catalyst models
requires 'Catalyst::Model::DBIC::Schema';

# Catalyst controllers
requires 'Catalyst::Controller::HTML::FormFu';
requires 'Catalyst::Action::REST';

# CatalystX components
requires 'CatalystX::AppBuilder' => '0.00010';
requires 'CatalystX::VirtualComponents';
requires 'CatalystX::SimpleLogin';

requires 'Import::Into';

requires 'Test::DBIx::Class';
requires 'Test::Most';
requires 'HTML::FormHandler';
requires 'HTML::FormHandler::Moose';
requires 'HTML::FormHandler::Widget::Field::HorizCheckboxGroup';
requires 'HTML::FormHandler::Widget::Wrapper::Bootstrap3';
requires 'HTML::FormHandler::TraitFor::Model::DBIC';

#catalyst;

install_share 'lib/auto';

#install_script glob('script/*.pl');
auto_install;
resources (
    repository => {
        url => 'ssh://git.rug-01.opusvl.net/srv/git/OpusVL-FB11',
        type => 'git',
    },
);

WriteAll;
