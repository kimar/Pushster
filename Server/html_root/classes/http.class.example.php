<?php
include("http.class.php");
$h=new Http;
$h->addString("firstname","Max");
$h->addString("lastname","Muster");
$h->addString("email","max@muster.de");
$h->addFile("cv","lebenslauf.pdf");
$ret=$h->execute("http://www.belbit.com/test.php","My Script/1.00");
echo $ret;
?>