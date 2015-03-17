<?php

$folder = scandir("logs");

array_shift($folder);
array_shift($folder);
array_shift($argv);

for($from = $argv[0]; $from < $argv[1]; $from++) {
    $file = $folder[$from];

    preg_match_all("/[0-9]*/", $file, $matches);

    `/home/ubuntu/ccfinder-src/ubuntu32/ccfx m ccfxreturn/$file.ccfxd -w -o metrics/$file.tsv`;
    $cij = array_sum(explode("\n", `cat metrics/$file.tsv | awk 'NR>1 {print $4}'`));

    $i = $matches[0][0];
    $j = $matches[0][2];

    $ci = trim(getLoc($i));
    $cj = trim(getLoc($j));

    $coverage = $cij / ($ci + $cj);

    echo "$i, $ci, $j, $cj, $cij, $coverage\n";
}


function getLoc($file){
    return file_get_contents("/mnt/source1/$file.loc");
}

