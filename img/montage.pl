#!/usr/bin/local/perl

use File::Basename;

# create a 3x3 grid of panels

@files = glob "/home/zach/Software/pg/tube/candidates/*.jpg";


@panels = glob "/home/zach/Software/pg/fifty/img/tmp/*.jpg";
foreach (@panels){
	unlink;
}

for ($t = 0; $t <9; $t++){

	$file = $files[int(rand($#files))];

	$fn = basename $file;
	system("convert $file -resize \"1000x\" -crop 200x300+20+20 tmp/$fn");

}

@panels = glob "/home/zach/Software/pg/fifty/img/tmp/*.jpg";

$pan = join (" ", @panels);

system("montage $pan -tile 3x -geometry +4+4 -border 2 -bordercolor #202020 /home/zach/Software/pg/fifty/img/page.jpg");

system("convert /home/zach/Software/pg/fifty/img/page.jpg -bordercolor \"#ffffff\" -border 12  /home/zach/Software/pg/fifty/img/page.jpg")