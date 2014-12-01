#!/usr/bin/local/perl
# use JSON::Parse 'parse_json';
# use Date::Parse;
use JSON::Parse qw(parse_json json_file_to_perl);
use Date::Parse;
use Date::Format;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);

# assemble 
# this is going to be ugly
print "Assembling...\n";

# a general purpose blank page
system("convert -size 1000x1600 xc:white img/tmp/pages/blank.png");

# front matter
my @frontMatter = ("cover", "blank", "titlePage", "about", "toc", "blank");

# makeBackCover();
my @backMatter = ("end", "blank", "backCover");

# make a PDF
print "Making a PDF .. \n";
system("mogrify -format pdf img/tmp/pages/*.png");

$pdffront = join(" ", map {"img/tmp/pages/" . $_ . ".pdf"} @frontMatter);
my @pdfpages = glob "img/tmp/pages/page-*.pdf";
$pdfs = join(" ", @pdfpages);
$pdfback = join(" ", map {"img/tmp/pages/" . $_ . ".pdf"} @backMatter);


system("pdftk $pdffront $pdfs $pdfback cat output output/book.pdf");




#make a CBR
print "Making a CBR...\n";
system("mogrify -format jpg -quality 80 img/tmp/pages/*.png");
@jpgfront = map {"img/tmp/pages/" . $_ . ".jpg"} @frontMatter;
@jpgpages = glob "img/tmp/pages/page-*.jpg";
@jpgback =  map {"img/tmp/pages/" . $_ . ".jpg"} @backMatter;

my $cbpn = 0;

foreach(@jpgfront){
	$tg = $_;
	$tg =~ s/img\/tmp\/pages\///i;
	$ppn = sprintf("%03d", $cbpn);
	system("mv $_ img/tmp/pages/$ppn-$tg");
	$cbpn += 1;
}
foreach(@jpgpages){
	$tg = $_;
	$tg =~ s/img\/tmp\/pages\///i;
	$ppn = sprintf("%03d", $cbpn);
	system("mv $_ img/tmp/pages/$ppn-$tg");
	$cbpn += 1;
}
foreach(@jpgback){
	$tg = $_;
	$tg =~ s/img\/tmp\/pages\///i;
	$ppn = sprintf("%03d", $cbpn);
	system("mv $_ img/tmp/pages/$ppn-$tg");
	$cbpn += 1;
}

#$cbrpages = join(" ", @jpgfront) . " " . join(" ", @jpgpages) . " " . join(" ", @jpgback);

@cbrpages = glob "img/tmp/pages/*.jpg";
$cbrs = join (" ", @cbrpages);
system("rar a output/book.cbr $cbrpages");


print "Done!?\n";

exit;


