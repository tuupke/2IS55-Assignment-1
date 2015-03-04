<?php


$contents = scandir('.');

foreach($contents as $dot){
    $fileName = str_replace(".dot", "", $dot);
    if($fileName == $dot){
        continue;
    }
    $fileName = str_replace(".", "", $fileName);
    `dot -Tpdf $dot -o ../rendered/$fileName.pdf`;

}


?>
