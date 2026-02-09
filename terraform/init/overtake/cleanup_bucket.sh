#!/bin/bash
BUCKET="overtake-eks-apnortheast2-tfstate"

echo "Listing object versions..."
aws s3api list-object-versions --bucket $BUCKET --output=json --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' > versions.json

if grep -q '"Objects": \[' versions.json; then
    echo "Deleting object versions..."
    aws s3api delete-objects --bucket $BUCKET --delete file://versions.json
else
    echo "No object versions found."
fi

echo "Listing delete markers..."
aws s3api list-object-versions --bucket $BUCKET --output=json --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' > markers.json

if grep -q '"Objects": \[' markers.json; then
    echo "Deleting delete markers..."
    aws s3api delete-objects --bucket $BUCKET --delete file://markers.json
else
    echo "No delete markers found."
fi

echo "Deleting bucket..."
aws s3 rb s3://$BUCKET

echo "Cleaning up local files..."
rm versions.json markers.json
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
