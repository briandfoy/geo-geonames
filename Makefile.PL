use 5.010;
use strict;
use warnings;

unless( exists $ENV{GEONAMES_USER} ) {
	print <<"HERE";
To test Geo::GeoNames, you need a a GeoNames account enabled at least
for free access. Start at http://www.geonames.org/login to create a
new account. Set GEONAMES_USER to run the tests.
HERE
	}

my $module    = 'Geo::GeoNames';
( my $dist = $module ) =~ s/::/-/g;

my $github    = 'https://github.com/briandfoy/geo-geonames';
my $main_file = catfile( 'lib', split /::/, "$module.pm" );

my %WriteMakefile = (
	MIN_PERL_VERSION => 5.010,
	NAME             => $module,
	ABSTRACT_FROM    => $main_file,
	VERSION_FROM     => $main_file,
	AUTHOR           => 'Per Henrik Johansen <per.henrik.johansen@gmail.com>',
	LICENSE          => 'perl',

	'CONFIGURE_REQUIRES' => {
		'ExtUtils::MakeMaker'   => '6.64',
		'File::Spec::Functions' => '0',
		},

	'BUILD_REQUIRES' => {
		},

	'TEST_REQUIRES' => {
		'Test::More' => '0.98',
		},

	'PREREQ_PM'      => {
		'XML::Simple'     => '2.13',
		'Mojo::UserAgent' => '0',
		'JSON'            => '1.14',
		},

	'META_MERGE' => {
		'meta-spec' => { version => 2 },
		keywords => [ qw(geo geonames) ],
		resources => {
			repository => {
				type => 'git',
				url  => "$github.git",
				web  => $github,
				},
			bugtraker => {
				web    => "$github/issues",
				},
			homepage => $github,
			},
		},

	clean => { FILES => "$dist-*" },
	);

sub arguments { \%WriteMakefile }

do_it() unless caller;
sub do_it {
	require File::Spec;
	my $MM ='ExtUtils::MakeMaker';
	my $MM_version =
		eval{ "$MM " . $WriteMakefile{'CONFIGURE_REQUIRES'}{'ExtUtils::MakeMaker'} }
			//
		"$MM 6.64";
	eval "use $MM_version; 1" or die "Could not load $MM_version: $@";
	eval "use Test::Manifest 1.21" 
		if -e File::Spec->catfile( qw(t test_manifest) );
	WriteMakefile( %WriteMakefile );
	}


no warnings;
__PACKAGE__;
