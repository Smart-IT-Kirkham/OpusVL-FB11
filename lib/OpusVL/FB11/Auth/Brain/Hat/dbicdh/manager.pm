package OpusVL::FB11::Auth::Brain::Hat::dbicdh::manager;

# ABSTRACT: Default DBIDCH manager
our $VERSION = '1';

use v5.24;
use File::ShareDir 'module_dir';
use List::UtilsBy qw/sort_by/;
use OpusVL::FB11::DeploymentHandler;
use Try::Tiny;

use Moose;
with 'OpusVL::FB11::Role::Hat::dbicdh::manager';

=head1 DESCRIPTION

Since the core deployment handler schema is the FB11AuthDB, it follows that the
core deployment handler manager is on the brain that interfaces with it.

To use it, simply ensure the Auth brain is in your hive. See
L<OpusVL::FB11::Auth::Brain>.

=cut

sub deploy_and_upgrade {
    my $self = shift;
    my $hive = shift;

    my @dh_consumers = sort_by {$_->sequence} $hive->hats('dbicdh::consumer');

    for my $hat (@dh_consumers) {
        my $schema = $hat->schema;
        my $deploy_version = $hat->start_at;
        my $upgrade_version = $schema->schema_version;
        my $module = ref $schema;

        my $dh = OpusVL::FB11::DeploymentHandler->new({
            schema => $schema,
            script_directory => module_dir(ref $schema) . '/sql',
            to_version => $upgrade_version,
        });

        my $v_current = try { $dh->database_version } catch {0};
        unless ($v_current) {
            say "Deploying $module at $deploy_version";
            my $ddl = $dh->deploy({
                version => $deploy_version
            });
            $dh->add_database_version({
                version => $deploy_version,
                ddl => $ddl,
            });
        }

        say "Upgrading $module from $v_current to $upgrade_version";
        $dh->upgrade;
    }
}

1;
