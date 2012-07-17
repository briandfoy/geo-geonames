package Geo::GeoNames;
use 5.008006;
use strict;
use warnings;
use utf8;

use Carp;
use LWP;

use vars qw($DEBUG $CACHE);

our $VERSION = '0.09';

our %searches = (
	cities                              => 'cities?',
	country_code                        => 'countrycode?type=xml&',
	country_info                        => 'countryInfo?',
	earthquakes                         => 'earthquakesJSON?',
	find_nearby_placename               => 'findNearbyPlaceName?',
	find_nearby_postalcodes             => 'findNearbyPostalCodes?',
	find_nearby_streets                 => 'findNearbyStreets?',
	find_nearby_weather                 => 'findNearByWeatherXML?',
	find_nearby_wikipedia               => 'findNearbyWikipedia?',
	find_nearby_wikipedia_by_postalcode => 'findNearbyWikipedia?',
	find_nearest_address                => 'findNearestAddress?',
	find_nearest_intersection           => 'findNearestIntersection?',
	postalcode_country_info             => 'postalCodeCountryInfo?',
	postalcode_search                   => 'postalCodeSearch?',
	search                              => 'search?',
	wikipedia_bounding_box              => 'wikipediaBoundingBox?',
	wikipedia_search                    => 'wikipediaSearch?',
	);

#	r	= required
#	o	= optional
#	rc	= required - only one of the fields marked with rc is allowed. At least one must be present
#	om	= optional, multiple entries allowed
#	d	= depreciated - will be removed in later versions
our %valid_parameters = (
	search => {
		'q'    => 'rc',
		name    => 'rc',
		name_equals => 'rc',
		maxRows    => 'o',
		startRow    => 'o',
		country    => 'om',
		continentCode    => 'o',
		adminCode1    => 'o',
		adminCode2    => 'o',
		adminCode3    => 'o',
		fclass    => 'omd',
		featureClass    => 'om',
		featureCode => 'om',
		lang    => 'o',
		type    => 'o',
		style    => 'o',
		isNameRequired    => 'o',
		tag    => 'o',
		username => 'r',
		},
	postalcode_search => {
		postalcode    => 'rc',
		placename    => 'rc',
		country    => 'o',
		maxRows    => 'o',
		style    => 'o',
		username => 'r',
		},
	find_nearby_postalcodes => {
		lat    => 'r',
		lng    => 'r',
		radius    => 'o',
		maxRows    => 'o',
		style    => 'o',
		country    => 'o',
		username => 'r',
		},
	postalcode_country_info => {
		username => 'r',
		},
	find_nearby_placename => {
		lat    => 'r',
		lng    => 'r',
		radius    => 'o',
		style    => 'o',
		maxRows    => 'o',
		username => 'r',
		},
	find_nearest_address => {
		lat    => 'r',
		lng    => 'r',
		username => 'r',
		},
	find_nearest_intersection => {
		lat    => 'r',
		lng    => 'r',
		username => 'r',
		},
	find_nearby_streets => {
		lat    => 'r',
		lng    => 'r',
		username => 'r',
		},
	find_nearby_wikipedia => {
		lang    => 'o',
		lat    => 'r',
		lng    => 'r',
		radius    => 'o',
		maxRows    => 'o',
		country    => 'o',
		username => 'r',
		},
	find_nearby_wikipedia_by_postalcode => {
		postalcode => 'r',
		country    => 'r',
		radius     => 'o',
		maxRows    => 'o',
		username   => 'r',
		},
	wikipedia_search => {
		'q'      => 'r',
		lang     => 'o',
		title    => 'o',
		maxRows  => 'o',
		username => 'r',
		},
	wikipedia_bounding_box => {
		south    => 'r',
		north    => 'r',
		east     => 'r',
		west     => 'r',
		lang     => 'o',
		maxRows  => 'o',
		username => 'r',
		},
	country_info => {
		country  => 'o',
		lang     => 'o',
		username => 'r',
		},
	country_code => {
		lat      => 'r',
		lng      => 'r',
		lang     => 'o',
		radius   => 'o',
		username => 'r',
		},
	find_nearby_weather => {
		lat      => 'r',
		lng      => 'r',
		username => 'r',
		},
	cities => {
		north      => 'r',
		south      => 'r',
		east       => 'r',
		west       => 'r',
		lang       => 'o',
		maxRows    => 'o',
		username   => 'r',
		},
	earthquakes => {
		north           => 'r',
		south           => 'r',
		east            => 'r',
		west            => 'r',
		date            => 'o',
		minMagnutide    => 'o',
		maxRows         => 'o',
		username        => 'r',
		}
	);

