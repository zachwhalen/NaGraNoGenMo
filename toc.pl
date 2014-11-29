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
	"THE WISHING, PART 2",
	"The wasting",
	"The tickling"
);


makeToc(@chaps);
	
sub makeToc {
	
	my @chaps = @_;
	my $c = `convert -size 1000x1600 xc:white -fill "#222222" -font ManlyMen-BB-Regular -pointsize 80 -gravity north -annotate +0+200 'CONTENTS' toc.png`;

 	# placeholder for practice, iterate for numbers
 	# eventually should get from %chapterInfo

	my $pg = 1;

	$dots = '.' x 50;
	my $offset = 0;

	foreach (@chaps){
		$offset += 1;
		my $liney = 320 + ($offset * 50);
		$pg += 25;

		$c = `convert toc.png -fill "#222" -font ManlyMen-BB-Regular -pointsize 44 -gravity northeast -annotate +180+$liney '.$dots$pg' -gravity northwest -undercolor white -annotate +180+$liney '$_ ' toc.png`;
	}
}  



	