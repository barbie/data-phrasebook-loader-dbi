#!/usr/bin/perl -w
use strict;
use lib 't';
use BookDB;

use Test::More tests => 23;

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
    isa_ok($obj, $class, 'Checking class');

    my $file = {
        dbh       => $dbh,
        dbcolumns => ['keyword','phrase','dictionary'],
    };

    eval { $obj->load( $file ); };
    ok($@, 'Test load failed - no table');

    $file = {
        dbh       => $dbh,
        dbtable   => 'phrasebook',
    };

    eval { $obj->load( $file ); };
    ok($@, 'Test load failed - no columns');

    $file = {
        dbtable   => 'phrasebook',
        dbcolumns => ['keyword','phrase','dictionary'],
    };

    eval { $obj->load( $file ); };
    ok($@, 'Test load failed - no handle');

    $file = {
        dsn       => $dsn,
        dbtable   => 'phrasebook',
        dbcolumns => ['keyword','phrase','dictionary'],
    };

    eval { $obj->load( $file ); };
    ok($@, 'Test load failed - dsn with no user/password');

    $file = {
        dsn       => $dsn,
        dbuser    => 'user',
        dbtable   => 'phrasebook',
        dbcolumns => ['keyword','phrase','dictionary'],
    };

    eval { $obj->load( $file ); };
    ok($@, 'Test load failed - dsn with no password');

    $file = {
        dsn       => $dsn,
        dbuser    => 'user',
        dbpass    => 'pass',
        dbtable   => 'phrasebook',
        dbcolumns => ['keyword','phrase','dictionary'],
    };

    eval { $obj->load( $file ); };
    is($@,'','Test load passed - dsn');

    $file = {
        dbh       => $dbh,
        dbtable   => 'phrasebook',
        dbcolumns => [],
    };

    eval { $obj->load( $file ); };
    ok($@,'Test load failed - empty column list');

    $file = {
        dbh       => $dbh,
        dbtable   => 'phrasebook',
        dbcolumns => ['keyword','phrase'],
    };

    load_test($obj, 0, $file );

    $file = {
      dbh       => $dbh,
      dbtable   => 'phrasebook',
      dbcolumns => ['keyword','phrase','dictionary'],
    };

    load_test($obj, 0, $file );
    load_test($obj, 0, $file, 'BLAH' );
    load_test($obj, 0, $file, $dict );

    my @expected = qw(DEF ONE);
    my @dicts = $obj->dicts();
    is_deeply( \@dicts, \@expected, 'Checking dictionaries' );

       @expected = qw(bar foo);
    my @keywords = $obj->keywords();
    is_deeply( \@keywords, \@expected, 'Checking keywords' );
}

sub load_test {
    my $obj = shift;
    my $tof = shift;

    eval { $obj->load( @_ ); };
    $tof ? ok($@,  'Test load failed - not enough data')
         : ok(!$@, 'Test load passed - valid params');

    my $phrase = $obj->get();
    is($phrase, undef, '.. no key no phrase');
    $phrase = $obj->get('foo');
    like($phrase, qr/Welcome to/, '.. a welcome phrase');
}
