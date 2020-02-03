#!/bin/bash
# 
# Create Buckets and Sync Local Directories into these Buckets.
#   Sync is kept n Days. -> S3 Versioning might be an alternative.
#

function slashes {
  fix=$1
  [ "${fix: -1}" == "/" ] || fix="${fix}/"
  [ "${fix:0:1}" == "/" ] || fix="/${fix}"

  # chomp clumped Slashes
  echo $fix | sed -r 's#/{2,}#/#g'
}

function bucket_exists {
  $AWS ls $BUCKET > /dev/null 2>&1
}

function bucket_sync {
  if [ -e "$SRC" ]; then
    $AWS sync $AES "$SRC" "$DST"
  else
    echo "Source \"$SRC\" does not exist"
    exit 1
  fi
}

function bucket_clean {
  C=$($AWS ls $PARENT | wc -l)
  echo "$C versions found..."
  if [ "$C" -gt "$TTL" ]; then
    for removable in $($AWS ls $PARENT | head -$(($C - $TTL)) | awk '{print $2}'); do
      # echo "Removing $removable ..."
      $AWS rm --recursive "${PARENT}${removable}"
    done
  fi
}

function usage() {
  echo "Sync Files into S3 as Backup."
  echo "A bucket containing the hostname is always createt first."
  echo "Inside this bucket a destination directory is createt. suffixed with the execution date."
  echo -e "X date suffixes are kept.\n"

  echo "usage $0:"
  echo " -d) Destination directory for Syncing. (Defaults to /)"
  echo " -d) Endpoint connecting to. (Defaults to rgw.noris.net)"
  echo " -s) Source directory for syncing"
  echo " -t) Time To Live for sync. (Defaults to 14 Days)"
  echo " -k) Encryption key for sync"
  echo " -l) List Bucket and exit"
  echo " -h) This help message"
  exit 3
}

while getopts "d:e:s:t:k:lh" opt; do
  case $opt in
    d) DST="$OPTARG" ;;
    d) EP="$OPTARG"  ;;
    s) SRC="$OPTARG" ;;
    t) TTL="$OPTARG" ;;
    k) KEY="$OPTARG" ;;
    l) LS=true ;;
    h) usage ;;
   \?) usage ;;
  esac
done

[ -z "$TTL" ] && TTL=14
[ -z "$KEY" ] && usage

PARENT="s3:/$(slashes "$(hostname -f)/${DST}")"
DST="s3:/$(slashes "$(hostname -f)/${DST}/$(date +%F_%H:%M:%S)")"
AWS="aws --endpoint https://${EP:-rgw.noris.net} --profile backup s3"
AES="--sse-c AES256 --sse-c-key $KEY"
BUCKET="s3://$(hostname -f)"

echo -e "Bucket: $DST\n"

if [ -n "$LS" ]; then
  echo "Listing Bucket content..."
  $AWS ls "$PARENT"
  exit 0
fi

if [ -n "$SRC" -a -n "$DST" ]; then
  echo "Checking if bucket exist... "
  bucket_exists || $AWS mb $BUCKET

  echo "Start Syncing..." && bucket_sync
fi

echo "Cleaning old Backups..." && bucket_clean
