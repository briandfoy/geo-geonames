# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Geo-GeoNames.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 8;
BEGIN { use_ok('Geo::GeoNames') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $geo = new Geo::GeoNames();
ok(defined($geo) && ref $geo eq 'Geo::GeoNames', 'new()');

my $result = $geo->search(q => "Oslo", maxRows => 3, style => "FULL");
ok(defined($result)								, 'q => Oslo');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');

$result = $geo->postalcode_search(postalcode => "1630", maxRows => 3, style => "FULL");
ok(defined($result)								, 'postalcode => 1630');
ok(ref($result) eq "ARRAY"						, 'result is array ref');
ok(exists($result->[0]->{name})					, 'name exists in result');
