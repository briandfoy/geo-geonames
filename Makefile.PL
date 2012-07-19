use 5.010;
use ExtUtils::MakeMaker 6.48;

unless( exists $ENV{GEONAMES_USER} ) {
	print <<"HERE";
To test Geo::GeoNames, you need a a GeoNames account enabled at least
for free access. Start at http://www.geonames.org/login to create a
new account.
HERE
	}

WriteMakefile(
	NAME             => 'Geo::GeoNames',
	ABSTRACT_FROM    => 'lib/Geo/GeoNames.pm',
	VERSION_FROM     => 'lib/Geo/GeoNames.pm',
	AUTHOR           => 'Per Henrik Johansen <per.henrik.johansen@gmail.com>',
	LICENSE          => 'perl',
	MIN_PERL_VERSION => 5.010,

	PREREQ_PM      => {
		XML::Simple => '2.13',
		LWP         => '5.805',
		JSON        => '1.14',
		Test::More  => '0.94',
		},

	META_MERGE     => {
		configure_requires => {
			ExtUtils::MakeMaker => '6.48',
			},
		build_requires => {
			},
		test_requires => {
			Test::More => '0.94',
			},
		resources => {
			repository => 'git@github.com:briandfoy/geo-geonames.git',
			license    => 'http://dev.perl.org/licenses/',
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Geo-GeoNames'
			},
		keywords => [ qw() ],
		},
	);
