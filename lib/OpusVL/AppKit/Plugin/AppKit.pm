package OpusVL::AppKit::Plugin::AppKit;

=head1 NAME

    OpusVL::AppKit::Plugin::AppKit - Common functions to get OpusVL::AppKit working.

=head1 DESCRIPTION

    Poeple not developing the AppKit should not really need to know much about this plugin.

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
                ( $comp->isa('Catalyst::Controller')    ) &&
                ( $comp->can('appkit_name')             ) &&
                ( $comp->appkit_name ne 'AppKit'        ) &&
                ( $comp->isa('OpusVL::AppKit::Base::Controller::GUI') )
            )
        {   
            push( @controllers, $comp );
        }
    }

    return \@controllers;
}

###########################################################################################################################
# catalyst hook.
###########################################################################################################################
=head2 execute
    The method that hooks into the catalyst despatch chain.

    If the current logged in used is denised access to the action this will detach to the 'access_denied' action.
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
                $c->log->debug("AppKit - Not Allowed Access - Detaching to - $path ") if $c->debug;
                $c->detach( $path, [$action, "Access Denied"] );
            }
        }
    }

    $c->maybe::next::method( $class, $action );
}

###########################################################################################################################
# plugin methods.
###########################################################################################################################

=head2 can_access
    Checks the Authorization::ACL structure against the current user and action.
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

    my @action_path     = grep { $_ ne "" } split( "/", $action_path );
    my $action_name     = pop @action_path;

    # we can always access _INTERNAL methods..
    return 1 if $action_name =~ /^\_/;

    # need to now match the action_path with a rule (closest match wins)
    my $matched_rules;
    RULE: foreach my $rule_action_path ( keys %{ $c->config->{'OpusVL::AppKit::Plugin::AppKit'}->{'acl_rules'} } )
    {

        #$c->log->debug("AppKit ACL : Checking: $rule_action_path FOR: $action_path ") if $c->debug;

        if ( $action_path =~ /^$rule_action_path/ )
        {
            # This rule matches the action path..
            $matched_rules->{ $rule_action_path } = length( $rule_action_path );
        }
    }

    # allow access if not matches..
    return 1 unless keys %$matched_rules;

    # now check the roles the rule defines. (longest, most speficic, wins )..
    my $rule_action_path = first { $_ } sort { $matched_rules->{$a} <=> $matched_rules->{$b}  } keys %$matched_rules;

    $c->log->debug("AppKit ACL : Matched Rule: $rule_action_path FOR: $action_path ") if $c->debug;

    # now check if the user has one of the roles allowed..
    my $allowed_roles = $c->config->{'OpusVL::AppKit::Plugin::AppKit'}->{'acl_rules'}->{ $rule_action_path };
    $allowed_roles = [ $allowed_roles ] unless ref $allowed_roles eq 'ARRAY';

    # return a test that will check for the roles
    return $c->check_user_roles( @$allowed_roles );
}

__PACKAGE__->meta->make_immutable;
__PACKAGE__;
__END__
