package OpusVL::AppKit::Controller::AppKit::Admin::Access;

use Moose;
use namespace::autoclean;
use Tree::Simple::View::HTML;
use Tree::Simple::VisitorFactory;

BEGIN { extends 'Catalyst::Controller::HTML::FormFu'; };
with 'OpusVL::AppKit::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    appkit_myclass              => 'OpusVL::AppKit',
);


=head2 auto

    Default action for this controller.
    
=cut

sub auto
    : Private
{
    my ( $self, $c ) = @_;

    # add to the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Access', url => $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('index') ) } );

}

=head2 index

    default action for access administration.

=cut

sub index
    : Path
    : Args(0)
{
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'appkit/admin/access/show_role.tt';
}

=head2 addrole

    Add a role

=cut

sub addrole
    : Local
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST')
    {
        my $rolename    = $c->req->param('rolename');
        if($rolename)
        {
            my $role        = $c->user->add_to_roles( { role => $rolename } );

            if ( $role )
            {
                $c->res->redirect( $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('show_role'), [ $rolename ] ) );
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
    $c->go( $c->controller('AppKit::Admin::Access')->action_for('index') );
}

=head2 role_specific

    Start of chain.
    Action to capture role specific action..

=cut

sub role_specific
    : Chained('/')
    : PathPart('admin/access/role')
    : CaptureArgs(1)
{
    my ( $self, $c, $rolename ) = @_;

    # put role into stash..
    $c->stash->{role} = $c->model('AppKitAuthDB::Role')->find( { role => $rolename } );

}

=head2 user_for_role

    Middle of chain.

=cut

sub user_for_role
    : Chained('role_specific')
    : PathPart('user')
    : CaptureArgs(1)
{
    my ( $self, $c, $user_id ) = @_;
    $c->stash->{roleuser} = $c->model('AppKitAuthDB::User')->find( $user_id );
}

=head2 user_delete_from_role

    End of chain.
    Add a user to a role (and give it a value)

=cut

sub user_delete_from_role
    : Chained('user_for_role')
    : PathPart('delete')
    : Args(0)
{
    my ( $self, $c ) = @_;
    # delete user/role lookup..
    $c->stash->{role}->delete_related('user_roles', { user_id => $c->stash->{roleuser}->id } );
    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 delete_role

    End of chain.
    Deletes a role (after confirmation)

=cut

sub delete_role
    : Chained('role_specific')
    : PathPart('delrole')
    : Args(0)
    : AppKitForm("appkit/admin/confirm.yml")
{   
    my ( $self, $c ) = @_;

    $c->stash->{question} = "Are you sure you want to delete the role: " . $c->stash->{role}->role;
    $c->stash->{template} = 'appkit/admin/confirm.tt';

    if ( $c->stash->{form}->submitted_and_valid )
    {   
        $c->stash->{role}->delete;
        $c->flash->{status_msg} = "Role deleted";
        $c->res->redirect( $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('index') ) );
    }
    elsif( $c->req->method eq 'POST' )
    {
        $c->flash->{status_msg} = "Role NOT deleted";
        $c->res->redirect( $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('index') ) );
    }

}

=head2 user_add_to_role

    End of chain.
    Adds a user to a role

=cut

sub user_add_to_role
    : Chained('role_specific')
    : PathPart('adduser')
    : Args(0)
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' )
    {
        # create the look up..
        my $user_id        = $c->req->param('user_id');
        $c->stash->{role}->update_or_create_related('user_roles', { user_id => $user_id } );
    }

    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 action_rule_for_role

    End of chain.

=cut

sub action_rule_for_role
    : Chained('role_specific')
    : PathPart('rule')
    : Args(2)
{
    my ( $self, $c, $action, $action_path ) = @_;

    # find any access control rule for the passed action path..
    my $aclrule =  $c->model('AppKitAuthDB::Aclrule')->find( { actionpath => $action_path } );

    if ( ! $aclrule )
    {
        $aclrule =  $c->model('AppKitAuthDB::Aclrule')->create( { actionpath => $action_path } );
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
    $c->res->redirect( $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 show_role

    End of chain.
    Action to display role info page.

=cut

sub show_role
    : Chained('role_specific')
    : PathPart('show')
    : Args(0)
{
    my ( $self, $c ) = @_;

    push ( @{ $c->stash->{breadcrumbs} }, { name => $c->stash->{role}->role, url => $c->uri_for( $c->controller('AppKit::Admin::Access')->action_for('show_role'), [ $c->stash->{role}->id ] ) } );

    # stash the tree..
    $c->stash->{action_tree} = $c->appkit_actiontree;

    # get role to show from stash..
    my $show_role = $c->stash->{role}->role;

    # build my visitor to get the path to the root..
    my $path2root_visitor = Tree::Simple::VisitorFactory->getVisitor("PathToRoot");
    $path2root_visitor->setNodeFilter(sub { my ($t) = @_; return $t->getNodeValue()->node_name });

    # test if need to process some rules submission...
    if ( $c->req->method eq 'POST' )
    {
        # now we run traverse the tree finding if we are allowing access or not...

        my $allowed = [];
        my $denied  = [];
        $c->stash->{action_tree}->traverse
        (
            sub 
            {
                my ($_tree) = @_;
                $_tree->accept($path2root_visitor);
                my $path = $path2root_visitor->getPathAsString("/");
                if ( $c->req->params->{$path} )
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
            my $aclrule = $c->model('AppKitAuthDB::Aclrule')->find_or_create( { actionpath => $path } );
            $c->stash->{role}->update_or_create_related('aclrule_roles', { aclrule_id => $aclrule->id } );
        }
        foreach my $path ( @$denied )
        {
            $c->log->debug("****************DENYING:" . $path . "\n") if $c->debug;
            my $aclrule = $c->model('AppKitAuthDB::Aclrule')->find_or_create( { actionpath => $path } );
            $c->stash->{role}->search_related('aclrule_roles', { aclrule_id => $aclrule->id } )->delete;
        }

        # now we have allowed and denied access to the different parts of the tree... we need to rebuild it..
        $c->stash->{action_tree} = $c->appkit_actiontree(1); # built with a 'force re-read'

    }

    # create the tree view...
    my $tree_view = Tree::Simple::View::HTML->new
    (
        $c->stash->{action_tree} => 
        (
            list_css                => "list-style: circle;",
            list_item_css           => "font-family: courier;",
            node_formatter          => sub 
            {
                my ($tree) = @_;
                my $node_string = $tree->getNodeValue()->node_name;

                $tree->accept($path2root_visitor);
                my $checkbox_name = $path2root_visitor->getPathAsString("/");

                my $checked             = '';
                my $color               = 'blue';

                if ( defined $tree->getNodeValue->action_path )
                {
                    $color = 'red';
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
                           $color   = 'green';
                       }
                    }
                    $node_string = "<input type='checkbox' name='$checkbox_name' value='allow' $checked>" . $node_string;
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
    $c->stash->{template} = 'appkit/admin/access/show_role.tt';
}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
