<?php
/***
	Template-System
***/
$xtpl = new XTemplate("$template_dir/signup.html");

/***
	Do the work
***/
$xtpl->assign("php_self", $_SERVER['PHP_SELF']);

/* Regular Sign up */
if(isset($_POST['signup_regular']))
{
	$xtpl->parse('error');
	$xtpl->out('error');
}

/* One-Click Sign up */
if(isset($_POST['signup_oneclick']))
{
	$xtpl->parse('error');
	$xtpl->out('error');
}

/***
	Parse and output Template
***/
$xtpl->parse('main');
$xtpl->out('main');

?>