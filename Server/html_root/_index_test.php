<?php
/***
	We want UTF8!!!
***/
header('content-type: text/html; charset=utf-8');

/***
	Configuration
***/
include('./config/database.conf.php');
include('./config/common.conf.php');

/***
	Classes and Singletons
***/
include('./singletons/database.singleton.php');

/***
	Database Connection
***/
$db = Database::obtain(DB_SERVER, DB_USER, DB_PASS, DB_DATABASE); 
$db->connect(); 

/***
	The real work
***/
if(isset($_POST['send']))
{
	echo "SEND OK<br>";
	if(strlen($_POST['message']) > 0)
	{
		$sql = "SELECT id, de_udid, de_token FROM $tbl_devices WHERE de_udid = '".$db->escape($_POST['udid'])."'";
		$device = $db->query_first($sql);
		
		$message = array();
		$message['de_id'] = $device['id'];
		$message['me_time'] = $time;
		$message['me_message'] = $_POST['message'];
		$db->insert($tbl_messages, $message);		
		
		echo "MSG OK<br>";
		$message = $_POST['message'];
		$deviceToken = $device['de_token'];
		include('./functions/apns.func.php');
		echo $apns_ret;
		
	}
}
?>

<html>
<head></head>
<body>
<form action="<?php echo $_SERVER['PHP_SELF']; ?>" method="POST">
<select name="udid">
<?php
$sql = "SELECT de_udid FROM $tbl_devices";
$devices = $db->query($sql);
while($device = $db->fetch())
{
	echo "<option value=\"".$device['de_udid']."\">".$device['de_udid']."</option>";
}
?>
</select>
<input type="text" name="message" size="30">
<input type="submit" name="send" value="Send">
</form>
</body>
</html>

<?php
/***
	Database Connrection close
***/
$db->close();
?>