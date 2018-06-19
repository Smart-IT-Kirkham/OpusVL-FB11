package OpusVL::FB11::Controller::FB11::Admin::Access;

use Moose;
use namespace::autoclean;
use Tree::Simple::View::HTML;
use Tree::Simple::VisitorFactory;
use HTML::FormHandler;
use List::Util qw/any/;
use Data::Munge qw/elem/;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

our $VERSION = "0.001";

# ABSTRACT: Core ACL administration page

=head1 DESCRIPTION

FB11 extends the concept of roles from L<Catalyst::Plugin::Authentication> and
L<Catalyst::Plugin;:Authorization::Roles>. Each action in the FB11 application
is given a so-called "feature", which works with the ACL.

Roles are therefore promoted to more than just a string name: they represent
feature sets, and thus each role in FB11 represents access rights for users
given that role.

In order to be able to administrate this set, any user store for
L<Catalyst::Plugin::Authentication> will also need to support writing of those
roles to the store.

The role L<OpusVL::FB11::RolesFor::User> defines the interface a User object
must have in order for this controller to be able to work with it.

=cut

has_forms(
    'confirm_form'      => 'Confirm',
);

__PACKAGE__->config
(
    fb11_myclass              => 'OpusVL::FB11',
);


=head2 auto

    Default action for this controller.
    
=cut

sub auto
    : FB11Feature('Role Administration')
    : Action
{
    my ( $self, $c ) = @_;

    # add to the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Access', url => $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('index') ) } );

}

=head2 index

    default action for access administration.

=cut

sub index
    : Path
    : Args(0)
    : FB11Feature('Role Administration')
{
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'fb11/admin/access/show_role.tt';
}

=head2 addrole

    Add a role

=cut

sub addrole
    : Local
    : FB11Feature('Role Administration')
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST')
    {
        my $rolename    = $c->req->param('rolename');
        if($rolename)
        {
            my $role = grep /^\Q$rolename\E$/, $c->user->roles;
            $c->flash->{error_msg} = 'Role already exists' if $role;
            $role = $c->user->add_to_roles( { role => $rolename } ) if !$role;

            if ( $role )
            {
                $c->flash->{status_msg} = "Successfully created new role '$rolename'";
                $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('show_role'), [ $rolename ] ) );
            }
            else
            {
                $c->stash->{error_msg} = 'Role not added';
            }
        }
        else
        {
            $c->stash->{error_msg} = 'Specify a role name!';
        }
    }

    # basically run the action for the index for this page..
    $c->go( $c->controller('FB11::Admin::Access')->action_for('index') );
}

=head2 _load_role

Load a role by name. If it doesn't exist, but the user is supposed to be able to
administrate it, create it. This allows external sources of role names to Just
Work without humans getting in the way.

=cut

sub _load_role
    : Chained(/)
    : PathPart('admin/role')
    : CaptureArgs(1)
    : FB11Feature('Role Administration')
{
    my ( $self, $c, $rolename ) = @_;

    my $role = $c->model('FB11AuthDB::Role')->find( { role => $rolename } );

    if (!$role) {
        if (elem $rolename, [ $c->user->roles_modifiable ]) {
            $role = $c->model('FB11AuthDB::Role')->create({ role => $rolename });
            $c->stash->{info_msg} = "Role $rolename was created automatically";
        }
        else {
            $c->detach('/not_found');
        }
    }

    $c->stash->{role} = $role;
}

=head2 role_management
=cut

