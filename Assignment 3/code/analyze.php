<?php

$folder = scandir("logs");

array_shift($folder);
array_shift($folder);
array_shift($argv);

for($from = $argv[0]; $from < $argv[1]; $from++) {
    $file = $folder[$from];

    `/home/ubuntu/ccfinder-src/ubuntu32/ccfx m logs/$file -c -o analysis/$file.tsv`;
    `/home/ubuntu/ccfinder-src/ubuntu32/picosel -o filter/$file.txt from analysis/$file.tsv select CID where RNR .ge. 0.5`;
    `/home/ubuntu/ccfinder-src/ubuntu32/ccfx s logs/$file -o ccfxreturn/$file.ccfxd -ci filter/$file.txt`;

}

