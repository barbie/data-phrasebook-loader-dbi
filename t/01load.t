#!/usr/bin/perl -w
use strict;
use lib 't';
use BookDB;

use Test::More tests => 21;

# ------------------------------------------------------------------------

my $class = 'Data::Phrasebook::Loader::DBI';
use_ok($class);

my $dbh = BookDB->new();
my $dsn = 'dbi:Mock:database=test';
my $dict = 'BASE';


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
	
# ------------------------------------------------------------------------

SKIP: {
	skip "Test::MockObject required for testing", 16 if $nomock;

    my $obj = $class->new();
    isa_ok($obj, $class);

	my $file = {
		dbh       => $dbh,
		dbcolumns => ['keyword','phrase','dictionary'],
        };

    eval { $obj->load( $file ); };
    ok($@);

	$file = {
		dbh       => $dbh,
		dbtable   => 'phrasebook',
        };

    eval { $obj->load( $file ); };
    ok($@);

	$file = {
		dbtable   => 'phrasebook',
		dbcolumns => ['keyword','phrase','dictionary'],
        };

    eval { $obj->load( $file ); };
    ok($@);

	$file = {
		dsn       => $dsn,
		dbtable   => 'phrasebook',
		dbcolumns => ['keyword','phrase','dictionary'],
        };

    eval { $obj->load( $file ); };
    ok($@);

	$file = {
		dsn       => $dsn,
		dbuser    => 'user',
		dbtable   => 'phrasebook',
		dbcolumns => ['keyword','phrase','dictionary'],
        };

    eval { $obj->load( $file ); };
    ok($@);

	$file = {
		dsn       => $dsn,
		dbuser    => 'user',
		dbpass    => 'pass',
		dbtable   => 'phrasebook',
		dbcolumns => ['keyword','phrase','dictionary'],
        };

    eval { $obj->load( $file ); };
    is($@,'');

	$file = {
               	dbh       => $dbh,
		dbtable   => 'phrasebook',
		dbcolumns => [],
        };

    eval { $obj->load( $file ); };
    ok($@);

	$file = {
               	dbh       => $dbh,
		dbtable   => 'phrasebook',
		dbcolumns => ['keyword','phrase'],
        };

    eval { $obj->load( $file ); };
    ok(!$@);

	my $phrase = $obj->get();
	is($phrase, undef);
	$phrase = $obj->get('foo');
	like($phrase, qr/Welcome to/);

	$file = {
               	dbh       => $dbh,
		dbtable   => 'phrasebook',
		dbcolumns => ['keyword','phrase','dictonary'],
        };

    eval { $obj->load( $file ); };
    ok(!$@);

	$phrase = $obj->get();
	is($phrase, undef);
	$phrase = $obj->get('foo');
	like($phrase, qr/Welcome to/);

    eval { $obj->load( $file, 'BLAH' ); };
    ok(!$@);

	$phrase = $obj->get();
	is($phrase, undef);
	$phrase = $obj->get('foo');
	like($phrase, qr/Welcome to/);

    eval { $obj->load( $file, $dict ); };
    ok(!$@);

	$phrase = $obj->get();
	is($phrase, undef);
	$phrase = $obj->get('foo');
	like($phrase, qr/Welcome to/);
}

