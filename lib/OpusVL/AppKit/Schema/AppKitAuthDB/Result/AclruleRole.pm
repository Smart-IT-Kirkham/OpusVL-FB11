package OpusVL::AppKit::Schema::AppKitAuthDB::Result::AclruleRole;

use Moose;
BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("aclrule_role");
__PACKAGE__->add_columns(
  "aclrule_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "role_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("aclrule_id", "role_id");
__PACKAGE__->belongs_to("aclrule_id", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Aclrule", { id => "aclrule_id" });
__PACKAGE__->belongs_to("role_id", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Role", { id => "role_id" });


1;

__END__
