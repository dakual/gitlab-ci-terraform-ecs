<?php
header('Content-Type: application/json');
Header('Access-Control-Allow-Origin: frontend');
Header('Access-Control-Allow-Methods: GET');

require_once('../vendor/autoload.php');

$api   = !empty(getenv('API_HOST')) ? getenv('API_HOST') : "http://localhost:5000";
$limit = !empty($_GET["limit"]) ? $_GET["limit"] : 10;
$res   = file_get_contents($api . "/history.php?limit=" . $limit);

echo $res;
?>