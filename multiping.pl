#!/usr/bin/env perl -w

use strict;
use warnings;
use feature 'say';

use Pod::Usage;
use Getopt::Long;
use Net::Ping; 	# Calls in Net::Ping::External also, as we use the
		# 'external' method for ping - otherwise we'd have to
		# run this script as root, or suid it.

my $RELEASE = '0.1';
my $INTERVAL = 1;
my $COUNT = -1; # Default infinite ping loop

parseCommandLineArguments();
runPing($COUNT,@ARGV) if (@ARGV);

sub parseCommandLineArguments
{
	# pod2usage ripped from http://www.perlmonks.org/?node_id=521812
	my $HELP	= 0;   # Show help overview.
	my $MANUAL	= 0;   # Show manual
	my $VERSION	= 0;   # Show version number and exit.

	#  Parse options. - switch to using a hash, thanks GAE.
	# https://metacpan.org/pod/Getopt::Long#Storing-options-values-in-a-hash
	GetOptions(
		"help",		\$HELP,
		"manual",	\$MANUAL,
		"version|V",	\$VERSION,
		"interval|i=i",	\$INTERVAL,
		"count|c=i",	\$COUNT
	);
    
	pod2usage(1) if $HELP;
	pod2usage(-verbose => 2 ) if $MANUAL;

	if ( $VERSION )
	{
		say "multiping release $RELEASE";
		exit;
	}
}


sub runPing
{
	my $limit = shift;
	my @hosts = @_;

	my $infinite = ($limit == -1);

	my $p = Net::Ping->new("external");
	$p->hires();

	for (my $count = 0; $count < $limit or $infinite; $count++, sleep $INTERVAL) {
		unless ( $count % 20 ) {
			say '-'x75;
			foreach my $host (@hosts) {
				printf("%16.15s",$host);
			}
			say "\n",'-'x75;
		}

		foreach my $host (@hosts) {
			my ($ret, $duration, $ip);
			eval {
				local $SIG{ALRM} = sub { die "alarm\n" };
				alarm 1;
				($ret, $duration, $ip) = $p->ping($host, 1);
				alarm 0;
			};
			alarm 0;
			if ($@) {
				die unless $@ eq "alarm\n";
				printf("%16.15s", "timed out");
			}
			else {
				my $rtt;
				printf("%16.15s", sprintf("%.2f ms", 1000 * $duration)) if $ret;
			}
		}
		print "\n";
	}
}

=head1 NAME

multiping - A simple tool to ping multiple hosts at the same time

=head1 SYNOPSIS

  multiping [options] host...

  Help Options:
   hosts	Hosts to ping - at least one required

=cut

=head1 OPTIONS

=over 8

=item B<--count|-c>
Number of pings to do before exiting (default: infinite)

=item B<--interval|-i>
Number of seconds between pings (default: 1)

=item B<--help>
Show the brief help information.

=item B<--manual>
Read the manual, with examples.

=item B<--version>

=back

=cut

=head1 EXAMPLES

The following is an example usage of this script:

multiping.pl host1 host2 host3 host4 host5

This will run multiping.pl in default mode, one second intervals and
infinite

multiping.pl -c 1 host1 host2

This will run multiping.pl with one probe, across multiple hosts

=cut

=head1 DESCRIPTION

 This script will ping multiple hosts in a round-robin fashion, this allows
users to see what patterns appear during certain scenarios, such as network
testing, failovers, intermittent packet loss.
 It is expected that this will help more quickly narrow down where unexpected
issues lie.
 Script is initially designed for human consumption. For automation with
other tools, I can recommend fping.

=cut

=head1 AUTHOR

 Siraj 'Sid' Rakhada
 --
 http://github.com/tidalvirus/multiping

=cut

=head2 runPing

  Run the main ping process

=cut
