requires 'Config::General';
requires 'Config::JFDI';
requires 'Cpanel::JSON::XS';
requires 'Crypt::Eksblowfish::Bcrypt';
requires 'Data::Munge';
requires 'Data::Visitor::Tiny';
requires 'DateTime';
requires 'DateTime::Format::Pg';
requires 'DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt';
requires 'DBIx::Class::TimeStamp';
requires 'Exporter::Easy';
requires 'Getopt::Compact';
requires 'Getopt::Long';
requires 'failures';
requires 'File::ShareDir';
requires 'File::Spec';
requires 'File::Slurper';
requires 'File::Find';
requires 'File::Path';
requires 'HTTP::Status';
requires 'List::Gather';
requires 'List::Util';
requires 'List::UtilsBy';
requires 'Moose';
requires 'MooseX::ClassAttribute';
requires 'Net::LDAP';
requires 'parent';
requires 'PerlX::Maybe';
requires 'Plack::Handler::Martian';
requires 'Pod::Usage';
requires 'String::MkPasswd';
requires 'Switch::Plain';
requires 'Template::Plugin::DateTime';
requires 'Tree::Simple';
requires 'Tree::Simple::View';
requires 'Tree::Simple::VisitorFactory';
requires 'Try::Tiny';
requires 'Template::AutoFilter';
requires 'Template::Alloy' => '1.020';
requires 'URL::Encode';
requires 'YAML::Tiny';
requires 'XML::Simple';

requires 'DBD::Pg';

# This is vendored in because of a patch to make WithSchema work
requires 'DBIx::Class::DeploymentHandler';
requires 'DBIx::Class::DeploymentHandler::VersionStorage::WithSchema';

# Base Catalyst components
requires 'Catalyst::Runtime' => '5.90051';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::ConfigLoader::Environment';

# Catalyst views
requires 'Catalyst::View::Download';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::Excel::Template::Plus';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::PDF::Reuse';
requires 'Catalyst::View::Thumbnail';
requires 'Catalyst::View::TT::Alloy';

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

# really test dependencies.
requires 'Plack';
requires 'Child';

# Catalyst models
requires 'Catalyst::Model::DBIC::Schema';

# Catalyst controllers
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

requires 'OpusVL::AppKit::Schema::AppKitAuthDB';
requires 'OpusVL::DBIC::Helper';
