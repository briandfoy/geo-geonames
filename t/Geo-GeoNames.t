# $Id: Geo-GeoNames.t 42 2008-03-25 21:31:07Z per.henrik.johansen $
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Geo-GeoNames.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 78;
BEGIN { use_ok('Geo::GeoNames') };
use Data::Dumper;
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

package Geo::GeoNames::Test;
use Geo::GeoNames;
use Data::Dumper;
@ISA = qw(Geo::GeoNames);

package main;

my $geo = new Geo::GeoNames();
ok(defined($geo) && ref $geo eq 'Geo::GeoNames', 'new()');

my $result = $geo->search(q => "Oslo", maxRows => 3, style => "FULL");
ok(defined($result)						, 'q => Oslo');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->postalcode_search(postalcode => "1630", style => "FULL", country => "NO");
ok(defined($result)						, 'postalcode 1630');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->find_nearby_postalcodes(lng => "10", lat => "59");
ok(defined($result)						, 'nearby postalcode');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->find_nearby_placename(lng => "10", lat => "59");
ok(defined($result)						, 'nearby placename');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->postalcode_country_info();
ok(defined($result)						, 'postalcode_country_info');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{countryCode})			        , 'countryCode exists in result');

$result = $geo->geocode('Fredrikstad');
ok(defined($result)						, 'geocode Fredrikstad');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{countryCode})			        , 'countryCode exists in result');

$result = $geo->find_nearest_address(lng => "-122.1", lat => "37.4");
ok(defined($result)						, 'nearest address');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{street})				, 'street exists in result');

$result = $geo->find_nearest_intersection(lng => "-122.1", lat => "37.4");
ok(defined($result)						, 'nearest intersection');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{street1})				, 'street1 exists in result');
ok(exists($result->[0]->{street2})				, 'street2 exists in result');

$result = $geo->find_nearby_streets(lng => "-122.1", lat => "37.4");
ok(defined($result)						, 'nearest street');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{line})					, 'line exists in result');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->find_nearby_wikipedia(lng => "9", lat => "47");
ok(defined($result)						, 'nearby wikipedia');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{title})				, 'title exists in result');
ok(exists($result->[0]->{lng})					, 'lng exists in result');
ok(exists($result->[0]->{lat})					, 'lat exists in result');

$result = $geo->find_nearby_wikipedia_by_postalcode(postalcode => "8775", country => "CH");
ok(defined($result)						, 'nearby wikipedia postalcode');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{title})				, 'title exists in result');
ok(exists($result->[0]->{lng})					, 'lng exists in result');
ok(exists($result->[0]->{lat})					, 'lat exists in result');

$result = $geo->wikipedia_search(q => "london");
ok(defined($result)						, 'wikipedia search');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{title})				, 'title exists in result');
ok(exists($result->[0]->{lng})					, 'lng exists in result');
ok(exists($result->[0]->{lat})					, 'lat exists in result');

$result = $geo->wikipedia_bounding_box(north => "44.1", south => "-9.9", east => "-22.4", west => "55.2");
ok(defined($result)						, 'wikipedia bounding box');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{title})				, 'title exists in result');
ok(exists($result->[0]->{lng})					, 'lng exists in result');
ok(exists($result->[0]->{lat})					, 'lat exists in result');

$result = $geo->country_info();
ok(defined($result)						, 'country info');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{bBoxWest})				, 'bBoxWest exists in result');
ok(exists($result->[0]->{bBoxNorth})			        , 'bBoxNorth exists in result');
ok(exists($result->[0]->{bBoxEast})				, 'bBoxEast exists in result');
ok(exists($result->[0]->{bBoxSouth})			        , 'bBoxSouth exists in result');

$result = $geo->country_code(lng => "10.2", lat => "47.03");
ok(defined($result)						, 'country code');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{countryCode})				, 'countryCode exists in result');
ok(exists($result->[0]->{countryName})			        , 'countryName exists in result');

$result = $geo->find_nearby_weather(lng => "10.2", lat => "47.03");
#diag(Data::Dumper->Dump($result));
ok(defined($result)                                             , 'find_nearby_weather');
ok(ref($result) eq "ARRAY"                                      , 'result is array ref');
ok(exists($result->[0]->{observation})                          , 'observation exists in result');
ok(exists($result->[0]->{stationName})                 		, 'stationName exists in result');

$result = $geo->cities(north => "44.1", south => "-9.9", east => "-22.4", west => "55.2");
ok(defined($result)                                             , 'cities');
ok(ref($result) eq "ARRAY"                                      , 'result is array ref');
ok(exists($result->[0]->{name})		                        , 'name exists in result');
ok(exists($result->[0]->{lat})	                 		, 'lat exists in result');
ok(exists($result->[0]->{lng})	                 		, 'lng exists in result');

$result = $geo->earthquakes(north => "44.1", south => "-9.9", east => "-22.4", west => "55.2");
ok(defined($result)                                             , 'earthquakes');
ok(ref($result) eq "ARRAY"                                      , 'result is array ref');
ok(exists($result->[0]->{magnitude})	                        , 'magnitude exists in result');
ok(exists($result->[0]->{lat})	                 		, 'lat exists in result');
ok(exists($result->[0]->{lng})	                 		, 'lng exists in result');


#diag(Data::Dumper->Dump($result));

$geo = new Geo::GeoNames::Test();
$result = $geo->geocode('Fredrikstad');
ok(defined($result)						, 'geocode Fredrikstad');
ok(ref($result) eq "ARRAY"					, 'result is array ref');
ok(exists($result->[0]->{countryCode})				, 'countryCode exists in result');

