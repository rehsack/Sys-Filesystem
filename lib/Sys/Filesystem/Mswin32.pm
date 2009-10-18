############################################################
#
#   $Id: Mswin32.pm 368 2006-03-23 17:38:56Z nicolaw $
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

package Sys::Filesystem::Mswin32;
# vim:ts=4:sw=4:tw=78

use strict;
use FileHandle;
use Win32::DriveInfo;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.05';

sub new {
	ref(my $class = shift) && croak 'Class name required';
	my %args = @_;
	my $self = { };

	my @volumes = Win32::DriveInfo::DrivesInUse();

	for my $volume (@volumes) {
		my $type = Win32::DriveInfo::DriveType($volume);
		my ($VolumeName,
			$VolumeSerialNumber,
			$MaximumComponentLength,
			$FileSystemName,
			@attr) = Win32::DriveInfo::VolumeInfo($volume);

		$self->{$VolumeName}->{mount_point} = $VolumeName;
		$self->{$VolumeName}->{device} = $FileSystemName;
		$self->{$VolumeName}->{mounted} = 1;
	}

	bless($self,$class);
	return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Mswin32 - Return Win32 filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 VERSION

$Id: Mswin32.pm 368 2006-03-23 17:38:56Z nicolaw $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

L<http://perlgirl.org.uk>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut



