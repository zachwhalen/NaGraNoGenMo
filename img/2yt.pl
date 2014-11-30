#!/usr/bin/local/perl
# use JSON::Parse 'parse_json';
# use Date::Parse;
use JSON::Parse qw(parse_json json_file_to_perl);
use Date::Parse;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);

my @used = shuffle glob "tmp/used/*.png";

$frame = shift(@used);

print $frame;
exit;


