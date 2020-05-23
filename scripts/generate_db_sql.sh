set -eoux pipefail

DIR="$( cd "$( dirname "$0" )" && pwd )"

SCHEMA_NAME=schema

PRIVATE_PATH=$DIR/../db/${SCHEMA_NAME}_private.sql
PUBLIC_PATH=$DIR/..//db/${SCHEMA_NAME}.sql

rm -rf $PUBLIC_PATH

sed "s/${SCHEMA_NAME}_private/${SCHEMA_NAME}/g" $PRIVATE_PATH > $PUBLIC_PATH
