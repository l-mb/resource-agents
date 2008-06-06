#!/usr/bin/perl

use Getopt::Std;
use Net::Telnet ();

# Get the program name from $0 and strip directory names
$_=$0;
s/.*\///;
my $pname = $_;

# WARNING!! Do not add code bewteen "#BEGIN_VERSION_GENERATION" and
# "#END_VERSION_GENERATION"  It is generated by the Makefile

#BEGIN_VERSION_GENERATION
$RELEASE_VERSION="";
$REDHAT_COPYRIGHT="";
$BUILD_DATE="";
#END_VERSION_GENERATION


sub usage 
{
    print "Usage:\n\n"; 
    print "$pname [options]\n\n";
    print "Options:\n";
    print "  -a <ip>          IP address or hostname of switch\n";
    print "  -h               Usage\n";
    print "  -n <num>         Port number to disable\n";
    print "  -p <string>      Password for login\n";
    print "  -S <path>        Script to run to retrieve login password\n";
    print "  -V               version\n\n";

    exit 0;
}

sub fail
{
  ($msg) = @_;
  print $msg."\n" unless defined $opt_q;
  $t->close if defined $t;
  exit 1;
}

sub fail_usage
{
  ($msg) = @_;
  print STDERR $msg."\n" if $msg;
  print STDERR "Please use '-h' for usage.\n";
  exit 1;
}

sub version
{
  print "$pname $RELEASE_VERSION $BUILD_DATE\n";
  print "$REDHAT_COPYRIGHT\n" if ( $REDHAT_COPYRIGHT );

  exit 0;
}

if (@ARGV > 0) {
    getopts("a:hn:p:S:V") || fail_usage ;

    usage if defined $opt_h;
    version if defined $opt_V;

    fail_usage "Unknown parameter." if (@ARGV > 0);

    fail_usage "No '-a' flag specified." unless defined $opt_a;

	if (defined $opt_S) {
		$pwd_script_out = `$opt_S`;
		chomp($pwd_script_out);
		if ($pwd_script_out) {
			$opt_p = $pwd_script_out;
		}
	}

    fail_usage "No '-p' or '-S' flag specified." unless defined $opt_p;
    fail_usage "No '-n' flag specified." unless defined $opt_n;

} else {
    get_options_stdin();

    fail "failed: no IP address for the Vixel." unless defined $opt_a;

	if (defined $opt_S) {
		$pwd_script_out = `$opt_S`;
		chomp($pwd_script_out);
		if ($pwd_script_out) {
			$opt_p = $pwd_script_out;
		}
	}

    fail "failed: no password provided." unless defined $opt_p;
    fail "failed: no port number specified." unless defined $opt_n;
}

#
# Set up and log in
#

$t = new Net::Telnet;

$t->open($opt_a);

$t->waitfor('/assword:/');

$t->print($opt_p);

($out, $match)= $t->waitfor(Match => '/\>/', Match => '/assword:/');

if ($match =~ /assword:/) {
  fail "failed: incorrect password\n";
} elsif ( $match !~ />/ ) {
  fail "failed: timed out waiting for prompt\n";
}
 
$t->print("config");

$t->waitfor('/\(config\)\>/');

$t->print("zone");

$t->waitfor('/\(config\/zone\)\>/');

#
# Do the command
#

$cmd = "config $opt_n \"\"";
$t->print($cmd);

$t->waitfor('/\(config\/zone\)\>/');

$t->print("apply");

($text, $match) = $t->waitfor('/\>/');
if ($text !~ /[Oo][Kk]/) {
	fail "failed: error from switch\n";
}

$t->print("exit");

print "success: zonedisable $opt_n\n";
exit 0;


sub get_options_stdin
{
	my $opt;
	my $line = 0;

	while( defined($in = <>) )
	{
		$_ = $in;
		chomp;

		# strip leading and trailing whitespace
		s/^\s*//;
		s/\s*$//;

		# skip comments
		next if /^#/;

		$line+=1;
		$opt=$_;
		next unless $opt;

		($name,$val)=split /\s*=\s*/, $opt;

		if ( $name eq "" ) {
			print("parse error: illegal name in option $line\n");
			exit 2;
		} 

		# DO NOTHING -- this field is used by fenced
		elsif ($name eq "agent" ) { }

		# FIXME -- depricated.  use "port" instead.
		elsif ($name eq "fm" ) {
			(my $dummy,$opt_n) = split /\s+/,$val;
			print STDERR "Depricated \"fm\" entry detected. Refer to man page.\n";
		} 
		elsif ($name eq "ipaddr" ) 
		{
			$opt_a = $val;
		} 
		elsif ($name eq "name" ) { }
		elsif ($name eq "passwd" ) 
		{
			$opt_p = $val;
		}
		elsif ($name eq "passwd_script" )
		{
			$opt_S = $val;
		} 
		elsif ($name eq "port" ) 
		{
			$opt_n = $val;
		} 
	}
}

