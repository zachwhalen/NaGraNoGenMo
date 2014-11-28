#!usr/bin/local/perl

# making a table of contents image, assuming I already have a list of themed chapter titles


@chaps = (
	"THE HAPPENING",
	"THE ENDING",
	"THE THING",
	"THE WISHING",
	"THE PARENTING",
	"THE OPENING",
	"THE ENDING, PART 2",
	"THE WISHING, PART 2"
);


makeToc(@chaps);
	
sub makeToc {
	
	my @chaps = @_;
	# composite label:Default   -geometry +10+10 rings.jpg gravity_default_pos.jpg
	# make canvas
	
	#$c = `composite label:CONTENTS -pointsize 80 -font ManlyMen-BB-Regular -fill "#222222" -geometry +0+200 -gravity north toc.png toc.png`;
	$c = `convert -size 1000x1600 xc:white -fill "#222222" -font ManlyMen-BB-Regular -pointsize 80 -gravity north -annotate +0+200 'CONTENTS' toc.png`;


	$pg = 1; #placeholder

	$dots = '.' x 50;
	my $offset = 0;

	foreach (@chaps){
		$offset += 1;
		$liney = 320 + ($offset * 50);
		$pg += 25;

		$c = `convert toc.png -fill "#222" -font ManlyMen-BB-Regular -pointsize 44 -gravity northeast -annotate +180+$liney '.$dots$pg' toc.png`;
		$c = `convert toc.png -fill "#222" -font ManlyMen-BB-Regular -pointsize 44 -gravity northwest -undercolor white -annotate +180+$liney '$_ ' toc.png`;

		#$c = `convert -page xc:white -fill "#222" -font ManlyMen-BB-Regular -pointsize 44 -gravity northwest -background white -annotate 0 '$_' -layers  toc.png`;

	}
	
}     




	