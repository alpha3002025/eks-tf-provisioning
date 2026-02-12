import boto3
import sys

def delete_all_objects(bucket_name):
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name)
    
    # Check if bucket exists
    try:
        s3.meta.client.head_bucket(Bucket=bucket_name)
    except:
        print(f"Bucket {bucket_name} does not exist.")
        return

    print(f"Deleting all objects and versions from {bucket_name}...")
    
    # Delete all object versions (including delete markers)
    bucket.object_versions.delete()
    
    # Delete all objects (just in case versions are not enabled somehow)
    bucket.objects.all().delete()
    
    print(f"Bucket {bucket_name} emptied.")
    
    # Delete the bucket itself
    print(f"Deleting bucket {bucket_name}...")
    bucket.delete()
    print(f"Bucket {bucket_name} deleted successfully.")

if __name__ == "__main__":
    bucket_name = "overtake-eks-apnortheast2-tfstate"
    delete_all_objects(bucket_name)
