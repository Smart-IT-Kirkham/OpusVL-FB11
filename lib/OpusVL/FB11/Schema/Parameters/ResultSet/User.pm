package OpusVL::FB11::Schema::Parameters::ResultSet::User;

use Moose;
extends 'DBIx::Class::ResultSet';
with 'OpusVL::Preferences::RolesFor::ResultSet::PrfOwner';

1;

