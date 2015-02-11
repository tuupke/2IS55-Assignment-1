<?php

$dotfile = file_get_contents($argv[1]);

preg_match_all("/([A-Z]+[0-9]+ -> [A-Z]+[0-9]+) \#(.*)/", $dotfile, $matches);

echo '\begin{longtable}{lp{11cm}}
';
echo '\textbf{Dependency} & \textbf{Reason} \\\\  \endhead
';
for($i = 0; $i < count($matches[0]); $i++){
    $req = $matches[1][$i];
    $remark = $matches[2][$i];

    $req = str_replace(" -> ", " $\\rightarrow$ ", $req);

    echo "{\\sc $req} & $remark. \\\\ \n";
}

echo '\end{longtable}'
// print_r($matches);

?>
