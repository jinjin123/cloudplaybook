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

$client = AutoScalingClient::factory(array(
		'key' => 'AKIAIMX7UYHK6NZVYBLQ',
		'secret' => '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',
		'region' => 'ap-northeast-1',

));
//change min-size to 2  of auto-scaling group,max-size could not be smaller thanmin-size



//target 1
$testGroup = "dev-auto";
$result = $client->updateAutoScalingGroup(array(
			'AutoScalingGroupName' => $testGroup,
			'MinSize' => 2,
			'MaxSize' => 2,
));// this will result to current instance number of auto-scaling group to 2
// we can also use this method to decrease the number of auto-scaling group
echo $result

//

//target 2 change instance type
/*
the change of instance type will lead to the change of launch configuration of chefclients which we use cloudformation  created, it will make things too complex,so if user want to change the instance type of their auto-scaling group ,I recommend that we should just delete the old chefclient stack,and create a new one,before creating the new stack ,we just change some parameters which will be used for chefClient.template,in this case ,we just change parameter instance-type,and recreated the chefclients

Some places to note:
1. before deleting user's old chefclient stack,we may save some settings made by user,and adapt these settings to the new stack
2. before creating new chefcients,we should delete node and client from chefServer ,or new chefclients registration will fail. 

*/

//target 3 change policy
/*
I assume this means we should enable user changing policy of auto-scale-out or auto-scale-in . This is associated with creating scheduled sacling action ,creating alarm and associated them together with our chefclients . I do not know if this is a good idea as we should maintain part of thease resources in our own hand if we did so. Maybe we really need a compiler which could auto-generate cloudformation template,and in this case,we just update an existing stack template,and leave the maintainment to the cloudformation .

*/





/*
 If you instantiate a new client for Amazon Simple Storage Service (S3) with
 no parameters or configuration, the AWS SDK for PHP will look for access keys
 in the AWS_ACCESS_KEY_ID and AWS_SECRET_KEY environment variables.

 For more information about this interface to Amazon S3, see:
 http://docs.aws.amazon.com/aws-sdk-php-2/guide/latest/service-s3.html#creating-a-client
*/
