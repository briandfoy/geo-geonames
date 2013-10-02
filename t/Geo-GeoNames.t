use Test::More 0.94;
use strict;
use warnings;

unless( defined $ENV{GEONAMES_USER} and length $ENV{GEONAMES_USER} ) {
	warn "Define GEONAME_USER to test Geo::GeoNames\n";
	pass();
	done_testing();
	exit;
	}

my $class = 'Geo::GeoNames';
use_ok( $class );

my $geo;
subtest 'Make object' => sub {
	can_ok( $class, 'new' );
	$geo = Geo::GeoNames->new( username => $ENV{GEONAMES_USER} );
	isa_ok( $geo, $class );
	};

subtest 'search' => sub {
	my $result = $geo->search( 'q' => "Oslo", maxRows => 3, style => "FULL" );
	ok( defined $result              , 'q => Oslo' );
	ok( ref $result eq ref []        , 'result is array ref' );
	ok( exists($result->[0]->{name}) , 'name exists in result' );
	};

subtest 'postalcode_search' => sub {
	my $result = $geo->postalcode_search( postalcode => "1630", style => "FULL", country => "NO" );
	ok( defined $result              , 'postalcode 1630' );
	ok( ref $result eq ref []        , 'result is array ref' );
	ok( exists($result->[0]->{name}) , 'name exists in result' );
	};

subtest 'find_nearby_postalcodes' => sub {
	my $result = $geo->find_nearby_postalcodes( lng => "10", lat => "59" );
	ok( defined $result              , 'nearby postalcode' );
	ok( ref $result eq ref []        , 'result is array ref' );
	ok( exists($result->[0]->{name}) , 'name exists in result' );
	};

subtest 'find_nearby_placename' => sub {
	my $result = $geo->find_nearby_placename( lng => "10", lat => "59" );
	ok( defined $result              , 'nearby placename' );
	ok( ref $result eq ref []        , 'result is array ref' );
	ok( exists($result->[0]->{name}) , 'name exists in result' );
	};

subtest 'postalcode_country_info' => sub {
	my $result = $geo->postalcode_country_info();
	ok( defined $result                     , 'postalcode_country_info' );
	ok( ref $result eq ref []               , 'result is array ref' );
	ok( exists($result->[0]->{countryCode}) , 'countryCode exists in result' );
	};

subtest 'geocode' => sub {
	my $result = $geo->geocode('Fredrikstad');
	ok( defined $result                     , 'geocode Fredrikstad' );
	ok( ref $result eq ref []               , 'result is array ref' );
	ok( exists($result->[0]->{countryCode}) , 'countryCode exists in result' );
	};

subtest 'find_nearest_address' => sub {
	my $result = $geo->find_nearest_address( lng => "-122.1", lat => "37.4" );
	ok( defined $result                , 'nearest address' );
	ok( ref $result eq ref []          , 'result is array ref' );
	ok( exists($result->[0]->{street}) , 'street exists in result' );
	};

subtest 'find_nearest_intersection' => sub {
	my $result = $geo->find_nearest_intersection( lng => "-122.1", lat => "37.4" );
	ok( defined $result                 , 'nearest intersection' );
	ok( ref $result eq ref []           , 'result is array ref' );
	ok( exists($result->[0]->{street1}) , 'street1 exists in result' );
	ok( exists($result->[0]->{street2}) , 'street2 exists in result' );
	};

subtest 'find_nearby_streets' => sub {
	my $result = $geo->find_nearby_streets( lng => "-122.1", lat => "37.4" );
	ok( defined $result              , 'nearest street' );
	ok( ref $result eq ref []        , 'result is array ref' );
	ok( exists($result->[0]->{line}) , 'line exists in result' );
	ok( exists($result->[0]->{name}) , 'name exists in result' );
	};

subtest 'find_nearby_wikipedia' => sub {
	my $result = $geo->find_nearby_wikipedia( lng => "9", lat => "47" );
	ok( defined $result    , 'nearby wikipedia');
	ok( ref $result eq ref []          , 'result is array ref' );
	ok( exists($result->[0]->{title})  , 'title exists in result' );
	ok( exists($result->[0]->{lng})    , 'lng exists in result' );
	ok( exists($result->[0]->{lat})    , 'lat exists in result' );
	};

