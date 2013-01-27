<?php
/***
	Configuration
***/
include('../config/database.conf.php');
include('../config/common.conf.php');

/***
	Classes and Singletons
***/
include('../singletons/database.singleton.php');
include('../classes/feed.class.php');

/***
	Functions
***/
include('../functions/main.func.php');
include('../functions/json.func.php');

/***
	Database Connection
***/
$db = Database::obtain(DB_SERVER, DB_USER, DB_PASS, DB_DATABASE); 
$db->connect(); 

/***
	The real work
***/


/***
	Close DB connection
***/
$db->close();

?>