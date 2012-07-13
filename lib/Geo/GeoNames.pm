# $Id: GeoNames.pm 30 2007-07-03 18:54:57Z per.henrik.johansen $
package Geo::GeoNames;

use 5.008006;
use strict;
use warnings;
use Carp;
use XML::Simple;
use LWP;

use vars qw($VERSION $DEBUG $GNURL $CACHE %valid_parameters %searches);

our $VERSION = '0.04';
$GNURL = 'http://ws.geonames.org';

%searches = (
	search => 'search?',
	postalcode_search => 'postalCodeSearch?',
	find_nearby_postalcodes => 'findNearbyPostalCodes?',
	postalcode_country_info => 'postalCodeCountryInfo?',
	find_nearby_placename => 'findNearbyPlaceName?',
	find_nearest_address => 'findNearestAddress?',
	find_nearest_intersection => 'findNearestIntersection?',
	find_nearby_streets => 'findNearbyStreets?'
);

# 	r 	= required
#	o	= optional
#	rc	= required - only one of the fields marked with rc is allowed. At least one must be present
#	om	= optional, multible entries allowed
%valid_parameters = (
	search => 	{
				q			=> 'rc',
				name		=> 'rc',
				name_equals	=> 'rc,',
				maxRows 	=> 'o',
				startRow	=> 'o',
				country		=> 'om',
				adminCode1	=> 'o',
				adminCode2	=> 'o',
				adminCode3	=> 'o',
				fclass		=> 'om',
				lang		=> 'o',
				type		=> 'o',
				style		=> 'o'
				},
	postalcode_search => {
				postalcode	=> 'rc',
				placename	=> 'rc',
				country		=> 'o',
				maxRows		=> 'o',
				style		=> 'o'
				},
	find_nearby_postalcodes => {
				lat			=> 'r',
				lng			=> 'r',
				radius		=> 'o',
				maxRows		=> 'o',
				style		=> 'o',
				country		=> 'o',
				},
	postalcode_country_info => {
				},
	find_nearby_placename => {
				lat			=> 'r',
				lng			=> 'r',
				radius		=> 'o',
				style		=> 'o'
				},
	find_nearest_address => {
				lat			=> 'r',
				lng			=> 'r'
				},
	find_nearest_intersection => {
				lat			=> 'r',
				lng			=> 'r'
				},
	find_nearby_streets => {
				lat			=> 'r',
				lng			=> 'r'
				} 				 						
);

sub new {
    my $class = shift;
    my $self = shift;
    my %hash = @_;

	(exists($hash{url})) ? $self->{url} = $hash{url} : $self->{url} = $GNURL;
	(exists($hash{debug})) ? $DEBUG = $hash{debug} : 0;
	(exists($hash{cache})) ? $CACHE = $hash{cache} : 0;
	$self->{_functions} = \%searches;
    bless $self, $class;
    return $self;
}

