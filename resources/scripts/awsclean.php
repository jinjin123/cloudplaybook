<?php
  if(!file_exists('aws.phar')){
    echo "aws.phar not found. downloading...\n";
    file_put_contents("aws.phar", file_get_contents("http://pear.amazonwebservices.com/get/aws.phar"));
  }
  require 'aws.phar';
  require 'aws.settings.php';


  echo "successfully require aws.phar and aws.settings.php\n";

  $bucket_name = $conf['mobingi_bucket'];
  $group_name = $conf['mobingi_dev_group'];
  $devpolicyname = 'full_access_on_bucket_'.$bucket_name;
  $playerpolicyname = 'full_access_on_bucket_'.$bucket_name;
  $player_role_name = $conf['mobingi_player_role'];
  

  use Aws\S3\S3Client;
  $s3client = S3Client::factory(array(
      'key'    => $conf['aws_key'],
      'secret' => $conf['aws_secret'],
  ));

  use Aws\Iam\IamClient;
  $iamclient = IamClient::factory(array(
      'key'    => $conf['aws_key'],
      'secret' => $conf['aws_secret'],
  ));

  // Del the policies
  try{
    $result = $iamclient->deleteRolePolicy(array(
      // RoleName is required
      'RoleName' => $player_role_name,
      // PolicyName is required
      'PolicyName' => $playerpolicyname,
    ));
    echo "deleted policy $playerpolicyname on role $player_role_name\n";
  }catch(Exception $e){
    echo ">>> ".$e->getMessage()."\n";
  };

  try{
    $result = $iamclient->deleteGroupPolicy(array(
      'GroupName' => $group_name,
      // PolicyName is required
      'PolicyName' => $devpolicyname,
    ));
    echo "deleted policy $playerpolicyname on role $player_role_name\n";
  }catch(Exception $e){
    echo ">>> ".$e->getMessage()."\n";
  };

  // Del the bucket if exist
  try{
    $cnt = $s3client->clearBucket($bucket_name);
    echo "deleted $cnt objects\n";
    $s3client->deleteBucket(array('Bucket' => $bucket_name));
    echo "deleted bucket $bucket_name\n";
  }
  catch(Exception $e){
    echo ">>> ".$e->getMessage()."\n";
  }

  // Del the group if exist

  try{
    $result = $iamclient->deleteGroup(array(
      'GroupName' => $group_name,
    ));
    echo "deleted group $group_name\n";
  }catch(Exception $e){
    echo ">>> ".$e->getMessage()."\n";
  }

  try{
    $result = $iamclient->deleteRole(array(
      // RoleName is required
      'RoleName' => $player_role_name,
    ));
    echo "deleted role $player_role_name\n";
  }catch(Exception $e){
    echo ">>> ".$e->getMessage()."\n";
  }

  use Aws\Sns\SnsClient;
  $snsclient = SnsClient::factory(array(
    'key'    => $conf['aws_key'],
    'secret' => $conf['aws_secret'],
    'region' => $conf['mobingi_region'],
  ));
  $prefix = $conf['mobingi_prefix']."_";
  $result = $snsclient->listPlatformApplications();
  $apptodel = array();
  foreach($result->get('PlatformApplications') as $app){
    $apparn = $app['PlatformApplicationArn'];
    $appname = end(split("/",$apparn));
    if(strpos($appname,$prefix) === 0){
      $apptodel[$appname] = $apparn;
    }
  }
  foreach($apptodel as $appname => $apparn){
    $snsclient->deletePlatformApplication(array('PlatformApplicationArn' => $apparn));
    echo "deleted app named $appname.\n";
  }

  $prefix = $conf['mobingi_prefix']."_";
  $result = $snsclient->listTopics();
  $topictodel = array();
  foreach($result->get('Topics') as $topic){
    $topicarn = $topic['TopicArn'];
    $topicname = end(split(":",$topicarn));
    if(strpos($topicname,$prefix) === 0){
      $topictodel[$topicname] = $topicarn;
    }
  }
  foreach($topictodel as $topicname => $topicarn){
    $snsclient->deleteTopic(array('TopicArn' => $topicarn));
    echo "deleted topic named $topicname.\n";
  }
  echo "end\n";