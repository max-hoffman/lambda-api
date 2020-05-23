set -eoux pipefail

DIR="$( cd "$( dirname "$0" )" && pwd )"
PYTHON_VERSION=${PYTHON_VERSION:-3.7}
PYTHON_LIB=python/lib/python${PYTHON_VERSION}/site-packages

TMP_DIR=$DIR/../tmp
TMP_LOCAL=$TMP_DIR/$PYTHON_LIB

ZIP_OUTPUT=$DIR/../zip/psycopg2.zip

rm -rf $ZIP_OUTPUT $TMP_LOCAL $TMP_DIR/awslambda-psycopg2 \
    && mkdir -p $TMP_LOCAL $DIR/../zip

cd $TMP_DIR

git clone git@github.com:jkehler/awslambda-psycopg2.git
cp -r awslambda-psycopg2/psycopg2-3.7 $TMP_LOCAL/psycopg2

zip -r $ZIP_OUTPUT python
