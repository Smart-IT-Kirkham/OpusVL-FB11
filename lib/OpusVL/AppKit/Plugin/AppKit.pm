package OpusVL::AppKit::Plugin::AppKit;

=head1 NAME

    OpusVL::AppKit::Plugin::AppKit - Common functions to get OpusVL::AppKit working.

=head1 DESCRIPTION

    People not developing the actual AppKit should not really need to know much about this plugin.

    It is used by the OpusVL::AppKit which intended to be inherited by another Catalyst App using 
    CatalystX::AppBuilder..

=head1 METHODS

=cut

###########################################################################################################################
# use lines.
###########################################################################################################################
use namespace::autoclean;
use Moose;
use List::Util 'first';
use Tree::Simple;
use OpusVL::AppKit::Plugin::AppKit::ActionNode;

###########################################################################################################################
# moose calls.
###########################################################################################################################
with 'Catalyst::ClassData';

has appkit_controllers => ( is => 'ro',    isa => 'ArrayRef',  lazy_build => 1 );
sub _build_appkit_controllers
{   
    my ( $c ) = shift;

    my @controllers;

    # Get all the components for this app...
    foreach my $comp ( values %{ $c->components } )
    {   
        # Check this is a controller..
        if  (
                ( $comp->isa('Catalyst::Controller')    )               &&
                ( $comp->isa('OpusVL::AppKit::Base::Controller::GUI') ) &&
                ( $comp->can('appkit_name')             )               &&
                ( defined $comp->appkit_name            )               &&
                ( $comp->appkit_name ne 'AppKit'        )               
            )
        {   
            push( @controllers, $comp );
        }
    }
    return \@controllers;
}

has appkit_actiontree => ( is => 'ro',    isa => 'Tree::Simple',  lazy_build => 1 );
sub _build_appkit_actiontree
{   
    my ( $c ) = shift;

    # make a tree root (based on code from Catalyst::Plugin::Authorization::ACL::Engine)
    my $root = Tree::Simple->new('AppKit', Tree::Simple->ROOT);

    AKCONTROLLERS: foreach my $cont ( @{ $c->appkit_controllers } )
    {   
        # Loop through all this AppKit controllers actionmethods...
        AKACTIONS: foreach my $action_method ( $cont->get_action_methods )
        {   
            next if $action_method->name =~ /^_/;

            my $action = $cont->action_for( $action_method->name );
            next unless defined $action;

            # Deal with path...
            my $action_path = $action->reverse;
            my @path = split '/', $action_path;
            my $name = pop @path;

            # build AppKit::ActionNode object...
            my $appkit_action_object = OpusVL::AppKit::Plugin::AppKit::ActionNode->new
            (
                node_name   => $name,
                controller  => $cont,
                action_path => $action_path,
            );

            # look for any ACL rules for this action_path...
            if ( my $allowed_roles = $c->_appkit_allowed_roles( $action_path ) )
            {
                $appkit_action_object->access_only( $allowed_roles );
            }

            # If this is deeper than a top level action_path...
            # See if we have already added it into the tree..
            # ..if so, add a child to it and loop..
            if (@path)
            {   

                # Need to check this!!.. we have changed from building the tree from strings (string/string) to 
                # a tree of objects... probably need to create a custom Visitor...
                my $by_path = Tree::Simple::Visitor::FindByPath->new;
                $by_path->setSearchPath(@path);
                $root->accept($by_path);

                if ( my $namespace_node = $by_path->getResult )
                {   

                    # final 'belt and braches' check to see if we have already added it..
                    foreach my $kid ( $namespace_node->getAllChildren )
                    {
                        if ( $kid->getNodeValue->node_name eq $appkit_action_object->node_name )
                        {   
                            $c->debug->error("Action path $action_path, already in tree!!!??.. not a massive problem, but strange that it is happening");
                            next AKACTIONS
                        }
                    }

                    # add a child to the already created tree node....
                    $namespace_node->addChild( Tree::Simple->new( $appkit_action_object ) );
                    next;
                }
            }
            # here we add all of the required path for the action we are adding to the tree..
            my $node = $root;
            for my $path_part ( @path )
            {   
                my $found;
                foreach my $kid ( @{ $node->getAllChildren } )
                {   
                    my $kidnode =  $kid->getNodeValue;
                    if ( $path_part eq $kidnode->node_name )
                    {   
                        $found = $kid;
                    }
                }

                if  ( defined $found )
                {
                    $node = $found;
                }
                else
                {

                    # build AppKit::ActionNode object...(this is not an action, so is pretty minimal)...
                    my $branch_appkit_action_object = OpusVL::AppKit::Plugin::AppKit::ActionNode->new
                    (
                        node_name   => $path_part,
                        controller  => $cont,
                    );

                    # add tree branch..
                    $node = Tree::Simple->new( $branch_appkit_action_object, $node);
                }
            }

            # add the child/action name to the node we have found/created..
            $node->addChild( Tree::Simple->new( $appkit_action_object ) );
        }
    }

    # finished :) 
    return $root;
}
###########################################################################################################################
# catalyst hook.
###########################################################################################################################
=head2 execute
    The method hooks into the catalyst despatch path.
    If the current logged in used is denied access to the action this will detach to the 'access_denied' action.
