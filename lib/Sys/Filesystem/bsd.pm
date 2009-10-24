############################################################
#
#   $Id: Freebsd.pm 364 2006-03-23 15:22:19Z nicolaw $
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright 2009           Jens Rehsack
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
############################################################

package Sys::Filesystem::bsd;

# vim:ts=4:sw=4:tw=78

use strict;

use vars qw($VERSION);
$VERSION = '1.25';

sub get_mounts
{
    my ( $self, $mount_rx, $pridx, $keys, $special, @lines ) = @_;
    foreach my $line (@lines)
    {
        if ( my @vals = $line =~ $mount_rx )
        {
            my $vfs_type;
            $self->{ $vals[ $pridx->[1] ] }->{mount_point} = $vals[ $pridx->[1] ];
            $self->{ $vals[ $pridx->[1] ] }->{device}      = $vals[ $pridx->[0] ];
            $vfs_type = $self->{ $vals[ $pridx->[1] ] }->{fs_vfstype} = $vals[ $pridx->[2] ];
            $self->{ $vals[ $pridx->[1] ] }->{mounted} = 1;
            delete $self->{ $vals[ $pridx->[1] ] }->{unmounted};
            $self->{ $vals[ $pridx->[1] ] }->{special} = 1 if grep( /^$vfs_type$/, @$special );
            for ( my $i = 0; $i < @$keys; $i++ )
            {
                $self->{ $vals[ $pridx->[1] ] }->{ $keys->[$i] } = $vals[$i];
            }
        }
    }
    $self;
}

sub get_swap
{
    my ( $self, $swap_rx, @lines ) = @_;
    foreach my $line (@lines)
    {
        if ( my ($dev) = $line =~ $swap_rx )
        {
            $self->{none}->{mount_point} ||= 'none';
            $self->{none}->{device}     = $dev;
            $self->{none}->{fs_vfstype} = 'swap';
            $self->{none}->{mounted}    = 1;
            $self->{none}->{special}    = 1;
            delete $self->{none}->{unmounted};
        }
    }
    $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::bsd - parses the mounted file systems and swap devices for BSD operating systems

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 VERSION

$Id$

=head1 METHODS

=over 4

=item get_mounts

This method is called to parse the information got from C<mount> system command.
It expects following arguments:

=over 8

=item mount_rx

Regular expression to extract the information from each mount line.

=item pridx

Array reference containing the index for primary keys of interest in match
in following order: device, mount_point, type.

=item keys

Array reference of the columns of the match - in order of paranteses in
regular expression.

=item special

Array reference containing the names of the special file system types.

=item lines

Array containing the lines to parse.

=back

=item get_swap

This method is called to parse the information from the swap status.
It expects following arguments:

=over 8

=item swap_rx

Regular expression to extract the information from each swap status line.
This regular expression should have exact one pair of parantheses to
identify the swap device.

=item lines

Array containing the lines to parse.

=back

=back

=head1 AUTHOR

Jens Rehsack <rehsack@cpan.org>

L<http://www.rehsack.de/>

=head1 COPYRIGHT

Copyright 2009 Jens Rehsack.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut

