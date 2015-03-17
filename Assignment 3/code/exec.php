<?php


$dir = scandir ("/home/ubuntu/ccfinder-src/source/source/" );

array_shift($dir);
array_shift($dir);

array_shift($argv);

$loc = $argv[0];
for($from = $argv[1]; $from < $argv[2]; $from++) {
	$fromm = $dir[$from];
	for($to = $from + 1; $to < count($dir); $to++) {
		$too = $dir[$to];
		echo "From: $fromm, to: $too\n";
		`/home/ubuntu/ccfinder-src/ubuntu32/ccfx d java -b 50 -dn $loc/$fromm -is -dn $loc/$too -w f-w-g+ -o logs/$fromm-$too`;

	}

}

