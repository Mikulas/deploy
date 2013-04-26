<?php

require __DIR__ . '/common.php';

$repo = "/Volumes/Cifrita/Web/khanovaskola.cz";
//$repo = "/home/git/repositories/testing.git";

$res = validateConfig($repo, "HEAD");
var_dump($res);
