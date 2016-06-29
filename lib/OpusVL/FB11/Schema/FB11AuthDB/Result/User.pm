package OpusVL::FB11::Schema::FB11AuthDB::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::User

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'text'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 tel

  data_type: 'text'
  is_nullable: 0

=head2 status

  data_type: 'text'
  default_value: 'active'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "text", is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "tel",
  { data_type => "text", is_nullable => 1 },
  "status",
  { data_type => "text", default_value => "active", is_nullable => 0 },
  "last_login",
  { data_type => 'timestamp', is_nullable => 1 },
  "last_failed_login",
  { data_type => 'timestamp', is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("user_index", ["username"]);

=head1 RELATIONS


=head2 users_roles

Type: has_many

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole>

=cut

__PACKAGE__->has_many(
  "users_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole",
  { "foreign.users_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


__PACKAGE__->has_one(
    'avatar',
    'OpusVL::FB11::Schema::FB11AuthDB::Result::UserAvatar',
    { 'foreign.user_id' => 'self.id' },
    { cascade_copy => 0, cascade_delete => 0 },
);

# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 12:56:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UaxbxFRL86+fBRmFpWtSSQ

use Moose;
use File::ShareDir 'module_dir';
use OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::User;
with 'OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::User';
__PACKAGE__->setup_authdb;

# create an avatar for new users
# default to profile.png
after 'insert' => sub {
    shift->set_default_avatar();
};

=head1 METHODS

=head2 set_default_avatar

Create an avatar record with the defaults set, and return it.
Uses root/static/images/profile.png as the default avatar.

Be sure to check the ->avatar field is null before you call this.

=cut

sub set_default_avatar {
    my ($self) = @_;
    require OpusVL::FB11;
    my $image  = module_dir('OpusVL::FB11') . '/root/static/images/profile.png';
    my $image_data;
    my $buff;

    open my $fh, '<', $image or die ("Could not open profile.png: $!\n");
    while(read $fh, $buff, 1024) {
        $image_data .= $buff;
    }
    close $fh;

    return $self->create_related('avatar', {
        user_id     => $self->id,
        mime_type   => 'image/png',
        data        => $image_data, 
    });
}


=head2 get_or_default_avatar

This will return the avatar record for this user if one is already set, otherwise
it will create a new default one (see C<set_default_avatar>) and return that.

Recommendation is usually to use this in preference to straight ->avatar, to ensure you
always get one.

=cut

sub get_or_default_avatar {
    my ($self) = @_;
    if (my $avatar = $self->avatar) {
        return $avatar;
    }
    return $self->set_default_avatar();
}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

# You can replace this text with custom content, and it will be preserved on regeneration
1;
