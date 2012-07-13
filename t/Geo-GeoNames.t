# $Id: Geo-GeoNames.t 26 2006-12-04 00:07:44Z per.henrik.johansen $
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Geo-GeoNames.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 23;
BEGIN { use_ok('Geo::GeoNames') };
#use Data::Dumper;
#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

package Geo::GeoNames::Test;
use Geo::GeoNames;
@ISA = qw(Geo::GeoNames);

package main;

my $geo = new Geo::GeoNames();
ok(defined($geo) && ref $geo eq 'Geo::GeoNames', 'new()');

my $result = $geo->search(q => "Oslo", maxRows => 3, style => "FULL");
ok(defined($result)								, 'q => Oslo');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->postalcode_search(postalcode => "1630", style => "FULL", country => "NO");
ok(defined($result)								, 'postalcode 1630');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->find_nearby_postalcodes(lng => "10", lat => "59");
ok(defined($result)								, 'nearby postalcode');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->find_nearby_placename(lng => "10", lat => "59");
ok(defined($result)								, 'nearby placename');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->postalcode_country_info();
ok(defined($result)								, 'postalcode_country_info');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{countryCode})			, 'countryCode exists in result');

$result = $geo->geocode('Fredrikstad');
ok(defined($result)								, 'geocode Fredrikstad');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{countryCode})			, 'countryCode exists in result');

$geo = new Geo::GeoNames::Test();
$result = $geo->geocode('Fredrikstad');
ok(defined($result)								, 'geocode Fredrikstad');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{countryCode})			, 'countryCode exists in result');

#diag(Data::Dumper->Dump($result));