=cut
sub execute 
{
    my ( $c, $class, $action ) = @_;

    #  to check roles we need the plugin
    $c->isa("Catalyst::Plugin::Authorization::Roles") or die "Please use the Authorization::Roles plugin.";

    my $access_denied_action_path = $c->config->{'OpusVL::AppKit::Plugin::AppKit'}->{'access_denied'};
    #$c->log->debug("************** AppKit - Access Denied Path - " . $access_denied_action_path );

    if  ( 
        Scalar::Util::blessed($action)
            and 
        $action->reverse ne $access_denied_action_path
        )
    {
        if ( $c->can_access( $action->reverse ) )
        {
            # do nothing..
            #$c->log->debug("************** AppKit - Allows Access - " . $action->reverse );
        }
        else
        {
            my @ad_path = split('/', $access_denied_action_path );
            my $ad_action_name = pop @ad_path; 
            my $ad_namespace = '';
            $ad_namespace = join('/', @ad_path) if @ad_path;

            #$c->log->debug("**** $ad_namespace **** $ad_action_name ****** AppKit - NO! Access - " . $action->reverse . " - Detaching to:" . $access_denied_action_path);

            if ( my $handler = ( $c->get_actions( $ad_action_name, $ad_namespace ) )[-1] )
            {
                (my $path = $handler->reverse) =~ s!^/?!/!;
                #$c->log->debug("AppKit - Not Allowed Access - Detaching to - $path ") if $c->debug;
                eval { $c->detach( $path, [$action, "Access Denied"] ) };
                die $@ || $Catalyst::DETACH;
            }
        }
    }

    $c->maybe::next::method( $class, $action );
}

###########################################################################################################################
# plugin methods.
###########################################################################################################################

=head2 can_access
    Checks the ACL structure against the current user and action.
    return 1 or 0 depending on if the user can access the action_path

    Used like so:
        if ( $c->can_access( 'controller/action/path' ) )
        {
            # $c->user must have the correct roles (or the action is not under ACL)..
        }
=cut
sub can_access
{   
    my $c               = shift;
    my ($action_path)   = @_;

    $c->log->warn("can_access called with a non-string action path: $action_path ") if ( ref $action_path );

    # find all allowed roles for this action path...
    my $allowed_roles = $c->_appkit_allowed_roles( $action_path );

    # if none found.. allow access..
    return 1 unless defined $allowed_roles;

    # return a test that will check for the roles
    return $c->check_user_roles( @$allowed_roles );
}

=head2 _appkit_allowed_roles
    Returns ArrayRef of roles that can can access the passed action path.
