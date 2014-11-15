#!/usr/bin/local/perl

use File::Basename;
my $base = '/home/zach/Software/pg';
my $path = '/nagranogenmo/NaGraNoGenMo';
# create a 3x3 grid of panels

@files = glob "$base/tube/candidates/*.jpg";


@panels = glob "$base/$path/img/tmp/*.jpg";
foreach (@panels){
	unlink;
}

for ($t = 0; $t <9; $t++){

	$file = $files[int(rand($#files))];

	$fn = basename $file;
	system("convert $file -resize \"1000x\" -crop 200x300+20+20 $base/$path/img/tmp/$fn");

}

@panels = glob "$base/$path/img/tmp/*.jpg";

$pan = join (" ", @panels);

system("montage $pan -tile 3x -geometry +4+4 -border 2.5 -bordercolor #000000 $base/$path/img/page.jpg");

system("convert $base/$path/img/page.jpg -bordercolor \"#ffffff\" -border 12  $base/$path/img/page.jpg")