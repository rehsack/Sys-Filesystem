use Test::More qw(no_plan);
use Sys::Filesystem;

my $fs = Sys::Filesystem->new();
ok( ref($fs) eq 'Sys::Filesystem', 'Create new Sys::Filesystem object' );

my @special_filesystems   = $fs->special_filesystems();
my @regular_filesystems = $fs->regular_filesystems();

SKIP:
{
    unless (@regular_filesystems)
    {
        skip('Badly poor supported OS or no file systems found.');
    }
    else
    {
        ok( @regular_filesystems, 'Get list of regular filesystems' );

        for my $filesystem (@regular_filesystems)
        {
	    my $special = $fs->special($filesystem) || 0;
	    ok( !$special, "Regular" );
	}
    }
}

SKIP:
{
    unless (@special_filesystems)
    {
        skip('Badly poor supported OS or no file systems found.');
    }
    else
    {
        ok( @special_filesystems, 'Get list of regular filesystems' );

        for my $filesystem (@special_filesystems)
        {
	    my $special = $fs->special($filesystem) || 0;
	    ok( $special, "Special" );
	}
    }
}
