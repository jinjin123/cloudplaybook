#!/bin/bash
# Clear screen to start
#clear

# Check if config file exists
if [ ! -f ~/.aws/credentials ]
then
#  echo "Please run \"aws configure\" to set your credentials before continuing"
  echo "AWS credential file not found, copying default to your local."
  read -n1 -r -p "Press ENTER/Space to continue...or any key to quit" key

  if [ "$key" = '' ]; then
    # Space pressed, do something
    # echo [$key] is empty when SPACE is pressed # uncomment to trace
    ./scripts/02_awsconfig.sh
    if [ $? -ne 0 ]
    then
        echo "Making AWS credential file failed"
        exit
    else
        echo "Copied default AWS credential file"
    fi    
  else
    # Anything else pressed, do whatever else.
    # echo [$key] not empty
    exit
  fi 
echo "---------------------------------------------"
fi

# Print stack name input message
DEFAULT="KYLIN-"`date +%Y%m%d%H%M%S`

# Accepting input of StackName
read -p "Please input stack names(just enter for default=$DEFAULT):" STACKNAME
#read STACKNAME
COUNT=${#STACKNAME}
if [ $COUNT -eq 0 ];then
    STACKNAME=$DEFAULT
fi
echo "STACKNAME = "$STACKNAME
echo

# Print selection messages
echo "Select Region to be deployed:"
echo "---------------------------------------------"
echo "US East (N. Virginia),     us-east-1:       1"
echo "US West (Oregon),          us-west-2:       2"
echo "US West (N. California),   us-west-1:       3"
echo "EU (Ireland),              eu-west-1:       4"
echo "EU (Frankfurt),            eu-central-1:    5"
echo "Asia Pacific (Singapore),  ap-southeast-1:  6"
echo "Asia Pacific (Tokyo),      ap-northeast-1:  7"
echo "Asia Pacific (Sydney),     ap-southeast-2:  8"
echo "Asia Pacific (Seoul),      ap-northeast-2:  9"
echo "Asia Pacific (Mumbai),     ap-south-1:     10"
echo "South America (São Paulo), sa-east-1:      11"
echo "China Beijing,             cn-north-1:     12"
echo "---------------------------------------------"

CHECK=0
while [ $CHECK != '1' ]
do
echo "Please input region number:(just enter for default zone)"
read REGION_NUM
case ${REGION_NUM} in
  1)
	REGION=us-east-1
        CHECK=1
	;;
  2)
        REGION=us-west-2
        CHECK=1
        ;;
  3)
        REGION=us-west-1
        CHECK=1
        ;;
  4)
        REGION=eu-west-1
        CHECK=1
        ;;
  5)
        REGION=eu-central-1
        CHECK=1
        ;;
  6)
        REGION=ap-southeast-1
        CHECK=1
        ;;
  7)
        REGION=ap-northeast-1
        CHECK=1
        ;;
  8)
        REGION=ap-southeast-2
        CHECK=1
        ;;
  9)
        REGION=ap-northeast-2
        CHECK=1
        ;;
 10)
        REGION=ap-south-1
        CHECK=1
        ;;
 11)
        REGION=sa-east-1
        CHECK=1
        ;;
 12)
        REGION=cn-north-1
        CHECK=1
        ;;
 "")
        CHECK=1
        ;;
  *)
	echo "You MUST input parameters 1-10, please redo"
	;;
esac
done

echo "Running on REGION="$REGION
# Run check zone
echo "---------------------------------------------"
echo "Step 1: Checking availiability zone for specific AWS account" 
ZONE=`./scripts/01_awscheck_zone.sh $REGION`
echo "Usable availiability zones are: "`echo $ZONE|cut -d',' -f1`","`echo $ZONE|cut -d',' -f2`
VAR=$ZONE","$STACKNAME
echo

# Run create VPC
echo "---------------------------------------------"
echo "Step 2: Create VPC"
# debug command
#./test/test.sh $VAR
./scripts/03_deploy_vpc.sh $VAR
if [ $? -ne 0 ]
then
    echo "Create VPC failed"
    exit
fi
echo "Creation succeed, Cloudformation stack name = "$STACKNAME"-vpc"
echo

# Run checking of EC2 key pair
echo "---------------------------------------------"
echo "Step 3: Checking EC2key pair"
./scripts/10_check_create_keypair.sh $VAR
echo

# Run creation of chef server
echo "---------------------------------------------"
echo "Step 4: Creation of Chef Server"
./scripts/04_deploy_chef.sh $VAR
