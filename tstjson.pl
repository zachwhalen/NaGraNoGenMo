#!/usr/bin/local/perl


use JSON::Parse qw(parse_json json_file_to_perl);
use Date::Parse;

sub getDate {
	
	my @jsons = glob "img/tmp/mov/*.json";

	foreach (@jsons){
		
		my $data = json_file_to_perl($_);
		my $ul = $data->{'upload_date'};
		print "UPLOAD DATE: $ul\n";
		close $result;
	}
}