<?php
	$username = $argv[1];
	$password = $argv[2];
	$name = "gitkey";
	$file = fopen("./".$name.".pub","rb");
	$fileData = fread($file,filesize("./".$name.".pub"));

	$key = urlencode($fileData);
	
	$label = "auto_deploy";
	$url  = "https://bitbucket.org/api/1.0/users/".$username."/ssh-keys";

	$postCommand = "curl --user ".$username.":".$password." -d '"."label=".$label."&key=".$key."' ".$url;
	$result = shell_exec($postCommand);
	echo $result;

?>
