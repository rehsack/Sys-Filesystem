use Test::More tests => 3;
use Sys::Filesystem;
use Cwd qw(abs_path);
use Config;

my $RealTest = abs_path(__FILE__);
my $RealPerl = $Config{perlpath};
if ( $^O ne 'VMS' )
{
    $RealPerl .= $Config{_exe}
      unless $RealPerl =~ m/$Config{_exe}$/i;
}

my $sfs = Sys::Filesystem->new();
ok( ref($sfs) eq 'Sys::Filesystem', 'Create new Sys::Filesystem object' );

if( $sfs->supported() )
{
my ( $binmount, $mymount );

my @mounted_filesystems = sort { length($b) <=> length($a) } $sfs->filesystems( mounted => 1 );
foreach my $fs (@mounted_filesystems)
{
    if ( !defined($binmount) && ( 0 == index( $RealPerl, $fs ) ) )
    {
        $binmount = $fs;
    }

    if ( !defined($mymount) && ( 0 == index( $RealTest, $fs ) ) )
    {
        $mymount = $fs;
    }
}
ok( $mymount,  sprintf( q{Found mountpoint for test file '%s' at '%s'}, $RealTest,   $mymount  || '<n/a>' ) );
ok( $binmount, sprintf( q{Found mountpoint for perl executable '%s' at '%s'},  $RealPerl, $binmount || '<n/a>' ) );
}
else
{
	SKIP:
	{
		skip( "Operating system $^O isn't supported", 2 );
	}
}
