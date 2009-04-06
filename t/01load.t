#!/usr/bin/perl -w
use strict;
use lib 't';
use BookDB;

use Test::More tests => 7;

# ------------------------------------------------------------------------

my $class = 'Data::Phrasebook';
use_ok $class;

my ($mock,$nomock);

BEGIN {
	eval "use Test::MockObject";
	$nomock = $@;

	if(!$nomock) {
		$mock = Test::MockObject->new();
		$mock->fake_module( 'DBI', 
					'connect' =>\&BookDB::connect,
					'prepare' =>\&BookDB::prepare,
					'prepare_cached' =>\&BookDB::prepare_cached,
					'rebind' =>\&BookDB::rebind,
					'bind_param' =>\&BookDB::bind_param,
					'execute' =>\&BookDB::execute,
					'fetchrow_hashref' =>\&BookDB::fetchrow_hashref,
					'fetchall_arrayref' =>\&BookDB::fetchall_arrayref,
					'fetchrow_array' =>\&BookDB::fetchrow_array,
					'finish' =>\&BookDB::finish);
		$mock->fake_new( 'DBI' );
		$mock->mock( 'connect', \&BookDB::connect );
		$mock->mock( 'prepare', \&BookDB::prepare );
		$mock->mock( 'prepare_cached', \&BookDB::prepare_cached );
		$mock->mock( 'rebind', \&BookDB::rebind );
		$mock->mock( 'bind_param', \&BookDB::bind_param );
		$mock->mock( 'execute', \&BookDB::execute );
		$mock->mock( 'fetchrow_hashref', \&BookDB::fetchrow_hashref );
		$mock->mock( 'fetchall_arrayref', \&BookDB::fetchall_arrayref );
		$mock->mock( 'fetchrow_array', \&BookDB::fetchrow_array );
		$mock->mock( 'finish', \&BookDB::finish );
	}
}
	
my %file = (
	dsn	      => 'dbi:Mock:database=test',
	dbuser    => 'user',
	dbpass    => 'pass',
    dbtable   => 'phrasebook',
    dbcolumns => ['keyword','phrase','dictionary'],
);

my $dict = 'base';

# ------------------------------------------------------------------------

SKIP: {
	skip "Test::MockObject required for testing", 2 if $nomock;

    my $obj = $class->new(
        loader    => 'DBI',
		file      => \%file,
	);
    isa_ok( $obj => $class.'::Plain', "Bare new" );
    $obj->dict( $dict );
    is( $obj->dict() => $dict , "Set/get dict works");
}

SKIP: {
	skip "Test::MockObject required for testing", 4 if $nomock;

    my $obj = $class->new(
		dict      => $dict,

        loader    => 'DBI',
		file      => \%file,
	);
    isa_ok( $obj => $class.'::Plain', "New with dict" );
    is( $obj->dict() => $dict , "Get dict works");

    {
        my $str = $obj->fetch( 'foo', {
                my => "Iain's",
                place => 'locale',
            });

        is ($str, "Welcome to Iain's world. It is a nice locale.",
            "Fetch matches" );
    }

    {
        $obj->delimiters( qr{ :(\w+) }x );

        my $str = $obj->fetch( 'bar', {
                my => "Bob's",
                place => 'whatever',
            });

        is ($str, "Welcome to Bob's world. It is a nice whatever.",
            "Fetch matches" );
    }
}

