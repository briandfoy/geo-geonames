use Test::More 0.98;

use strict;
use warnings;

use_ok('Geo::GeoNames');

ok ! eval { Geo::GeoNames->new( ua => undef, username => 'fakename' ); }, 'Bad user-agent should croak: ' . $@;
ok ! eval { Geo::GeoNames->new( ua => {}, username => 'fakename' ); }, 'Bad user-agent should croak: ' . $@;
ok ! eval { Geo::GeoNames->new( ua => IO::Handle->new, username => 'fakename' ); }, 'Bad user-agent should croak: ' . $@;

subtest 'Mojo::UserAgent' => sub {
    SKIP: {
        skip 'Skip tests if Mojo::UserAgent is not installed', 4 unless eval { require Mojo::UserAgent; };
        my $mua = Mojo::UserAgent->new;
        ok Geo::GeoNames->new( ua => $mua, username => 'fakename' ), 'Instantiates fine with proper object';

        skip 'Need $ENV{GEONAMES_USER} to test actual results work with provided Mojo::UserAgent', 3  unless $ENV{GEONAMES_USER};
        my $geo = Geo::GeoNames->new( ua => $mua, username => $ENV{GEONAMES_USER} );
        my $result = $geo->search( 'q' => "Oslo", maxRows => 3, style => "FULL" );
        ok( defined $result              , 'q => Oslo' );
        ok( ref $result eq ref []        , 'result is array ref' );
        ok( exists($result->[0]->{name}) , 'name exists in result' );
    };
};

subtest 'LWP::UserAgent' => sub {
    SKIP: {
        skip 'Skip tests if LWP::UserAgent is not installed', 4 unless eval { require LWP::UserAgent };

        my $lwp = LWP::UserAgent->new;
        ok Geo::GeoNames->new( ua => $lwp, username => 'fakename' ), 'Instantiates fine with proper object';

        skip 'Need $ENV{GEONAMES_USER} to test actual results work with provided LWP::UserAgent', 3 unless $ENV{GEONAMES_USER};
        my $geo = Geo::GeoNames->new( ua => $lwp, username => $ENV{GEONAMES_USER} );
        my $result = $geo->search( 'q' => "Oslo", maxRows => 3, style => "FULL" );
        ok( defined $result              , 'q => Oslo' );
        ok( ref $result eq ref []        , 'result is array ref' );
        ok( exists($result->[0]->{name}) , 'name exists in result' );
    };
};

done_testing;