sub _build_request {
	my $self = shift;
	my $request = shift;
	my $hash = {@_};
	my $request_string = $GNURL . '/' . $searches{$request};
	# check to see that mandatory arguments are present
	my $conditional_mandatory_flag = 0;
	my $conditional_mandatory_required = 0;
	foreach my $arg (keys %{$valid_parameters{$request}}) {
		if($valid_parameters{$request}->{$arg} eq 'r' && !exists($hash->{$arg})) {
			carp("Mandatory argument $arg is missing!");
		} 
		if($valid_parameters{$request}->{$arg} eq 'rc') {
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
		$request_string .= $key . '=' . $hash->{$key} . '&';
	}	
	chop($request_string); # loose the trailing &
	return $request_string;
}

sub _parse_result {
	my $self = shift;
	my $geonamesresponse = shift;
	my @result;
	my $xmlsimple = XML::Simple->new();
	my $xml = $xmlsimple->XMLin($geonamesresponse, KeyAttr=>[], ForceArray => 1);

	my $i = 0;
	foreach my $geoname (@{$xml->{geoname}}) {
		foreach my $attribute (%{$geoname}) {
			next if !defined($geoname->{$attribute}->[0]);
			$result[$i]->{$attribute} = $geoname->{$attribute}->[0];
		}
		$i++;
	} 
	foreach my $address (@{$xml->{address}}) {
		foreach my $attribute (%{$address}) {
			next if !defined($address->{$attribute}->[0]);
			$result[$i]->{$attribute} = $address->{$attribute}->[0];
		}
		$i++;
	} 
	foreach my $code (@{$xml->{code}}) {
		foreach my $attribute (%{$code}) {
			next if !defined($code->{$attribute}->[0]);
			$result[$i]->{$attribute} = $code->{$attribute}->[0];
		}
		$i++;
	} 
	foreach my $country (@{$xml->{country}}) {
		foreach my $attribute (%{$country}) {
			next if !defined($country->{$attribute}->[0]);
			$result[$i]->{$attribute} = $country->{$attribute}->[0];
		}
		$i++;
	} 
	foreach my $intersection (@{$xml->{intersection}}) {
		foreach my $attribute (%{$intersection}) {
			next if !defined($intersection->{$attribute}->[0]);
			$result[$i]->{$attribute} = $intersection->{$attribute}->[0];
		}
		$i++;
	} 
	foreach my $street_segment (@{$xml->{streetSegment}}) {
		foreach my $attribute (%{$street_segment}) {
			next if !defined($street_segment->{$attribute}->[0]);
			$result[$i]->{$attribute} = $street_segment->{$attribute}->[0];
		}
		$i++;
	} 
	return \@result;
}

sub _request {
	my $self = shift;
	my $request = shift;
	my $browser = LWP::UserAgent->new;
	my $response = $browser->get($request);
	carp "Can't get $request -- ", $response->status_line unless $response->is_success;
	return $response->content;
}

sub _do_search {
	my $self = shift;
	my $searchtype = shift;
	my $request = $self->_build_request($searchtype, @_);
	my $result = $self->_request($request);
	return($self->_parse_result($result));
}

sub geocode {
	my $self = shift;
	my $q = shift;
	return($self->search(q=> $q));
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

sub DESTROY {

}
1;
__END__

=head1 NAME

Geo::GeoNames - Perform geographical queries using GeoNames Web Services

=head1 SYNOPSIS

  use Geo::GeoNames;
  use Data::Dumper;
  my $geo = new Geo::GeoNames();
  
  # make a query based on placename
  my $result = $geo->search(q => 'Fredrikstad', maxRows => 2);
  
  # print the first result
  print " Name: " . $result->[0]->{name};
  print " Longitude: " . $result->[0]->{lng};
  print " Lattitude: " . $result->[0]->{lat};
  
  # Dump the data structure into readable form
  # This also will show the attributes to each found location
  Data::Dumper->Dump()
  
  # Make a query based on postcode
  $result = $geo->postalcode_search(postalcode => "1630", maxRows => 3, style => "FULL"); 

=head1 DESCRIPTION

Provides a perl interface to the webservices found at 
http://ws.geonames.org. That is, given a given placename or
postalcode, the module will look it up and return more information
(longitude, lattitude, etc) for the given placename or postalcode.
If more than one match is found, a list of locations will be returned.  

=head1 METHODS

=over 4

=item new 

  $geo = Geo::GeoNames->new()
  $geo = Geo::GeoNames->new(url => $url)

Constructor for Geo::GeoNames. It returns a reference to an Geo::GeoNames object.
You may also pass the url of the webservices to use. The default value is
http://ws.geonames.org and is the only url, to my knowledge, that provides
the services needed by this module.

=item geocode($placename)

This function is just an easy access to search. It is the same as saying:

  $geo->search(q => $placename);

=item search(arg => $arg)

Searches for information about a placename. Valid names for B<arg> are as follows: 

  q => $placename
  name => $placename
  name_equals => $placename
  maxRows => $maxrows
  startRow => $startrow
  country => $countrycode
  adminCode1 => $admin1
  adminCode2 => $admin2
  adminCode3 => $admin3
  fclass => $fclass
  lang => $lang
  type => $type
  style => $style

One, and only one, of B<q>, B<name>, or B<name_equals> must be supplied to 
this function.

For a thorough description of the arguments, see 
http://www.geonames.org/export/geonames-search.html

=item find_nearby_placename(arg => $arg)

Reverse lookup for closest placename to a given coordinate. Valid names for
B<arg> are as follows:

  lat => $lat
  lng => $lng
  radius => $radius
  style => $style

Both B<lat> and B<lng> must be supplied to 
this function.

For a thorough descriptions of the arguments, see 
http://www.geonames.org/export

=item find_nearest_address(arg => $arg)

Reverse lookup for closest address to a given coordinate. Valid names for
B<arg> are as follows:

  lat => $lat
  lng => $lng

Both B<lat> and B<lng> must be supplied to 
this function.

For a thorough descriptions of the arguments, see 
http://www.geonames.org/maps/reverse-geocoder.html

US only.

=item find_nearest_intersection(arg => $arg)

Reverse lookup for closest intersection to a given coordinate. Valid names for
B<arg> are as follows:

  lat => $lat
  lng => $lng

Both B<lat> and B<lng> must be supplied to 
this function.

For a thorough descriptions of the arguments, see 
http://www.geonames.org/maps/reverse-geocoder.html

US only.

=item find_nearby_streets(arg => $arg)

Reverse lookup for closest streets to a given coordinate. Valid names for
B<arg> are as follows:

  lat => $lat
  lng => $lng

Both B<lat> and B<lng> must be supplied to 
this function.

For a thorough descriptions of the arguments, see 
http://www.geonames.org/maps/reverse-geocoder.html

US only.

=item postalcode_search(arg => $arg)

Searches for information about a postalcode. Valid names for B<arg> are as follows: 

  postalcode => $postalcode
  placename => $placename
  country => $country
  maxRows => $maxrows
  style => $style

One, and only one, of B<postalcode> or B<placename> must be supplied to 
this function.

For a thorough description of the arguments, see 
http://www.geonames.org/export

=item find_nearby_postalcodes(arg => $arg)

Reverse lookup for postalcodes. Valid names for B<arg> are as follows:
  lat => $lat
  lng => $lng
  radius => $radius
  maxRows => $maxrows
  style => $style
  country => $country

Both B<lat> and B<lng> must be supplied to 
this function.

For a thorough description of the arguments, see 
http://www.geonames.org/export

=item postalcode_country_info

Returns a list of all postalcodes found on GeoNames. This function
takes no arguments.

=back

=head1 RETURNED DATASTRUCTURE

The datastructure returned from methods in this module is an array of
hashes. Each array element contains a hash which in turn contains the information
about the placename/postalcode.

For example, running the statement

  my $result = $geo->search(q => "Fredrikstad", maxRows => 3, style => "FULL");

yields the result (after doing a Data::Dumper->Dump($result);):

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

The elements in the hashes depends on which B<style> is passed to the method, but
will always contain B<name>, B<lng>, and B<lat> except for postalcode_country_info(),
find_nearest_address(), find_nearest_intersection(), and find_nearby_streets().

=head1 BUGS

Not a bug, but the GeoNames services expects placenames to be
UTF-8 encoded, and all data recieved from the webservices are
also UTF-8 encoded. So make sure that strings are encoded/decoded
based on the correct encoding.

=head1 SEE ALSO

http://www.geonames.org/export

=head1 SOURCE AVAILABILITY

The source code for this module is available from SVN
at http://code.google.com/p/geo-geonames

=head1 AUTHOR

Per Henrik Johansen, E<lt>per.henrik.johansen@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Per Henrik Johansen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
