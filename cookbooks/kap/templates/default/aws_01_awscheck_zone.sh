#!/bin/bash
REGION=$1

# Run command
#/usr/bin/aws ec2 describe-availability-zones --region $REGION
case ${REGION} in
 "")
        RESPONSE=`aws ec2 describe-availability-zones`
        AZ1=`echo "$RESPONSE" | grep ZoneName | awk -F" " '{print $2}'| sed 's/\"//g' | head -1`
        AZ2=`echo "$RESPONSE" | grep ZoneName | awk -F" " '{print $2}'| sed 's/\"//g' | tail -1`
        REGION=`echo "$RESPONSE"| grep RegionName| awk -F" " '{print $2}'|sed 's/"//g'|sed 's/,//g'|head -1`
        ;;
  *)
        RESPONSE=`aws ec2 describe-availability-zones --region $REGION`
	      AZ1=`echo "$RESPONSE" | grep ZoneName | awk -F" " '{print $2}'| sed 's/\"//g' | head -1`
        AZ2=`echo "$RESPONSE" | grep ZoneName | awk -F" " '{print $2}'| sed 's/\"//g' | tail -1`
	;;
esac

#Return output
echo $AZ1","$AZ2","$REGION
