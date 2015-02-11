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
    "optionality" => array("possibly","eventually","if case","if possible","if appropriate","if needed", "maybe","and/or", "option"),
    "vagueness" => array("clear","easy","strong","good","bad","useful","significant","adequate","recent","praised", "goals", "strict or lenient", "choice","should be consistent to",'"forgiving"',"small","plausible","large","complex errors","intuitive","and in a way","accurately"),
    "underspecification" => array("data flow","control flow","write access","remote access","authorized","access","testing","functional testing","structural testing","unit testing","and in a way","teaching preferences", "on-line support"),
);

if(in_array("analyze",$argv)){

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
}

if(in_array("report",$argv)){
    $output = array();

    foreach($keywords as $k => $v){
        $output[$k] = "";
    }


    foreach($contents as $ur){
        $split = '/^([A-Z]+[0-9]+) (.*$)/i';
        $replacement = '\\texttt{$1} & $2';
        preg_match($split, $ur, $spl);
        // print_r($spl);
        $tempLine = prepForAnalysis($spl[2]);

        $analysis = calcScores($keywords, $tempLine);
        foreach($analysis as $k => $v){
            if($v != 0){
                $output[$k] .= '\item['.$spl[1]."] a\n";
            }
        }
    }

    foreach($output as $k => $v){
        echo "The user requirements that match for {\\sc $k} are:
\\begin{itemize}
".$v."
\\end{itemize}

";
    }
    // print_r($output);
}

if(in_array("keywords", $argv)){
foreach($keywords as $key => $val){
    echo "The keywords used for {\\sc $key} are:
\\begin{itemize} \\itemsep0em
\\item ".implode("\n \\item ",$val)."
\\end{itemize}";
}
}

?>
