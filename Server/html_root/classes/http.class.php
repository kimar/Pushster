<?php
class Http {
	protected $body="";
	protected $boundary="";
	function __construct(){
		$boundary=md5(uniqid(""));
	}
	function addString($name,$value){
		$this->body.="--".$this->boundary."\r\n";
		$this->body.="Content-Disposition: form-data; name=\"$name\"\r\n\r\n";
		$this->body.="$value\r\n";
		return true;
	}
	function addFile($name,$filename,$type="application/octet-stream"){
		if(!is_file($filename)) return false;
		$this->body.="--".$this->boundary."\r\n";
		$this->body.="Content-Disposition: form-data; name=\"$name\"; filename=\"".basename($filename)."\"\r\n";
		$this->body.="Content-Type: $type\r\n\r\n";
		$this->body.=file_get_contents($filename)."\r\n";
		return true;
	}
	function execute($url,$useragent=""){
		if(!preg_match("/^(https?):\/\/(.*?)(\/.*)?$/i",$url,$url_inf)) return false;
		switch(strtolower($url_inf[1])){
			case "http": $protocol="tcp://"; $port=80; break;
			case "https": $protocol="ssl://"; $port=443; break;
		}
		if(!isset($url_inf[3])) $url_inf[3]="/";
		if($this->body==""){
			$headers="GET $url_inf[3] HTTP/1.0\r\n";
		}else{
			$this->body.="--".$this->boundary."--";
			$headers="POST $url_inf[3] HTTP/1.0\r\n";
			$headers.="Content-Type: multipart/form-data; boundary=".$this->boundary."\r\n";
			$headers.="Content-Length: ".strlen($this->body)."\r\n";
		}
		$headers.="Host: $url_inf[2]\r\n";
		if($useragent) $headers.="User-Agent: $useragent\r\n";
		$headers.="\r\n";
		$fp=fsockopen($protocol.$url_inf[2],$port,$errno,$errstr,10);
		if(!$fp) return false;
		fputs($fp,$headers.$this->body);
		while(!feof($fp)) $ret.=fgets($fp);
		fclose($fp);
		$ret=substr($ret,strpos($ret,"\r\n\r\n")+4);
		return $ret;
	}
}
?>