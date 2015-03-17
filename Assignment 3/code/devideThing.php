<?php

$storage = array(
	"/mnt/source1",
	"/mnt/source2",
	"/home/ubuntu/ccfinder-src/source/source",
	"/mnt/source3",
	"/mnt/source4",
);

$totalWork = 0;
$workRequired = 60;
$workStart = $workRequired;
$parts = 2;

$todo = ($workStart * ($workStart-1)) / 2;

$workPerPart = $todo / $parts;

$currentWork = 0;

$prevStart = 0;


$locPos = 0;

while(--$workStart){
	$currentWork += $workStart;
	if($currentWork > $workPerPart){
		$end = ($workRequired - $workStart);
		echo "$prevStart-$end\n";
		$currentWork = 0;
		$loc = $storage[$locPos++];
		`screen -d -m /bin/bash -c 'php exec.php $loc $prevStart $end > $prevStart-$end.log 2>$prevStart-$end.err.log'`;
		$prevStart = $end;
	}

}

$end = $workRequired - 1;
echo "$prevStart-$end\n";
`screen -d -m /bin/bash -c 'php exec.php $loc $prevStart $end > $prevStart-$end.log 2>$prevStart-$end.err.log'`;

