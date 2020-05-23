set -eoux pipefail

if [ $# -lt 1 ];
    then echo "usage: ./make_layer.sh [PACKAGE]"
    exit 1
fi;

DIR="$( cd "$( dirname "$0" )" && pwd )"
PYTHON_VERSION=${PYTHON_VERSION:-3.7}
PYTHON_LIB=python/lib/python${PYTHON_VERSION}/site-packages

TMP_DIR=$DIR/../tmp
TMP_LOCAL=$TMP_DIR/$PYTHON_LIB
TMP_DOCKER=/home/$PYTHON_LIB

ZIP_INPUT=$TMP_DIR/python
ZIP_OUTPUT=$DIR/../zip/layer.zip

rm -rf $ZIP_OUTPUT \
    && mkdir -p $TMP_LOCAL $DIR/../zip \

cd $TMP_DIR

docker run \
    --rm \
    -v $TMP_LOCAL:$TMP_DOCKER \
    python:${PYTHON_VERSION} \
    python -m pip install $@ -t $TMP_DOCKER

cd $TMP_DIR
zip -r $ZIP_OUTPUT python
