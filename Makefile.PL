use 5.008006;
use ExtUtils::MakeMaker 6.48;

WriteMakefile(
	NAME           => 'Geo::GeoNames',
	ABSTRACT_FROM  => 'lib/Geo/GeoNames.pm',
	VERSION_FROM   => 'lib/Geo/GeoNames.pm',
	AUTHOR         => 'Per Henrik Johansen <per.henrik.johansen@gmail.com>',
	MIN_PERL_VERSION => 5.008006,
	LICENSE => 'perl',
	PREREQ_PM      => {
		XML::Simple => '2.13',
		LWP         => '5.805',
		JSON        => '1.14'
		},
	META_MERGE     => {
		configure_requires => {
			ExtUtils::MakeMaker => '6.48',
			},
		build_requires => {
			},
		test_requires => {
			},
		resources => {
			repository => 'git@github.com:briandfoy/geo-geonames.git',
			license    => 'http://dev.perl.org/licenses/',
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Geo-GeoNames'
			},
		keywords => [ qw() ],
		},
);
