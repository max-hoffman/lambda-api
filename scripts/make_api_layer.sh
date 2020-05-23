set -eoux pipefail

DIR="$( cd "$( dirname "$0" )" && pwd )"
BASE_DIR=$DIR/..
PYTHON_VERSION=${PYTHON_VERSION:-3.7}
PYTHON_LIB=python/lib/python${PYTHON_VERSION}/site-packages

DOCKER_MOUNT=/home/quarantoned
MOUNT_PYTHON_TARGET=$DOCKER_MOUNT/tmp/$PYTHON_LIB
MOUNT_PYTHON_SOURCE=$DOCKER_MOUNT/python

TMP_DIR=$DIR/../tmp
ZIP_INPUT=$TMP_DIR/python
ZIP_OUTPUT=$DIR/../zip/quarantoned.zip

rm -rf $ZIP_OUTPUT $ZIP_INPUT \
    && mkdir -p $ZIP_INPUT

cd $BASE_DIR

docker run \
    --rm \
    -v ${BASE_DIR}:${DOCKER_MOUNT}\
    python:${PYTHON_VERSION} \
    python -m pip install ${MOUNT_PYTHON_SOURCE} -t ${MOUNT_PYTHON_TARGET}

cd $TMP_DIR
zip -r $ZIP_OUTPUT python
