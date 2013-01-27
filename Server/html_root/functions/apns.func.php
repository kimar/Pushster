<?php
/*$deviceToken = '85526c2a260d37f132ed77668f3c36522688a4ea71dcad6c6df9687e2010dacd'; // masked for security reason
// Passphrase for the private key (ck.pem file)
// $pass = '';
// Get the parameters from http get or from command line
$message = $_GET['message'];
$badge = (int)$_GET['badge'];
$sound = $_GET['sound'];
*/

$badge = 0;
$sound = "Notify.aiff";

// Construct the notification payload
$body = array();
$body['aps'] = array('alert' => $message);
if ($badge) $body['aps']['badge'] = $badge;
if ($sound) $body['aps']['sound'] = $sound;

$apns_certificates=array('/kunden/321498_30167/pushster/certificates/apns_dev_20120309.pem','/kunden/321498_30167/pushster/certificates/apns_prod_20120309.pem');
$apns_gateways=array('ssl://gateway.sandbox.push.apple.com:2195','ssl://gateway.push.apple.com:2195');

/* End of Configurable Items */
for($i=0;$i<count($apns_certificates);$i++)
{
	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', $apns_certificates[$i]);
	// assume the private key passphase was removed.
	// stream_context_set_option($ctx, 'ssl', 'passphrase', $pass);
	$fp = stream_socket_client($apns_gateways[$i], $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);
	if (!$fp) 
	{
		$apns_ret .= "CONN ERR $err $errstrn<br>";
		return;
	}
	else
	{
		$apns_ret .= "CONN OK<br>";
	}
	$payload = json_encode($body);
	$msg = chr(0) . pack("n",32) . pack('H*', str_replace(' ', '', $deviceToken)) . pack("n",strlen($payload)) . $payload;
	$apns_ret .= "SEND PAYLOAD " . $payload . " OK<br>";
	fwrite($fp, $msg);
	fclose($fp);
}
?>