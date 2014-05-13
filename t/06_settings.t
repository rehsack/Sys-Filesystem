#!perl

use strict;
use warnings;

use Test::More;
use Sys::Filesystem;

my ( $fs, @filesystems );
eval { $fs = Sys::Filesystem->new(); };

$@ and plan skip_all => "Cannot initialize Sys::Filesystem: $@";

$fs = Sys::Filesystem->new(canondev => 1);
@filesystems = $fs->filesystems;

for my $filesystem (@filesystems)
{
    my $device;
    ok( $device = $fs->device($filesystem), "Get device for $filesystem" );
    ok(!-l $device, "$device is not a symlink");
}

done_testing;
