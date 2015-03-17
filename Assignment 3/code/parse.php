<?php

$contents = explode("\n",file_get_contents("results.csv"));
array_pop($contents);


$parsed = array(array());

foreach($contents as $row){

    $row = explode(",",$row);

    if(gettype($parsed[$row[0]]) !== "array"){
        $parsed[$row[0]] = array();
    }

    $parsed[$row[2]][$row[0]] = $row[5];

}

ksort($parsed);

unset($parsed[0]);

foreach ($parsed as $k => &$row){
    ksort($row);
    echo $k.",".implode(",",$row)."\n";
}

$keys = array_keys($parsed);
echo ",".implode(",",$keys);

