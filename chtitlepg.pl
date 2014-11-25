#!/usr/bin/local/perl

# test titlepage making


@chaps = ("one", "two", "three");

@chup = themeChaps(@chaps);

foreach (@chup){

	print $_ . "\n";
}

sub themeChaps {

	my @chips = @_;

	return @chips;

}
exit;
	# get details from %chapterInfo
	
	my ($ch, $pn, $title, $img) = (3,45,"THe Yawning","img/tmp/covers/ch-1.png");
	$page = `convert -size 1000x1600 xc:white img/tmp/layout.png`;

	$make = `convert img/tmp/layout.png -fill '#222222' -font ManlyMen-BB-Regular -pointsize 60 -gravity north -annotate 0 '\\n\\n\\n\\nChapter $ch:' -pointsize 80 -gravity north -annotate 0 '\\n\\n\\n\\n$title' img/tmp/layout.png`;


	my $tw = 500 * 5 . 'x<';
	my $th = 400 * 5;


	my $sktchgeo = int(rand(15)) + 1 . 'x20+' . int(rand(150)) + 50;  


	my $cropgeo = "650x650+" . int(rand(300)). "+" . int(rand(300));

	$make = `convert $img -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $cropgeo +repage -paint 2 -colorspace gray -sketch $sktchgeo img/tmp/fill.png`;

	$make = `convert img/tmp/fill.png -alpha set -virtual-pixel transparent -channel A -blur 0x40 -level 90%,100% +channel -layers flatten img/tmp/fill.png`;
	$make = `convert img/tmp/layout.png -page +175+500 img/tmp/fill.png -layers flatten img/tmp/layout.png`;

	system("mv img/tmp/layout.png img/tmp/title-$pn.png");
	#cleanUp();

