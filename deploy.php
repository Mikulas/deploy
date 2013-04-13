<?php

if (in_array('--force', $argv) || in_array('-f', $argv)) {
	die("Hell no!\n");
}

if ($argc !== 2 || !in_array($argv[1], ['staging', 'production'])) {
	die('Usage: deploy (staging|production)');
}

$target = $argv[1];

$cwd = getcwd();
$cmd = "cd $cwd; git push deploy master:$target";

$descriptorspec = [
	0 => ['pipe', 'r'],
	1 => ['pipe', 'w'],
	2 => ['pipe', 'w'],
];
$pipes = [];

$process = proc_open($cmd, $descriptorspec, $pipes, __DIR__, []);
if (is_resource($process)) {
	while ($s = fgets($pipes[1])) {
		onLineRead($s);
	}
	while ($s = fgets($pipes[2])) {
		onLineRead($s, TRUE);
	}
}


function onLineRead($line, $error = FALSE)
{
	$count = 0;

	$line = trim(preg_replace('~^remote:\s+~', '', $line));

	$line = str_replace("&cr;", "\r", $line);
	$line = str_replace("&tb;", "\t", $line);
	$line = str_replace("&nl;", "\n", $line);

	$match = [];
	if (preg_match('~^_block:\s*(?P<value>.*)$~', $line, $match)) {
		echo "\033[32m$match[value]\033[1m\n";

	} else {
		echo $line;
	}
}
