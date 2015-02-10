#!/usr/bin/php
<?php

function expLine($l){
    return explode(" ", $l);
}

function prepForAnalysis($word) {
    if (strlen($word)>1)
        $word = strtolower($word);
    return str_replace(array(",",".",";",":"),'', $word);
}

function calcScores($keywords, $line){

    $res = array();

    foreach($keywords as $k => $v){
        $res[$k] = 0;

        foreach($v as $word){
            if(strpos($line, $word) !== false){
                $res[$k]++;
            }

        }
    }

    return $res;
}

$contents = file_get_contents(dirname(__FILE__)."/requirements.txt");

$contents = explode("\n", $contents);

$keywords = array(
    "optionality" => array("possibly","eventually","if case","if possible","if appropriate","if needed", "additionally", "and in a more", "there is a need","maybe"),
    "vagueness" => array("clear","easy","strong","good","bad","useful","significant","adequate","recent","praised", "goals", "strict or lenient", "choice","should be consistent to",'"forgiving"',"small","plausible","large","provide hints","complex errors"),
    "underspecification" => array("data flow","control flow","write access","remote access","authorized","access","testing","functional testing","structural testing","unit testing"),
);

echo "
The results of the analysis are:
\\begin{longtable}{|l|p{11cm}|c|c|c|} \\hline
\\textbf{UR} & \\textbf{Description} & \\textbf{O} & \\textbf{V} & \\textbf{U} \\\\ \\hline \\endhead
";

foreach($contents as $ur){
    $split = '/^([A-Z]+[0-9]+) (.*$)/i';
    $replacement = '\\texttt{$1} & $2';
    echo preg_replace($split, $replacement, $ur) . ' & ';

    $tempLine = prepForAnalysis($ur);

    $analysis = calcScores($keywords, $tempLine);

    echo $analysis['optionality'] . ' & ';
    echo $analysis['vagueness'] . ' & ';
    echo $analysis['underspecification'] . ' \\\\ \\hline
';
}

echo "\\end{longtable}

";

foreach($keywords as $key => $val){
    echo "The keywords used for {\\sc $key} are:
\\begin{enumerate}
\\item ".implode("\n \\item ",$val)."
\\end{enumerate}";
}

?>