sub role_management
    : Chained('_load_role')
    : PathPart('management')
    : Args(0)
    : FB11Feature('Role Administration')
{
    my ($self, $c) = @_;
    my $role = $c->stash->{role};
    my $can_change_any_role = $role->can_change_any_role;
    my @allowed_roles = $role->roles_allowed_roles->get_column('role_allowed')->all;
    my @all_roles = $c->model('FB11AuthDB::Role')->all;
    my @options;
    for my $role (@all_roles) {
        push @options, {
            value => $role->id,
            label => $role->role,
            checked => (grep { $_ == $role->id } @allowed_roles) ? 1 : 0,
        };
    }

    my $can_change_any_role_opts = {
        type    => 'Boolean',
        label   => 'Can change any role',
    };

    # NOTE: this not how you should do this, we should be setting defaults
    # but since we redirect we get away with this.
    $can_change_any_role_opts->{element_attr}->{checked} = 'checked'
        if $role->can_change_any_role;

    my $form = HTML::FormHandler->new(
        widget_wrapper => 'Bootstrap3',
        name => 'role_management_form',
        field_list => [
            'can_change_any_role' => $can_change_any_role_opts,

            'roles_allowed_roles' => {
                label   => 'Roles allowed to modify/apply',
                type    => 'Multiple',
                widget  => 'HorizCheckboxGroup',
                options => \@options,
            },

            'confirm' => {
                type => 'Submit',
                widget => "ButtonTag",
                widget_wrapper => "None",
                value => '<i class="fa fa-check"></i> Save',
                element_attr => { value => 'confirm', class => ['btn', 'btn-success'] }
            },
        ],
    );

    $c->stash->{form} = $form;
    $form->process($c->req->params);    
    if($c->req->param('cancel'))
    {
        $c->response->redirect($c->uri_for($self->action_for('show_role'), [ $role->role ]));
        $c->detach;
    }
    
    if ($form->validated) {
        my $selection = $form->field('roles_allowed_roles');
        my $ids = $form->field('roles_allowed_roles')->value;
        my $can_change_any_role = $form->field('can_change_any_role')->value;
        if (not $can_change_any_role) {
            $role->delete_related('roles_allowed_roles');
            $role->create_related('roles_allowed_roles', { role_allowed => $_}) for @$ids;
        }

        $role->can_change_any_role($can_change_any_role);
        $c->flash->{status_msg} = 'Permissions changed';
        $c->res->redirect($c->req->uri);
    }

}

=head2 user_for_role

    Middle of chain.

=cut

sub user_for_role
    : Chained('_load_role')
    : PathPart('user')
    : CaptureArgs(1)
    : FB11Feature('Role Administration')
{
    my ( $self, $c, $user_id ) = @_;
    $c->stash->{roleuser} = $c->model('FB11AuthDB::User')->find( $user_id );
}

=head2 user_delete_from_role

    End of chain.
    Add a user to a role (and give it a value)

=cut

sub user_delete_from_role
    : Chained('user_for_role')
    : PathPart('delete')
    : Args(0)
    : FB11Feature('Role Administration')
{
    my ( $self, $c ) = @_;
    # delete user/role lookup..
    $c->stash->{role}->delete_related('user_roles', { user_id => $c->stash->{roleuser}->id } );
    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 delete_role

    End of chain.
    Deletes a role (after confirmation)

=cut

sub delete_role
    : Chained('_load_role')
    : PathPart('delrole')
    : Args(0)
    : FB11Feature('Role Administration')
{   
    my ( $self, $c ) = @_;
    my $form = $self->confirm_form;
    $c->stash->{question} = "Are you sure you want to delete the role: " . $c->stash->{role}->role;
    $c->stash->{template} = 'fb11/admin/confirm.tt';
    $c->stash->{form}     = $form;

    $form->process($c->req->params);
    if ($form->validated) {
        if ($c->req->params->{submitok}) {
            $c->stash->{role}->delete;
            $c->flash->{status_msg} = "Role deleted";
            $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('index') ) );
        }
        else {
            $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('index') ) );
        }
    }
}

=head2 user_add_to_role

    End of chain.
    Adds a user to a role

=cut

sub user_add_to_role
    : Chained('_load_role')
    : PathPart('adduser')
    : Args(0)
    : FB11Feature('Role Administration')
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' )
    {
        # create the look up..
        my $user_id        = $c->req->param('user_id');
        $c->stash->{role}->update_or_create_related('user_roles', { user_id => $user_id } );
    }

    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 action_rule_for_role

    End of chain.

