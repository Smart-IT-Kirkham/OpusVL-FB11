package OpusVL::FB11::Schema::FB11AuthDB::Result::User;

use Moose;
use OpusVL::FB11::Hive;
use File::ShareDir 'module_dir';
use namespace::autoclean;
extends 'DBIx::Class::Core';
with 'OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::User';

our $VERSION = '0.001';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");
__PACKAGE__->table("users");

=head1 DESCRIPTION

This is the core FB11 user class, the default auth method for an FB11
application. It works with L<Catalyst::Plugin::Authentication> via the consumed
role L<OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::User>.

=head1 ACCESSORS

=head2 id

Auto-incremented user ID

=head2 username

B<Considered for deprecation>

The username to log in with. We should probably deprecate this in favour of just
using the email address.

=head2 password

The database does not encrypt the password; this is set up by
L<OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::User/setup_authdb> for
some reason.

DEBT: I tried to pull this behaviour into this class but it broke.

=head2 email

A preferable unique value to use as the login username. This can be assumed to
be a valid email address, and therefore you can send emails to users with this.

=head2 name

User's real name, or preferred name, or whatever.

=head2 tel

User's telephone number. This has been required for a long time but we should
really get around to creating a new DB version where it is not.

=head2 status

Either 'enabled' or 'disabled'.

FIXME: The DB default is 'active', which we need a new DB version to change.

=cut

__PACKAGE__->add_columns(
    id => {
        data_type => "integer",
        is_auto_increment => 1,
        is_nullable => 0
    },
    username => {
        data_type => "text",
        is_nullable => 0
    },
    password => {
        data_type => "text",
        is_nullable => 0
    },
    email => {
        data_type => "text",
        is_nullable => 0
    },
    name => {
        data_type => "text",
        is_nullable => 0
    },
    tel => {
        data_type => "text",
        is_nullable => 1
    },
    status => {
        data_type => "text",
        default_value => "active", #FIXME
        is_nullable => 0
    },
    last_login => {
        data_type => 'timestamp',
        is_nullable => 1
    },
    last_failed_login => {
        data_type => 'timestamp',
        is_nullable => 1
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(["username"]);
__PACKAGE__->resultset_attributes({ order_by => [ 'name' ] });
__PACKAGE__->setup_authdb;

=head1 RELATIONS

=head2 users_roles

A user has many L<OpusVL::FB11::Schema::FB11AuthDB::Result::UsersRole>s. These
are more complicated than simple strings for hysterical raisins. You can deal
with the strings themselves by using L</role_names>, which you should do because
then you are not tied to this user structure.

See also
L<OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::User/setup_authdb>, which
adds a many-to-many called C<roles>.

=cut

__PACKAGE__->has_many(
  users_roles => 'OpusVL::FB11::Schema::FB11AuthDB::Result::UsersRole',
  { "foreign.users_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 1 },
);

=head2 avatar

A user has one L<OpusVL::FB11::Schema::FB11AuthDB::Result::UserAvatar> for some
reason. Present state of functionality of this part of the system is unknown.

=cut

__PACKAGE__->has_one(
    avatar => 'OpusVL::FB11::Schema::FB11AuthDB::Result::UserAvatar',
    { 'foreign.user_id' => 'self.id' },
    { cascade_copy => 0, cascade_delete => 1 },
);

# create an avatar for new users
# default to profile.png
after 'insert' => sub {
    shift->set_default_avatar();
};

# FIXME DEBT XXX !!!
# Time constraint and laziness means I've not made a new DH version for the
# cascade delete changes. Instead, I'm doing this
# DELETE THIS LATER or so help me I'll roll the BOFH dice
before delete => sub {
    my $self = shift;
    $self->roles->delete;
    $self->users_roles->delete;
    $self->avatar->delete;
};

=head1 METHODS

=head2 role_names

Returns role names the user is a member of. This is the preferable interface
into roles, because every other user auth under the sun just uses string names
for roles (or "groups").

=cut

sub role_names {
    my ($self) = shift;

    $self->roles->get_column('role')->all;
}

=head2 has_role

Returns true if the user has the given role (string name) (case sensitive)

=cut

sub has_role {
    my $self = shift;
    my $role = shift;
    grep { $_ eq $role } $self->role_names;
}

=head2 set_default_avatar

Create an avatar record with the defaults set, and return it.
Uses root/static/images/profile.png as the default avatar.

Overrides the current value of the avatar field.

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

=head2 augmentation_for

FIXME: Are we still using this or is this left over from hat experimentation?

Given a string name, finds the component so named and requests any augmented
data provided thereby.

Well-behaved components will return a L<DBIx::Class> result because this is one
of those.

=cut

sub augmentation_for {
    my $self = shift;
    my $component = shift;

    OpusVL::FB11::Hive
        ->brain($component)
        ->hat('augments_object')
        ->get_augmented_object($self);
}

=head2 parameters

=head2 params_hash

This returns a hashref of all parameters defined against this object. This is
done by finding all brains wearing the C<parameters> hat and asking them.

C<params_hash> is supplied as an alias for backward compatibility.

=cut

sub parameters {
    my $self = shift;

    my $combined = {};
    for my $hat ( OpusVL::FB11::Hive->hats('parameters') ) {
        my $current = $hat->get_augmented_data($self);
        next unless $current;
        $combined = {
            %$combined,
            %$current
        }
    }

    return $combined;
}

*params_hash = \&parameters;

=head2 methods_for_delegation

Returns an arrayref of method names that you can safely delegate to this object,
using Moose's C<handles> attribute:

    has core_user => (
        is => 'rw',
        handles => OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::User->methods_for_delegation
    );

Of course, you're not required to delegate; it might be useful in some
situations though.

Note that nothing in FB11 is going to handle a C<core_user> attribute like this;
your own component should do that.

=cut

sub methods_for_delegation {
    [
        __PACKAGE__->columns,
        __PACKAGE__->relationships
    ]
}

1;
