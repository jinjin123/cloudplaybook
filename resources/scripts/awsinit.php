<?php
  if(!file_exists('aws.phar')){
    echo "aws.phar not found. downloading...\n";
    file_put_contents("aws.phar", file_get_contents("http://pear.amazonwebservices.com/get/aws.phar"));
  }
  require 'aws.phar';
  require 'aws.settings.php';

  use Aws\S3\S3Client;
  echo "successfully require aws.phar and aws.settings.php\n";


  // Instantiate the S3 client with your AWS credentials and desired AWS region
  $s3client = S3Client::factory(array(
      'key'    => $conf['aws_key'],
      'secret' => $conf['aws_secret'],
  ));

  $bucket_name = $conf['mobingi_bucket'];
  $bucketpolicy = '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1387263171000",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "s3:GetBucketPolicy",
        "s3:GetBucketVersioning",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectTorrent",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTorrent",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectVersionAcl"
      ],
      "Resource": [
        "arn:aws:s3:::'.$bucket_name.'*"
      ]
    }
  ]
}';

  echo "creating bucket $bucket_name...\n";
  $result = $s3client->createBucket(array(
    'ACL'                 => 'public-read-write',
    'Bucket'              => $bucket_name,
    'LocationConstraint'  => $conf['mobingi_region'],
    ));
  echo "successfully create s3bucket $bucket_name\n";
  print_r($result);

  use Aws\Iam\IamClient;
  $group_name = $conf['mobingi_dev_group'];
  $devpolicyname = 'mobingi_developer_policy';
  $iamclient = IamClient::factory(array(
      'key'    => $conf['aws_key'],
      'secret' => $conf['aws_secret'],
  ));
  echo "trying to create group:$group_name...\n";
  $result = $iamclient->createGroup(array(
      'GroupName' => $group_name,
      'Path' => '/mobingi/',
    ));
  echo "Adding policy to group $group_name...\n";
  $result = $iamclient->putGroupPolicy(array(
      'GroupName' => $group_name,
      'PolicyName' => 'full_access_on_bucket_'.$bucket_name,
      'PolicyDocument' => $bucketpolicy,
    ));
  echo "successfully create group $group_name\n";

  //Add role for facebook login
  $player_role_name = $conf['mobingi_player_role'];
  $iamclient->createRole(array(
    'Path' => '/mobingi/',
    'RoleName' => $player_role_name,
    'AssumeRolePolicyDocument' => '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"sts:AssumeRoleWithWebIdentity","Principal":{"Federated":"graph.facebook.com"}}]}',
  ));
  echo "successfully create role $player_role_name\n";
  $result = $iamclient->putRolePolicy(array(
    // RoleName is required
    'RoleName' => $player_role_name,
    // PolicyName is required
    'PolicyName' => 'full_access_on_bucket_'.$bucket_name,
    // PolicyDocument is required
    'PolicyDocument' => $bucketpolicy,
));