=cut

sub action_rule_for_role
    : Chained('_load_role')
    : PathPart('rule')
    : Args(2)
    : FB11Feature('Role Administration')
{
    my ( $self, $c, $action, $action_path ) = @_;

    # find any access control rule for the passed action path..
    my $aclrule =  $c->model('FB11AuthDB::Aclrule')->find( { actionpath => $action_path } );

    if ( ! $aclrule )
    {
        $aclrule =  $c->model('FB11AuthDB::Aclrule')->create( { actionpath => $action_path } );
    }

    if ( $action eq 'deny' )
    {
        $c->stash->{status_msg} .= "Removed role " . $c->stash->{role}->role . " from access control rule:" . $aclrule->actionpath;
        $aclrule->delete_related('aclrule_roles', { role_id => $c->stash->{role}->id } );
    }
    elsif ( $action eq 'allow' )
    {
        $c->stash->{status_msg} .= "Added role " . $c->stash->{role}->role . " to access control rule:" . $aclrule->actionpath;
        $aclrule->create_related('aclrule_roles', { role_id => $c->stash->{role}->id } );
    }
    elsif ( $action eq 'revoke' )
    {
        $c->stash->{status_msg} .= "Revoked access control for:" . $aclrule->actionpath;
        $aclrule->delete;
    }

    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 show_role

Lists all the FB11 features as checkboxes so you can assign them to this role.

=cut

sub show_role
    : Chained('_load_role')
    : PathPart('show')
    : Args(0)
    : FB11Feature('Role Administration')
{
    my ( $self, $c ) = @_;

    push @{$c->stash->{breadcrumbs}}, {
        name    => $c->stash->{role}->role,
        url     => $c->uri_for( $c->controller('FB11::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->id ] )
    };

    $c->stash->{action_tree} = $c->fb11_actiontree;

    my $show_role = $c->stash->{role}->role;

    # XXX This tree is ludicrous considering the entire ACL is flat
    # build my visitor to get the path to the root..
    my $path2root_visitor = Tree::Simple::VisitorFactory->getVisitor("PathToRoot");
    $path2root_visitor->setNodeFilter(sub { my ($t) = @_; return $t->getNodeValue()->node_name });
    $c->stash->{fb11_features} = $c->fb11_features->feature_list($show_role);

    if ( $c->req->method eq 'POST' )
    {
        my @features_allowed;
        my @features_denied;
        for my $app (keys %{$c->stash->{fb11_features}})
        {
            my $features = $c->stash->{fb11_features}->{$app};
            for my $feature (keys %$features)
            {
                if($c->req->params->{"feature_$app/$feature"})
                {
                    push @features_allowed, "$app/$feature";
                }
                else
                {
                    push @features_denied, "$app/$feature";
                }
            }
        }
        for my $feature (@features_allowed)
        {
            $c->log->debug("****************ALLOWING FEATURE:" . $feature . "\n") if $c->debug;
            my $aclfeature = $c->model('FB11AuthDB::Aclfeature')->find_or_create( { feature => $feature } );
            $c->stash->{role}->update_or_create_related('aclfeature_roles', { aclfeature_id => $aclfeature->id } );
        }
        for my $feature (@features_denied)
        {
            $c->log->debug("****************DENYING FEATURE:" . $feature . "\n") if $c->debug;
            my $aclfeature = $c->model('FB11AuthDB::Aclfeature')->find_or_create( { feature => $feature } );
            $c->stash->{role}->search_related('aclfeature_roles', { aclfeature_id => $aclfeature->id } )->delete;
        }
        # now we run traverse the tree finding if we are allowing access or not...

        # XXX WHAT IS HAPPENING HELP ME
        my $allowed = [];
        my $denied  = [];
        $c->stash->{action_tree}->traverse
        (
            sub 
            {
                my ($_tree) = @_;
                $_tree->accept($path2root_visitor);
                my $path = $path2root_visitor->getPathAsString("/");
                if ( $c->req->params->{'action_' . $path} )
                {
                    push ( @$allowed, $path );
                }
                else
                {
                    push ( @$denied, $path );
                }
            },
        );

        foreach my $path ( @$allowed )
        {
            $c->log->debug("***************ALLOWING:" . $path . "\n") if $c->debug;
            my $aclrule = $c->model('FB11AuthDB::Aclrule')->find_or_create( { actionpath => $path } );
            $c->stash->{role}->update_or_create_related('aclrule_roles', { aclrule_id => $aclrule->id } );
        }
        foreach my $path ( @$denied )
        {
            $c->log->debug("****************DENYING:" . $path . "\n") if $c->debug;
            my $aclrule = $c->model('FB11AuthDB::Aclrule')->find_or_create( { actionpath => $path } );
            $c->stash->{role}->search_related('aclrule_roles', { aclrule_id => $aclrule->id } )->delete;
        }

        # now we have allowed and denied access to the different parts of the tree... we need to rebuild it..
        $c->stash->{action_tree} = $c->fb11_actiontree(1); # built with a 'force re-read'
        $c->stash->{fb11_features} = $c->fb11_features->feature_list($show_role);

    }


    # create the tree view...
    # need to prune items that are in_feature 
    # to prevent confusion.
    # oh NOW you want to prevent confusion? - Al
    my $display_tree = $c->stash->{action_tree}->clone;
    my @remove;
    $display_tree->traverse(sub {
        my ($tree) = @_;
        push @remove, $tree if($tree->getNodeValue->in_feature);
        push @remove, $tree if($tree->getNodeValue->action_attrs && any { defined $tree->getNodeValue->action_attrs->{$_} } qw/FB11AllAccess Public/);
    });
    for my $item (@remove)
    {
        my $parent = $item->getParent;
        # why does this happen?
        next if not ref $parent;
        $parent->removeChild($item);
        while($parent->getChildCount == 0)
        {
            my $item = $parent;
            $parent = $parent->getParent;
            last if !$parent->can('removeChild');
            $parent->removeChild($item);
        }
    }
    my $tree_view = Tree::Simple::View::HTML->new
    (
        $display_tree => 
        (
            list_css                => "list-style: none;",
            #list_item_css           => "font-family: courier;",
            node_formatter          => sub 
            {
                my ($tree) = @_;
                my $node_string = $tree->getNodeValue()->node_name;

                $tree->accept($path2root_visitor);
                my $checkbox_name = $path2root_visitor->getPathAsString("/");

                my $checked             = '';
                my $color               = '#81BEF7';

                if($tree->getNodeValue->in_feature)
                {
                    # it's part of a feature so avoid using this mechanism.
                    $color = 'grey';
                }
                elsif ( defined $tree->getNodeValue->action_path )
                {
                    $color = '#FA5882';
                    if ( my $roles = $tree->getNodeValue->access_only )
                    {
                       my $matched_role = 0;
                       foreach my $allowed_role ( @{ $tree->getNodeValue->access_only } )
                       {
                           $matched_role = 1 if ( $allowed_role eq $show_role );
                       }
                       if ( $matched_role ) # rules and a matched.. therefore, access :)..
                       {
                           $checked = 'checked';
                           $color   = '#3fb618';
                       }
                    }
                    $node_string = qq{<div class="checkbox"><label><input type="checkbox" name="action_$checkbox_name" value="allow" $checked> $node_string</label></div>};
                }
                else
                {
                    $node_string = $node_string;
                }
                $node_string = "<font color='$color'>" . $node_string . "</font>";
                return $node_string;
            }
        )
    );  
    $c->stash->{access_control_role_tree} = $tree_view;

    # manually set (as we may forward to this action).
    $c->stash->{template} = 'fb11/admin/access/show_role.tt';
}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