sub new {
	my( $class, %hash ) = @_;

	my $self = bless { _functions => \%searches }, $class;

	croak <<"HERE" unless length $hash{username};
You must specify a GeoNames username to use Geo::GeoNames.
See http://www.geonames.org/export/web-services.html
HERE

	$self->username( $hash{username} );
	$self->url( $hash{url} // $self->default_url );

	(exists($hash{debug})) ? $DEBUG = $hash{debug} : 0;
	(exists($hash{cache})) ? $CACHE = $hash{cache} : 0;
	$self->{_functions} = \%searches;

	return $self;
	}

sub username {
	my( $self, $username ) = @_;

	$self->{username} = $username if @_ == 2;

	$self->{username};
	}

sub default_url { 'http://api.geonames.org' }

sub url {
	my( $self, $url ) = @_;

	$self->{url} = $url if @_ == 2;

	$self->{url};
	}

sub _build_request {
	my( $self, $request, @args ) = @_;
	my $hash = { @args, username => $self->username };
	my $request_string = $self->url . '/' . $searches{$request};

	# check to see that mandatory arguments are present
	my $conditional_mandatory_flag = 0;
	my $conditional_mandatory_required = 0;
	foreach my $arg (keys %{$valid_parameters{$request}}) {
		my $flags = $valid_parameters{$request}->{$arg};
		if($flags =~ /d/ && exists($hash->{$arg})) {
			carp("Argument $arg is depreciated.");
			}
		$flags =~ s/d//g;
		if($flags eq 'r' && !exists($hash->{$arg})) {
			carp("Mandatory argument $arg is missing!");
			}
		if($flags !~ /m/ && exists($hash->{$arg}) && ref($hash->{$arg})) {
			carp("Argument $arg cannot have multiple values.");
			}
		if($flags eq 'rc') {
			$conditional_mandatory_required = 1;
			if(exists($hash->{$arg})) {
				$conditional_mandatory_flag++;
				}
			}
		}

	if($conditional_mandatory_required == 1 && $conditional_mandatory_flag != 1) {
		carp("Invalid number of mandatory arguments (there can be only one)");
		}

	foreach my $key (keys(%$hash)) {
		carp("Invalid argument $key") if(!defined($valid_parameters{$request}->{$key}));
		my @vals = ref($hash->{$key}) ? @{$hash->{$key}} : $hash->{$key};
		no warnings 'uninitialized';
		$request_string .= join("", map { "$key=$_&" } @vals );
		}

	chop($request_string); # loose the trailing &
	return $request_string;
	}

sub _parse_xml_result {
	require XML::Simple;
	my( $self, $geonamesresponse ) = @_;
	my @result;
	my $xmlsimple = XML::Simple->new;
	my $xml = $xmlsimple->XMLin( $geonamesresponse, KeyAttr => [], ForceArray => 1 );

	my $i = 0;
	foreach my $element (keys %{$xml}) {
		if ($element eq 'status') {
			carp "GeoNames error: " . $xml->{$element}->[0]->{message};
			return [];
			}
		next if (ref($xml->{$element}) ne "ARRAY");
		foreach my $list (@{$xml->{$element}}) {
			next if (ref($list) ne "HASH");
			foreach my $attribute (%{$list}) {
				next if !defined($list->{$attribute}->[0]);
				$result[$i]->{$attribute} = $list->{$attribute}->[0];
				}
			$i++;
			}
		}
	return \@result;
	}

sub _parse_json_result {
	require JSON;
	my( $self, $geonamesresponse ) = @_;
	my @result;
	my $json = JSON->new;
	my $data = $json->decode($geonamesresponse);

	my $i = 0;
	foreach my $hash (keys %{$data}) {
		if(ref($data->{$hash}) eq 'ARRAY') { # we have a list of objects
			foreach my $object (@{$data->{$hash}}) { # $object is a hash ref
				next if(ref($object) ne 'HASH');
				foreach my $attribute (keys %{$object}) {
					$result[$i]->{$attribute} = $object->{$attribute};
					}
				$i++;
				}
			}
		else { #we have only one
			my $attributes = $data->{$hash};
			foreach my $attribute (keys %{$attributes}) {
				$result[$i]->{$attribute} = $attributes->{$attribute};
				}
			$i++;
			}
		}

	return \@result;
	}

sub _parse_text_result {
	my( $self, $geonamesresponse ) = @_;
	my @result;
	$result[0]->{Result} = $geonamesresponse;
	return \@result;
	}

sub _request {
	my( $self, $request ) = @_;
	my $browser = LWP::UserAgent->new;
	$browser->env_proxy();
	my $response = $browser->get($request);
	carp "Can't get $request -- ", $response->status_line
		unless $response->is_success;
	return $response;
	}

sub _do_search {
	my( $self, $searchtype, @args ) = @_;

	my $request = $self->_build_request( $searchtype, @args );
	my $response = $self->_request( $request );

	# check mime-type to determine which parse method to use.
	# we accept text/xml, text/plain (how do see if it is JSON or not?)
	my $mime_type = $response->header( 'Content-type' );
	if($mime_type =~ m(\Atext/xml;) ) {
		return $self->_parse_xml_result( $response->content );
		}
	if($mime_type =~ m(\Aapplication/json;) ) {
		# a JSON object always start with a left-brace {
		# according to http://json.org/
		if( $response->content =~ m/\A\{/ ) {
			return $self->_parse_json_result( $response->content );
			}
		else {
			return $self->_parse_text_result( $response->content );
			}
		}

	carp "Invalid mime type [$mime_type]";

	return;
	}

sub geocode {
	my( $self, $q ) = @_;
	$self->search( 'q' => $q );
	}

sub AUTOLOAD {
	my $self = shift;
	my $type = ref($self) || croak "$self is not an object";
	my $name = our $AUTOLOAD;
	$name =~ s/.*://;

	unless (exists $self->{_functions}->{$name}) {
		croak "No such method '$AUTOLOAD'";
		}

	return($self->_do_search($name, @_));
	}

sub DESTROY { 1 }

1;

__END__

=head1 NAME

Geo::GeoNames - Perform geographical queries using GeoNames Web Services

=head1 SYNOPSIS

	use Geo::GeoNames;
	my $geo = Geo::GeoNames->new( username => $username );

	# make a query based on placename
	my $result = $geo->search(q => 'Fredrikstad', maxRows => 2);

	# print the first result
	print " Name: " . $result->[0]->{name};
	print " Longitude: " . $result->[0]->{lng};
	print " Lattitude: " . $result->[0]->{lat};

	# Make a query based on postcode
	my $result = $geo->postalcode_search(
		postalcode => "1630", maxRows => 3, style => "FULL"
		);

=head1 DESCRIPTION

Before you start, get a free GeoNames account and enable it for
access to the free web service:

=over 4

=item * Get an account

Go to http://www.geonames.org/login

=item * Respond to the email

=item * Login and enable your account for free access

http://www.geonames.org/enablefreewebservice

=back

Provides a perl interface to the webservices found at
http://api.geonames.org. That is, given a given placename or
postalcode, the module will look it up and return more information
(longitude, lattitude, etc) for the given placename or postalcode.
Wikipedia lookups are also supported. If more than one match is found,
a list of locations will be returned.

=head1 METHODS

=over 4

=item new

	$geo = Geo::GeoNames->new( username => '...' )
	$geo = Geo::GeoNames->new( username => '...', url => $url )

Constructor for Geo::GeoNames. It returns a reference to an
Geo::GeoNames object. You may also pass the url of the webservices to
use. The default value is http://api.geonames.org and is the only url,
to my knowledge, that provides the services needed by this module. The
username parameter is required.

=item username( $username )

With a single argument, set the GeoNames username and return that
username. With no arguments, return the username.

=item default_url

Returns C<http://api.geonames.org>.

=item url( $url )

With a single argument, set the GeoNames url and return that
url. With no arguments, return the url.

=item geocode( $placename )

This function is just an easy access to search. It is the same as
saying:

	$geo->search( q => $placename );

=item search( arg => $arg )

Searches for information about a placename. Valid names for B<arg> are
as follows:

	q              => $placename
	name           => $placename
	name_equals    => $placename
	maxRows        => $maxrows
	startRow       => $startrow
	country        => $countrycode
	continentCode  => $continentcode
	adminCode1     => $admin1
	adminCode2     => $admin2
	adminCode3     => $admin3
	fclass         => $fclass
	featureClass   => $fclass,
	featureCode    => $code
	lang           => $lang
	type           => $type
	style          => $style
	isNameRequired => $isnamerequired
	tag            => $tag

One, and only one, of B<q>, B<name>, or B<name_equals> must be
supplied to this function.

fclass is depreciated.

For a thorough description of the arguments, see
http://www.geonames.org/export/geonames-search.html

=item find_nearby_placename( arg => $arg )

Reverse lookup for closest placename to a given coordinate. Valid
names for B<arg> are as follows:

	lat     => $lat
	lng     => $lng
	radius  => $radius
	style   => $style
	maxRows => $maxrows

Both B<lat> and B<lng> must be supplied to
this function.

For a thorough descriptions of the arguments, see
http://www.geonames.org/export

=item find_nearest_address(arg => $arg)

Reverse lookup for closest address to a given coordinate. Valid names
for B<arg> are as follows:

	lat => $lat
	lng => $lng

Both B<lat> and B<lng> must be supplied to this function.

For a thorough descriptions of the arguments, see
http://www.geonames.org/maps/reverse-geocoder.html

US only.

=item find_nearest_intersection(arg => $arg)

Reverse lookup for closest intersection to a given coordinate. Valid
names for B<arg> are as follows:

	lat => $lat
	lng => $lng

Both B<lat> and B<lng> must be supplied to
this function.

For a thorough descriptions of the arguments, see
http://www.geonames.org/maps/reverse-geocoder.html

US only.

=item find_nearby_streets(arg => $arg)

Reverse lookup for closest streets to a given coordinate. Valid names
for B<arg> are as follows:

	lat => $lat
	lng => $lng

Both B<lat> and B<lng> must be supplied to
this function.

For a thorough descriptions of the arguments, see
http://www.geonames.org/maps/reverse-geocoder.html

US only.

=item postalcode_search(arg => $arg)

Searches for information about a postalcode. Valid names for B<arg>
are as follows:

	postalcode => $postalcode
	placename  => $placename
	country    => $country
	maxRows    => $maxrows
	style      => $style

One, and only one, of B<postalcode> or B<placename> must be supplied
to this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item find_nearby_postalcodes(arg => $arg)

Reverse lookup for postalcodes. Valid names for B<arg> are as follows:

	lat     => $lat
	lng     => $lng
	radius  => $radius
	maxRows => $maxrows
	style   => $style
	country => $country

Both B<lat> and B<lng> must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item postalcode_country_info

Returns a list of all postalcodes found on GeoNames. This function
takes no arguments.

=item country_info(arg => $arg)

Returns country information. Valid names for B<arg> are as follows:

	country => $country
	lang    => $lang

For a thorough description of the arguments, see
http://www.geonames.org/export

=item find_nearby_wikipedia(arg => $arg)

Reverse lookup for Wikipedia articles. Valid names for B<arg> are as
follows:

	lat     => $lat
	lng     => $lng
	radius  => $radius
	maxRows => $maxrows
	lang    => $lang
	country => $country

Both B<lat> and B<lng> must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item find_nearby_wikipediaby_postalcode(arg => $arg)

Reverse lookup for Wikipedia articles. Valid names for B<arg> are as
follows:

	postalcode => $postalcode
	country    => $country
	radius     => $radius
	maxRows    => $maxrows

Both B<postalcode> and B<country> must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item wikipedia_search(arg => $arg)

Searches for Wikipedia articles. Valid names for B<arg> are as
follows:

	q       => $placename
	maxRows => $maxrows
	lang    => $lang
	title   => $title

B<q> must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item wikipedia_bounding_box(arg => $arg)

Searches for Wikipedia articles. Valid names for B<arg> are as
follows:

	south   => $south
	north   => $north
	east    => $east
	west    => $west
	lang    => $lang
	maxRows => $maxrows

B<south>, B<north>, B<east>, and B<west> and must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item cities(arg => $arg)

Returns a list of cities and placenames within the bounding box.
Valid names for B<arg> are as follows:

	south   => $south
	north   => $north
	east    => $east
	west    => $west
	lang    => $lang
	maxRows => $maxrows

B<south>, B<north>, B<east>, and B<west> and must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item country_code(arg => $arg)

Return the country code for a given point. Valid names for B<arg> are
as follows:

	lat    => $lat
	lng    => $lng
	radius => $radius
	lang   => $lang

Both B<lat> and B<lng> must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item earthquakes(arg => $arg)

Returns a list of cities and placenames within the bounding box.
Valid names for B<arg> are as follows:

	south        => $south
	north        => $north
	east         => $east
	west         => $west
	date         => $date
	minMagnitude => $minmagnitude
	maxRows      => $maxrows

B<south>, B<north>, B<east>, and B<west> and must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=item find_nearby_weather(arg => $arg)

Return the country code for a given point. Valid names for B<arg> are
as follows:

	lat => $lat
	lng => $lng

Both B<lat> and B<lng> must be supplied to
this function.

For a thorough description of the arguments, see
http://www.geonames.org/export

=back

=head1 RETURNED DATASTRUCTURE

The datastructure returned from methods in this module is an array of
hashes. Each array element contains a hash which in turn contains the
information about the placename/postalcode.

For example, running the statement

	my $result = $geo->search(
		q => "Fredrikstad", maxRows => 3, style => "FULL"
		);

yields the result:

	$VAR1 = {
		'population' => {},
		'lat' => '59.2166667',
		'elevation' => {},
		'countryCode' => 'NO',
		'adminName1' => "\x{d8}stfold",
		'fclName' => 'city, village,...',
		'adminCode2' => {},
		'lng' => '10.95',
		'geonameId' => '3156529',
		'timezone' => {
			'dstOffset' => '2.0',
			'content' => 'Europe/Oslo',
			'gmtOffset' => '1.0'
			},
		'fcode' => 'PPL',
		'countryName' => 'Norway',
		'name' => 'Fredrikstad',
		'fcodeName' => 'populated place',
		'alternateNames' => 'Frederikstad,Fredrikstad,Fredrikstad kommun',
		'adminCode1' => '13',
		'adminName2' => {},
		'fcl' => 'P'
		};

The elements in the hashes depends on which B<style> is passed to the
method, but will always contain B<name>, B<lng>, and B<lat> except for
postalcode_country_info(), find_nearest_address(),
find_nearest_intersection(), and find_nearby_streets().

=head1 BUGS

Not a bug, but the GeoNames services expects placenames to be UTF-8
encoded, and all data received from the webservices are also UTF-8
encoded. So make sure that strings are encoded/decoded based on the
correct encoding.

Please report any bugs found or feature requests to
https://rt.cpan.org//Dist/Display.html?Queue=geo-geonames

=head1 SEE ALSO

http://www.geonames.org/export
http://www.geonames.org/export/ws-overview.html

=head1 SOURCE AVAILABILITY

The source code for this module is available from Github
at https://github.com/briandfoy/geo-geonames

=head1 AUTHOR

Per Henrik Johansen, C<< <per.henrik.johansen@gmail.com> >>.

Currently maintained by brian d foy, C<< <brian.d.foy@gmail.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007-2008 by Per Henrik Johansen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
