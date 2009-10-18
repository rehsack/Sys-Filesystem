############################################################
#
#   $Id: Unix.pm 364 2006-03-23 15:22:19Z nicolaw $
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright 2004,2005,2006 Nicola Worthington
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

package Sys::Filesystem::Unix;
# vim:ts=4:sw=4:tw=78

use strict;
use FileHandle;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.05';

sub new {
	ref(my $class = shift) && croak 'Class name required';
	my %args = @_;
	my $self = { };

	# Defaults
	$args{fstab} ||= '/etc/fstab';
	$args{mtab} ||= '/etc/mtab';
	$args{xtab} ||= '/etc/lib/nfs/xtab';

	# Default fstab and mtab layout
	my @keys = qw(fs_spec fs_file fs_vfstype fs_mntops fs_freq fs_passno);
	my @special_fs = qw(swap proc);

	# Read the fstab
	my $fstab = new FileHandle;
	if ($fstab->open($args{fstab})) {
		while (<$fstab>) {
			next if /^\s*#/;
			next if /^\s*$/;

			my @vals = split(/\s+/, $_);
			$self->{$vals[1]}->{mount_point} = $vals[1];
			$self->{$vals[1]}->{device} = $vals[0];
			$self->{$vals[1]}->{unmounted} = 1;
			$self->{$vals[1]}->{special} = 1 if grep(/^$vals[2]$/,@special_fs);
			for (my $i = 0; $i < @keys; $i++) {
				$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
			}
		}
		$fstab->close;
	}

	# Read the mtab
	my $mtab = new FileHandle;
	if ($mtab->open($args{mtab})) {
		while (<$mtab>) {
			next if /^\s*#/;
			next if /^\s*$/;
			my @vals = split(/\s+/, $_);
			delete $self->{$vals[1]}->{unmounted} if exists $self->{$vals[1]}->{unmounted};
			$self->{$vals[1]}->{mounted} = 1;
			$self->{$vals[1]}->{mount_point} = $vals[1];
			$self->{$vals[1]}->{device} = $vals[0];
			for (my $i = 0; $i < @keys; $i++) {
				$self->{$vals[1]}->{$keys[$i]} = $vals[$i];
			}
		}
		$mtab->close;
	}

	bless($self,$class);
	return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Unix - Return generic Unix filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 VERSION

$Id: Unix.pm 364 2006-03-23 15:22:19Z nicolaw $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

L<http://perlgirl.org.uk>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut


