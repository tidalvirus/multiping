#!/usr/bin/env perl -w

=head1 NAME

multiping - A simple tool to ping multiple hosts at the same time

=head1 SYNOPSIS

  multiping [options] [hosts]

  Help Options:
   [hosts]	Hosts to ping - at least one required

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

use strict;
use Pod::Usage;
use Getopt::Long;
use Net::Ping; 	# Calls in Net::Ping::External also, as we use the
		# 'external' method for ping - otherwise we'd have to
		# run this script as root, or suid it.

my $RELEASE = '0.1';
my $INTERVAL = 1;
my $COUNT = -1; # Default infinite ping loop

#
# Parse command line arguments.  These override the values from the
# configuration file.
#
parseCommandLineArguments();

=head2 parseCommandLineArguments

  Parse the arguments specified upon the command line.

=cut

sub parseCommandLineArguments
{
	# pod2usage ripped from http://www.perlmonks.org/?node_id=521812
	my $HELP	= 0;   # Show help overview.
	my $MANUAL	= 0;   # Show manual
	my $VERSION	= 0;   # Show version number and exit.

	#  Parse options.
	#
	GetOptions(
		"help",		\$HELP,
		"manual",	\$MANUAL,
		"version|V",	\$VERSION,
       		"interval|i=i",	\$INTERVAL,
		"count|c=i",	\$COUNT
	);
    
	pod2usage(1) if $HELP;
	pod2usage(-verbose => 2 ) if $MANUAL;

	runPing($COUNT,@ARGV) if(scalar(@ARGV) >0);

	if ( $VERSION )
	{
		print "multiping release $RELEASE\n";
		exit;
	}
}

=head2 runPing

  Run the main ping process

=cut

sub runPing
{
	my $limit = shift;
	my @hosts = @ARGV;
	my $infinite = 0;
	$infinite = 1 if $limit == -1;
	$limit = 2 if $infinite; # Need to improve the infinite loop thing

	my $p = Net::Ping->new("external");
	$p->hires();

	for (my $count = 0; $count < $limit; $count++, sleep $INTERVAL) {
		if($infinite) { $limit++;} # always increase limit for infinity
		if( !($count % 20) ) {
			print '-'x75,"\n";
			foreach my $host (@hosts) {
				printf("%16.15s",$host);
			}
			print "\n",'-'x75,"\n";
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
				printf("%16.15s","timed out");
			}
			else {
				my $rtt;
				printf("%16.15s",sprintf("%.2f ms", 1000 * $duration)) if $ret;
			}
		}
		print "\n";
	}
}
