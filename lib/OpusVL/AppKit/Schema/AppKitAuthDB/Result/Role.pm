package OpusVL::AppKit::Schema::AppKitAuthDB::Result::Role;

use Moose;
BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("role");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "role",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


__PACKAGE__->has_many(
  "user_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UserRole",
  { "foreign.role_id" => "self.id" },
);
__PACKAGE__->many_to_many( users => 'user_roles', 'user_id');

__PACKAGE__->has_many(
  "aclrule_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::AclruleRole",
  { "foreign.role_id" => "self.id" },
);
__PACKAGE__->many_to_many( aclrules => 'aclrule_roles', 'aclrule_id');


__PACKAGE__->has_many(
  "role_parameters",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::RoleParameter",
  { "foreign.role_id" => "self.id" },
);
__PACKAGE__->many_to_many( parameters => 'role_parameters', 'parameter_id');


sub params_hash
{
    my $self = shift;

    my %hash;
    foreach my $rp ( $self->role_parameters )
    {
        $hash{  $rp->parameter->parameter } = $rp->value;
    }

    return \%hash;     
}

1;

__END__
