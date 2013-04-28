<?php

require_once __DIR__ . '/vendor/autoload.php';


function decline($repo_dir)
{
	@unlink(getLockFile($repo_dir));
	exit(1);
}



function getLockFile($repo_dir)
{
	return "$repo_dir/.deploy_lock";
}



function getProjectName($repo_dir)
{
	$match = array();
	preg_match('~/(?P<project>[^/]*?)\.git$~', $repo_dir, $match);
	return $match['project'];
}



function configExists($repo_dir, $newsha)
{
	return exec("cd $repo_dir; git ls-tree $newsha | grep \"\sdeploy\.json$\" | wc -l") >= 1;
}



function validateConfig($repo_dir, $newsha)
{
	$retriever = new JsonSchema\Uri\UriRetriever;
	$schema = $retriever->retrieve('file://' . __DIR__ . '/deploy_schema.json');
	$data = json_decode(readConfigString($repo_dir, $newsha));

	$validator = new JsonSchema\Validator();
	$validator->check($data, $schema);

	return $validator->isValid() ? FALSE : $validator->getErrors();
}



function readConfigString($repo_dir, $newsha)
{
	$lines = '';
	run("git show $newsha:deploy.json", $repo_dir, function($line) use (&$lines) {
		$lines .= $line;
	});

	return $lines;
}



function readConfig($repo_dir, $newsha)
{
	return json_decode(readConfigString($repo_dir, $newsha), TRUE);
}



/**
 * @returns array of branches the commit it NOT in
 */
function isCommitIn($repo_dir, $branches, $newsha)
{
	run("git branch --contains $newsha", $repo_dir, function($line) use (&$branches) {
		unset($branches[array_search(trim($line), $branches)]);
	});

	return $branches;
}



function getBranchInfo($repo_dir, $branch)
{
	$info = '';
	run("git log -1 --format='%h\013%ci\013%cn\013%s' $branch", $repo_dir, function($line) use (&$info) {
		$info = trim($line);
	});
	if (strpos($info, 'separate paths from revisions') !== FALSE) {
		return FALSE;
	}

	return explode("\013", $info);
}



function beep($times = 1)
{
	echo str_repeat("\x07", $times);
}



function run($cmd, $dir, $callback)
{
	$descs = array(
		array("pipe", "r"),
		array("pipe", "w"),
		array("pipe", "w"),
	);
	$process = proc_open($cmd, $descs, $pipes, $dir);
	if (is_resource($process)) {
		while ($s = fgets($pipes[1])) {
			$callback($s, TRUE);
		}
		while ($s = fgets($pipes[2])) {
			$callback($s, FALSE);
		}
	}
}
