package BookDB;

my $dbh;
my $bind = '';
my $oldq = '';

sub new
{
	my $self = shift;

	# create an attributes hash
	my $atts = {
		'sql'	=> undef,
		'res'	=> [0],
	};

	# create the object
	bless $atts, $self;
	$dbh = $atts;
	return $atts;
}

use Data::Dumper;

my @sql = (
	['foo','Welcome To My World']);

sub prepare { 
	shift; #print STDERR "\n#prepare=".Dumper(\@_);
	$dbh->{sql} = shift;
	$dbh->{cache} = shift;
	$dbh 
}
sub prepare_cached { 
	shift; #print STDERR "\n#prepare_cached=".Dumper(\@_);
	$dbh->{sql} = shift;
	$dbh->{cache} = shift;
	$dbh 
}
sub rebind {
	shift; 
	$dbh->{sql} = $dbh->{cache};
}
sub bind_param {
	shift;
#print STDERR "\n#bind_param(@_)\n";
	$bind = $_[1];
	return;
}
sub execute {
	shift; 
	my $query = $dbh->{sql} || $oldq;
	my $arg = @_ ? $_[0] : $bind;

	$bind = $arg;
	$oldq = $query;
	return	unless($query);

#print STDERR "\n# query=[$query]\n";
#print STDERR "\n# arg=[$arg]\n";

	if($query =~ /SELECT phrase FROM  phrasebook WHERE keyword=\? AND   dictionary=\?/) {
		if($arg && $arg =~ /foo/) {
		$dbh->{array} = ['Welcome to [% my %] world. It is a nice [% place %].'];
		}
	}

	elsif($query =~ /SELECT phrase FROM  phrasebook WHERE keyword=\?/) {
		if($arg && $arg =~ /foo/) {
		$dbh->{array} = ['Welcome to [% my %] world. It is a nice [% place %].'];
		}
	}

    elsif($query =~ /SELECT dictonary FROM  phrasebook/) {
		$dbh->{array} = [['DEF'],['ONE']];
	}
}
sub fetchrow_hashref {
	return shift @{$dbh->{hash}}}
sub fetchall_arrayref {
	return \@{$dbh->{array}}}
sub fetchrow_array {
	return shift @{$dbh->{array}}}
sub finish { $dbh->{sql} = undef }

sub connect { new(@_); $dbh }

sub can { 1 }

DESTROY { }

END { }

1;

