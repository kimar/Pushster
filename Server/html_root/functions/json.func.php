<?php
/***
	Some JSON functions
***/
function send_json_error_response($errorCode, $errorMsg, $reqId) {
	$arr = array('error_code'=>$errorCode, 'error_msg'=>$errorMsg, 'req_id'=>$reqId);
	echo json_encode($arr);
}

function send_json_response($response_array) {
	echo json_encode($response_array);
}
?>