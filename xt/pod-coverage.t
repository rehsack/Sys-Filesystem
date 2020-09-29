#! perl

use strict;
use warnings;

use Test::More;
use Test::Pod::Coverage;

$^O ne 'MSWin32' and eval <<EOLIE;
package
Win32::DriveInfo;
1;
EOLIE
$^O ne 'MSWin32' and $INC{"Win32/DriveInfo.pm"} = "mocked";

all_pod_coverage_ok(
    {
        also_private => [qr/^[A-Z_]+$/],
        trustme      => [qr/^new$/]
    }
);
