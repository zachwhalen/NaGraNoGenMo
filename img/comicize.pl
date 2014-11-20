#!/usr/bin/local/perl

# existing images
@frames = glob "tmp/frames/*.png";

# let's grab some frames and do some image processing to make these look more comic-like
for ($p = 0; $p < 9; $p++){

	# pick one
	my $frame = $frames[int(rand($#frames))];

}