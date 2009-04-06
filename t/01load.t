#!/usr/bin/perl -w
use strict;
use lib 't';
use vars qw( $class );
use BookDB;

use Test::More tests => 7;

# ------------------------------------------------------------------------

my ($mock1);

BEGIN {
    $class = 'Data::Phrasebook';
    use_ok $class;

	eval "use Test::MockObject";
	plan skip_all => "Test::MockObject required for testing" if $@;

	$mock1 = Test::MockObject->new();
	$mock1->fake_module( 'DBI', 
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
	$mock1->fake_new( 'DBI' );
	$mock1->mock( 'connect', \&BookDB::connect );
	$mock1->mock( 'prepare', \&BookDB::prepare );
	$mock1->mock( 'prepare_cached', \&BookDB::prepare_cached );
	$mock1->mock( 'rebind', \&BookDB::rebind );
	$mock1->mock( 'bind_param', \&BookDB::bind_param );
	$mock1->mock( 'execute', \&BookDB::execute );
	$mock1->mock( 'fetchrow_hashref', \&BookDB::fetchrow_hashref );
	$mock1->mock( 'fetchall_arrayref', \&BookDB::fetchall_arrayref );
	$mock1->mock( 'fetchrow_array', \&BookDB::fetchrow_array );
	$mock1->mock( 'finish', \&BookDB::finish );
}

use DBI;

my $dict = 'base';

# ------------------------------------------------------------------------

{
    my $obj = $class->new(
        loader    => 'DBI',
		file      => {
            dsn	      => 'dbi:mysql:database=test',
            dbuser    => 'user',
            dbpass    => 'pass',
		    dbtable   => 'phrasebook',
		    dbcolumns => ['keyword','phrase','dictionary'],
        }
	);
    isa_ok( $obj => $class.'::Plain', "Bare new" );
    $obj->dict( $dict );
    is( $obj->dict() => $dict , "Set/get dict works");
}

{
    my $obj = $class->new(
		dict      => $dict,

        loader    => 'DBI',
		file      => {
            dsn	      => 'dbi:mysql:database=test',
            dbuser    => 'user',
            dbpass    => 'pass',
		    dbtable   => 'phrasebook',
		    dbcolumns => ['keyword','phrase','dictionary'],
        }
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

