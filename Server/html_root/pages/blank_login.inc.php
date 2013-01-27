<?php
/***
	Template-System
***/
$xtpl = new XTemplate("$template_dir/blank_login.html");

/***
	Do the work
***/
$xtpl->assign("php_self", $_SERVER['PHP_SELF']);

if($user_online == 1)
{
	/***
		Parse and output Template
	***/
	$xtpl->parse('main');
	$xtpl->out('main');
}
else
{
	/***
		Parse and output Template
	***/
	$xtpl->parse('error');
	$xtpl->out('error');
}
?>