=cut
sub _appkit_allowed_roles
{   
    my $c               = shift;
    my ($action_path)   = @_;

    my @action_path     = grep { $_ ne "" } split( "/", $action_path );
    my $action_name     = pop @action_path;

    # always allow to method starting with underscore (_) ... typically they are internal methods..
    return undef if $action_name =~ /^_/;

    my $matched_rules;
    RULE: foreach my $aclrule ( $c->model('AppKitAuthDB::Aclrule')->search )
    {
        # see if this rule, matches the action we a checking??...
        my $rule_action_path = $aclrule->actionpath;
        if ( $action_path =~ /^$rule_action_path/ )
        {
            # it does match!.. (store it with its length)
            $matched_rules->{ $rule_action_path } = length( $rule_action_path );
        }
    }
    
    # allow access if not matches..
    return undef unless keys %$matched_rules;

    # now check the roles the rule defines. (longest, most speficic, wins .. no very good logic!)..
    my $rule_actionpath = first { $_ } sort { $matched_rules->{$b} <=> $matched_rules->{$a}  } keys %$matched_rules;

    $c->log->debug("AppKit ACL : Matched Rule: $rule_actionpath FOR: $action_path ") if $c->debug;

    # find the rule object that matches the path we found to be the closest match...
    my $rule = $c->model('AppKitAuthDB::Aclrule')->find( { actionpath => $rule_actionpath } );
    #.. pull out all the allowed roles for this rule..
    my $allowed_roles = [ map { $_->role } $rule->roles ];

    # return array ref of roles..
    return $allowed_roles;
}

=head2 _appkit_stash_portlets
    Put all the AppKit Controller Portlets data in the stash
    If you forward to this action, you should end up with a stash value keyed by 'portlets'.
        eg. $c->forward('stash_portlets');
    The value of 'portlets' is an ArrayRef of HashRefs.
    The HashRefs contain 2 keys:
        name    = The name of the portlet
        html    = The HTML content of the portlet
=cut
sub _appkit_stash_portlets 
{
    my ( $c ) = @_;
    my @portlets;
    foreach my $apc ( @{ $c->appkit_controllers } )
    {   
        next unless $apc->portlet_actions;
        foreach my $portlet ( @{ $apc->portlet_actions } )
        {   
            my $portlet_action = $apc->action_for( $portlet->{actionname} );

            # forward to the portlet action..
            $c->forward( $portlet_action );

            # take things from the stash (that the action should have just filled out)
            push
            (   
                @portlets,
                {   
                    name    => $portlet->{value},
                    html    => $c->stash->{portlet}->{html}
                }
            );
        }
    }
    $c->stash->{portlets} = \@portlets;
}

=head2 _appkit_stash_navigation
    Put all the AppKit Controller Navigation data in the stash
    If you forward to this action, you should end up with a stash value keyed by 'navigation'.
        eg. $c->forward('stash_navigation');
    The value of 'navigation' is an ArrayRef of HashRefs.
    The HashRefs contain 2 keys:
        text    = The text of the navigation item
        uri     = The uri if the action the navigation relates to.
=cut
sub _appkit_stash_navigation
{
    my ( $c ) = @_;
    my @navigations;
    foreach my $apc ( @{ $c->appkit_controllers } )
    {   
        next unless $apc->navigation_actions;
        foreach my $nav ( @{ $apc->navigation_actions } )
        {   
            my $nav_action = $apc->action_for( $nav->{actionname} );

            # test we can access this action..
            next unless $c->can_access( $nav_action->reverse );

            # build an array of navigation information...
            push
            (   
                @navigations,
                {   
                    text    => $nav->{value},
                    uri     => $c->uri_for( $nav_action ),
                }
            );
        }
    }
    $c->stash->{navigation} = \@navigations;
}

__PACKAGE__->meta->make_immutable;
__PACKAGE__;
__END__
