#!/usr/bin/local/perl

# testing out a better-looking panel drawing method.
# using Perl just to tinker with and remember all the imagemagick steps

#cleanup from last run

unlink("panel.png");


# import the line image 
my $line = "line0.png";

# first, make a canvas to work with
system("convert -size 500x500 canvas:white panel.png");

# let's make a panel that's 300 x 20

# bearing in mind that line0.gif is 14x3000, pick a random 300 pixels of it.
# should probably just make this a subroutine eventually
$seed = int(rand(700));
system("convert $line -crop 5x300+0+$seed -rotate 90 lineT.png");

$seed = int(rand(700));
system("convert $line -crop 5x300+0+$seed -rotate 90 -alpha set lineB.png");

$seed = int(rand(700));
system("convert $line -crop 5x200+0+$seed -alpha set  lineL.png");

$seed = int(rand(700));
system("convert $line -crop 5x200+0+$seed -alpha set  lineR.png");

# this seems to work
system("convert panel.png -page +30+30 lineT.png -page +30+30 lineL.png -page +325+30 lineR.png -page +30+225 lineB.png -layers flatten paneled.png");


grep "10" | around 