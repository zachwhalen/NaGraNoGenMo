#!/usr/bin/local/perl
# use JSON::Parse 'parse_json';
# use Date::Parse;
use JSON::Parse qw(parse_json json_file_to_perl);
use Date::Parse;
use Date::Format;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);
use DateTime;

my @frontMatter = ("cover", "blank", "titlePage", "about", "toc", "blank");

$pdffront = join(" ", map {"img/tmp/pages/" . $_ . ".pdf"} @frontMatter);

print $pdffront;


exit;


