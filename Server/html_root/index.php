<?php
exit();
header('Location: api.php');
/***
	Let's make a session
***/
session_start();

/***
	Configuration
***/
include('./config/database.conf.php');
include('./config/common.conf.php');

/***
	Classes and Singletons
***/
include('./singletons/database.singleton.php');
include('./classes/xtemplate.class.php');
include('./classes/phplivex.class.php');

/***
	Database Connection
***/
$db = Database::obtain(DB_SERVER, DB_USER, DB_PASS, DB_DATABASE); 
$db->connect();

/***
	Online
***/
include('./includes/online.inc.php');

/***
	Functions
***/
include('./includes/functions.inc.php');
include('./includes/userfunctions.inc.php');
include('./includes/settings.inc.php');

/***
	Template Head
***/
include("$pages_dir/head.inc.php");

if(isset($_GET['page']) && file_exists("$pages_dir/".$_GET['page'].".inc.php")) {
	include("$pages_dir/".$_GET['page'].".inc.php");
} else if($_GET['page'] != "" && !file_exists("$pages_dir/".$_GET['page'].".inc.php")) {
	include("$pages_dir/404.inc.php");
} else {
	include("$pages_dir/index.inc.php");
}

include("$template_dir/foot.html");

/***
	Database Connrection close
***/
$db->close();
?>