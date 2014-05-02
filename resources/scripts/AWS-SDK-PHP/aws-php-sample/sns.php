<?php

/*
target:
1 change instance number of auto-scaling group
2 change instance type of auto-scaling group
3 change policy of auto-scaling group

to get more info about AutoScalingClient,visit : http://docs.aws.amazon.com/aws-sdk-php/latest/class-Aws.AutoScaling.AutoScalingClient.html#_updateAutoScalingGroup
*/


// Include the SDK using the Composer autoloader
require 'vendor/autoload.php';

use Aws\S3\S3Client;
use Aws\AutoScaling\AutoScalingClient;
use Aws\Sns\SnsClient;

//MGC-STATUS-CHECK
//MGC-STATUS-CHECK1
//MGC-STATUS-CHECK2
//MGC_STATUS-CHECK3
//MGC_STATUS-CHECK4
//MGC_STATUS-CHECK5
//MGC_STATUS-CHECK6
//MGC_STATUS-CHECK7
$awskey = "AKIAIBTLNC3DJJ32M3QQ";
$awssecret = "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";

$endpoint = "http://gamecloud.mobingi.com/status-check.php";

$regions = array(
  '1' => 'us-east-1',
  '2' => 'us-west-2',
  '3' => 'us-west-1',
  '4' => 'eu-west-1',
  '5' => 'ap-southeast-1',
  '6' => 'ap-southeast-2',
  '7' => 'ap-northeast-1',
  '8' => 'sa-east-1'
);
foreach ($regions as $region){
	$client = SnsClient::factory(array(
		'key' => $awskey,
		'secret' => $awssecret,
		'region' => $region,
	
	));

	
	$result0 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK',
	));
	$result1 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK1',
	));
	$result2 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK2',
	));
	$result3 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK3',
	));
	$result4 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK4',

	));
	$result5 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK5',
	));
	$result6 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK6',
	));
	$result7 = $client->createTopic(array(
		'Name' => 'MGC-STATUS-CHECK7',
	));

	$topicArn_0 = $result0->get("TopicArn");
	$topicArn_1 = $result1->get("TopicArn");
	$topicArn_2 = $result2->get("TopicArn");
	$topicArn_3 = $result3->get("TopicArn");
	$topicArn_4 = $result4->get("TopicArn");
	$topicArn_5 = $result5->get("TopicArn");
	$topicArn_6 = $result6->get("TopicArn");
	$topicArn_7 = $result7->get("TopicArn");

	$sub_result0 = $client->subscribe(array(
		'TopicArn' => $topicArn_0,
		'Protocol' => 'http',
		'Endpoint' => $endpoint,
	));
	$sub_result1 = $client->subscribe(array(
        	'TopicArn' => $topicArn_1,
        	'Protocol' => 'http',
        	'Endpoint' => $endpoint,
	));
	$sub_result2 = $client->subscribe(array(
        	'TopicArn' => $topicArn_2,
        	'Protocol' => 'http',
        	'Endpoint' => $endpoint,
	));
	$sub_result3 = $client->subscribe(array(
        	'TopicArn' => $topicArn_3,
        	'Protocol' => 'http',
        	'Endpoint' => $endpoint,
	));
	$sub_result4 = $client->subscribe(array(
        	'TopicArn' => $topicArn_4,
        	'Protocol' => 'http',
        	'Endpoint' => $endpoint,
	));
	$sub_result5 = $client->subscribe(array(
        	'TopicArn' => $topicArn_5,
        	'Protocol' => 'http',
        	'Endpoint' => $endpoint,
	));
	$sub_result6 = $client->subscribe(array(
        	'TopicArn' => $topicArn_6,
        	'Protocol' => 'http',
        	'Endpoint' => $endpoint,
	));
	$sub_result7 = $client->subscribe(array(
        	'TopicArn' => $topicArn_7,
        	'Protocol' => 'http',
        	'Endpoint' => $endpoint,
	));



}
/*
$client = SnsClient::factory(array(
		'key' => $awskey,
                'secret' => $awssecret,
                'region' => 'us-east-1',
));
*/
//echo $sub_result7;
/*$client = AutoScalingClient::factory(array(
		'key' => 'AKIAIMX7UYHK6NZVYBLQ',
		'secret' => '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',
		'region' => 'ap-northeast-1',

));i
*/











/*
 If you instantiate a new client for Amazon Simple Storage Service (S3) with
 no parameters or configuration, the AWS SDK for PHP will look for access keys
 in the AWS_ACCESS_KEY_ID and AWS_SECRET_KEY environment variables.

 For more information about this interface to Amazon S3, see:
 http://docs.aws.amazon.com/aws-sdk-php-2/guide/latest/service-s3.html#creating-a-client
*/