subtest 'find_nearby_wikipedia_by_postalcode' => sub {
	my $result = $geo->find_nearby_wikipedia_by_postalcode( postalcode => "8775", country => "CH" );
	ok( defined $result                , 'nearby wikipedia postalcode' );
	ok( ref $result eq ref []          , 'result is array ref' );
	ok( exists($result->[0]->{title})  , 'title exists in result' );
	ok( exists($result->[0]->{lng})    , 'lng exists in result' );
	ok( exists($result->[0]->{lat})    , 'lat exists in result' );
	};

subtest 'wikipedia_search' => sub {
	my $result = $geo->wikipedia_search( 'q' => "london" );
	ok( defined $result                , 'wikipedia search' );
	ok( ref $result eq ref []          , 'result is array ref' );
	ok( exists($result->[0]->{title})  , 'title exists in result' );
	ok( exists($result->[0]->{lng})    , 'lng exists in result' );
	ok( exists($result->[0]->{lat})    , 'lat exists in result' );
	};

subtest 'wikipedia_bounding_box' => sub {
	my $result = $geo->wikipedia_bounding_box( north => "44.1", south => "-9.9", east => "-22.4", west => "55.2" );
	ok( defined $result               , 'wikipedia bounding box' );
	ok( ref $result eq ref []         , 'result is array ref' );
	ok( exists($result->[0]->{title}) , 'title exists in result' );
	ok( exists($result->[0]->{lng})   , 'lng exists in result' );
	ok( exists($result->[0]->{lat})   , 'lat exists in result' );
	};

subtest 'country_info' => sub {
	TODO: {
	local $TODO = 'Bounding box stuff is missing';
	my $result = $geo->country_info();
	ok( defined $result                   , 'country info' );
	ok( ref $result eq ref []             , 'result is array ref' );
	ok( exists($result->[0]->{bBoxWest})  , 'bBoxWest exists in result' );
	ok( exists($result->[0]->{bBoxNorth}) , 'bBoxNorth exists in result' );
	ok( exists($result->[0]->{bBoxEast})  , 'bBoxEast exists in result' );
	ok( exists($result->[0]->{bBoxSouth}) , 'bBoxSouth exists in result' );
	}
	};

subtest 'country_code' => sub {
	my $result = $geo->country_code( lng => "10.2", lat => "47.03" );
	ok( defined $result                     , 'country code' );
	ok( ref $result eq ref []               , 'result is array ref' );
	ok( exists($result->[0]->{countryCode}) , 'countryCode exists in result' );
	ok( exists($result->[0]->{countryName}) , 'countryName exists in result' );
	};

subtest 'find_nearby_weather' => sub {
	my $result = $geo->find_nearby_weather( lng => "10.2", lat => "47.03" );
	ok( defined $result                     , 'find_nearby_weather' );
	ok( ref $result eq ref []               , 'result is array ref' );
	ok( exists($result->[0]->{observation}) , 'observation exists in result' );
	ok( exists($result->[0]->{stationName}) , 'stationName exists in result' );
	};

subtest 'cities' => sub {
	my $result = $geo->cities( north => "44.1", south => "-9.9", east => "-22.4", west => "55.2" );
	ok( defined $result               , 'cities' );
	ok( ref $result eq ref []         , 'result is array ref' );
	ok( exists($result->[0]->{name})  , 'name exists in result' );
	ok( exists($result->[0]->{lat})   , 'lat exists in result' );
	ok( exists($result->[0]->{lng})   , 'lng exists in result' );
	};

subtest 'earthquakes' => sub {
	my $result = $geo->earthquakes( north => "44.1", south => "-9.9", east => "-22.4", west => "55.2" );
	ok( defined $result                   , 'earthquakes' );
	my $earthquakes = $result->[0]{Result}{earthquakes};
	ok( ref $earthquakes eq ref []             , 'result is array ref' );
	ok( exists($earthquakes->[0]->{magnitude}) , 'magnitude exists in result' );
	ok( exists($earthquakes->[0]->{lat})       , 'lat exists in result' );
	ok( exists($earthquakes->[0]->{lng})       , 'lng exists in result' );
	};

{
package Geo::GeoNames::Test;
use base qw(Geo::GeoNames);
}

subtest 'Geo::GeoNames::Test' => sub {
	my $geo = Geo::GeoNames::Test->new( username => $ENV{GEONAMES_USER} );
	my $result = $geo->geocode('Fredrikstad');
	ok( defined $result                     , 'geocode Fredrikstad');
	ok( ref $result eq ref []               , 'result is array ref');
	ok( exists($result->[0]->{countryCode}) , 'countryCode exists in result');
	};

done_testing();
