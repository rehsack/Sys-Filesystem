#! perl

use 5.008;
use strict;
use warnings;

use Test::More;
use Test::Pod::Coverage;

all_pod_coverage_ok(
                     {
                       also_private => [qr/^[A-Z_]+$/],
                       trustme      => [qr/^new$/]
                     }
                   );
