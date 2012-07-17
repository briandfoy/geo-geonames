use Test::More;

my $class = 'Geo::GeoNames';
my $method = 'new';

use_ok( $class );
can_ok( $class, $method );

subtest bad_name => sub {
	my $geo = eval { $class->$method(
		username => 'fakename',
		) };
	
	my $result = $geo->search( 'q' => 'Dijon' );
	isa_ok( $result, ref [] );
	is( scalar @$result, 0, 'There are no elements when the username is bad' );
	};
	
subtest empty_name => sub {
	my $geo = eval { $class->$method(
		username => '',
		) };
	my $at = $@;

	is( $geo, undef, '$geo is undefined with empty username' );
	like( $at, qr/You must specify/i, 'Error message says to specify username' );
	};

subtest undef_name => sub {
	my $geo = eval { $class->$method(
		username => undef,
		) };
	my $at = $@;
	
	is( $geo, undef, '$geo is undefined with undef username' );
	like( $at, qr/You must specify/i, 'Error message says to specify username' );
	};

done_testing();
