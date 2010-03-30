package OpusVL::AppKit::Controller::AppKitAdmin::Access;

use Moose;
use namespace::autoclean;
use Tree::Simple::View::HTML;

BEGIN { extends 'Catalyst::Controller' }

=head2 auto
    Default action for this controller.
=cut
sub auto
    : Private
{
    my ( $self, $c ) = @_;

    # add to the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Access', url => $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('index') ) } );
}

=head2 index
    default action for access administration.
=cut
sub index
    : Path
    : Args(0)
{
    my ( $self, $c ) = @_;
}

=head2 addrole
    Add a role
=cut
sub addrole
    : Local
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' )
    {
        my $rolename     = $c->req->param('rolename');
        my $role = $c->user->add_to_roles( { role => $rolename } );
    }
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('index') ) );
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

=head2 parameter_for_role
    Middle of chain.
=cut
sub parameter_for_role
    : Chained('role_specific')
    : PathPart('param')
    : CaptureArgs(1)
{
    my ( $self, $c, $parameter_id ) = @_;
    $c->stash->{parameter} = $c->model('AppKitAuthDB::Parameter')->find( $parameter_id );
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
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 parameter_delete_from_role
    End of chain.
    Add a parameter to a role (and give it a value)
=cut
sub parameter_delete_from_role
    : Chained('parameter_for_role')
    : PathPart('delete')
    : Args(0)
{
    my ( $self, $c ) = @_;
    # delete role/parameter lookup..
    $c->stash->{role}->delete_related('role_parameters', { parameter_id => $c->stash->{parameter}->id } );
    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
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
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 parameter_add_to_role
    End of chain.
    Adds a parameter to a role (and gives it a value)
=cut
sub parameter_add_to_role
    : Chained('role_specific')
    : PathPart('addparam')
    : Args(0)
{
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' )
    {
        my $parameter_id        = $c->req->param('parameter_id');
        my $parameter_value     = $c->req->param('parameter_value');

        # create the look up (and the assocated value)...
        $c->stash->{role}->update_or_create_related('role_parameters', { parameter_id => $parameter_id, value => $parameter_value } );
    }

    # refresh show page..
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
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
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) ) ;
}

=head2 delete_role
    End of chain.
=cut
sub delete_role
    : Chained('role_specific')
    : PathPart('delete')
    : Args(0)
{
    my ( $self, $c ) = @_;

    $c->stash->{role}->delete;
    $c->res->redirect( $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('index') ) );
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

    # stash the tree..
    $c->stash->{action_tree} = $c->appkit_actiontree;

    # set the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Role Access', url => $c->uri_for( $c->controller('AppKitAdmin::Access')->action_for('show_role'), [ $c->stash->{role}->role ] ) } );

    # get role to show from stash..
    my $show_role = $c->stash->{role}->role;

    # mix the CSS properties and CSS classes
    my $tree_view = Tree::Simple::View::HTML->new
    (
        $c->stash->{action_tree} => 
        (
            list_css                => "list-style: circle;",
            list_item_css           => "font-family: courier;",
            expanded_item_css_class => "myExpandedListItemClass",                                                         
            node_formatter          => sub 
            {
                my ($tree) = @_;
                my $node_string = $tree->getNodeValue()->node_name;
                if ( defined $tree->getNodeValue->action_path )
                {
                    my $color    = 'blue';

                    if ( my $roles = $tree->getNodeValue->access_only )
                    {
                        my $matched_role = 0;
                        foreach my $allowed_role ( @{ $tree->getNodeValue->access_only } )
                        {
                            $matched_role = 1 if ( $allowed_role eq $show_role );
                        }
                        $color = 'red'      unless $matched_role;
                        $color = 'green'    if $matched_role;

                    }
                    else
                    {
                        $color    = 'yellow';
                    }

                    if ( $color )
                    {
                        # decide what links to draw..
                        my $links='';
                        if ( $color eq 'yellow' )
                        {
                            $links.="<a href='" . $c->uri_for($c->controller('AppKitAdmin::Access')->action_for( 'action_rule_for_role' ), [ $show_role ], 'deny',  $tree->getNodeValue->action_path ) . "'>D</a>  ";
                            $links.="<a href='" . $c->uri_for($c->controller('AppKitAdmin::Access')->action_for( 'action_rule_for_role' ), [ $show_role ], 'allow',  $tree->getNodeValue->action_path ) . "'>A</a> ";
                        }
                        elsif ( $color eq 'green' )
                        {
                            $links.="<a href='" . $c->uri_for($c->controller('AppKitAdmin::Access')->action_for( 'action_rule_for_role' ), [ $show_role ], 'revoke',  $tree->getNodeValue->action_path ) . "'>R</a> ";
                            $links.="<a href='" . $c->uri_for($c->controller('AppKitAdmin::Access')->action_for( 'action_rule_for_role' ), [ $show_role ], 'deny',  $tree->getNodeValue->action_path ) . "'>D</a>   ";
                        }
                        elsif ( $color eq 'red' )
                        {
                            $links.="<a href='" . $c->uri_for($c->controller('AppKitAdmin::Access')->action_for( 'action_rule_for_role' ), [ $show_role ], 'revoke',  $tree->getNodeValue->action_path ) . "'>R</a> ";
                            $links.="<a href='" . $c->uri_for($c->controller('AppKitAdmin::Access')->action_for( 'action_rule_for_role' ), [ $show_role ], 'allow',  $tree->getNodeValue->action_path ) . "'>A</a>  ";
                        }
                        $node_string = "<font color='$color'>" . $node_string . "</font>" . $links;
                    }
                }
                return $node_string;
            }
        )
    );  
    $c->stash->{access_control_role_tree} = $tree_view;

    # have a look at the user roles parameters...
    my $test_string = '';
    if ( $c->user )
    {
        foreach my $role_name ( $c->user->roles )
        {
            my $role = $c->model('AppKitAuthDB::Role')->find( { role => $role_name } );
            $test_string .= "$role_name (" . $role->role . ') - ';

            my $h = $role->params_hash;

            foreach my $p ( keys %$h )
            {
                $test_string .= $p . ' : ' . $h->{$p};
            }
        }
    }

    # manually set (as we may forward to this action).
    $c->stash->{template} = 'appkitadmin/access/show_role.tt';
}

1;
__END__
