#!/bin/bash

CONFIG="$PWD/dxr.config"
DXR="$PWD/dxr"
PORT=8000

PRINT_USAGE() {
    echo ""
    echo "./build.sh --source=<absolute path to the source directory> [options]"
    echo ""
    echo "options:"
    echo "    --port=PORT                   which host port should be used to serve indexed codebase (default: 8000)"
    echo "    --x-disable-private-volume    workaround for read-only container failure"
    echo ""
}


while [[ $# -gt 0 ]]; do
    case "$1" in
    --source=*)
        SOURCE=$1
        SOURCE="${SOURCE:9}"  # values after "--source="
        ;;

    --port=*)
        PORT=$1
        PORT="${PORT:7}"
        ;;

    --x-disable-private-volume)
        DISABLE_PRIVATE_VOLUME="1"
        ;;

    -h | --help)
        PRINT_USAGE
        exit
        ;;

    -v | --verbose)
        _VERBOSE="V=1"
        ;;

    *)
        echo "Unknown option $1"
        PRINT_USAGE
        exit -1
        ;;
    esac

    shift
done

if test -e "$SOURCE"
then
  echo "Found the source at: $SOURCE"
else
  echo "ERROR: Cannot find the source at: $SOURCE"
  exit -1
fi

echo "Copy the CXX and CC wrappers into the source directory"
cp wrapper-clang++.sh "$SOURCE/cxx"
cp wrapper-clang.sh "$SOURCE/cc"


if test -e "$SOURCE/cxx"
then
  echo "CXX wrapper copying succeed"
else
  echo "ERROR: Cannot find the CXX wrapper under: $SOURCE"
  exit -1
fi

if test -e "$SOURCE/cc"
then
  echo "CC wrapper copying succeed"
else
  echo "ERROR: Cannot find the CC wrapper under: $SOURCE"
  exit -1
fi

ZFLAG=""
if [ "1" != "$DISABLE_PRIVATE_VOLUME" ]
then
  ZFLAG="Z=\":Z\""
fi

COMMAND="cd $DXR && CONFIG=$CONFIG SOURCE=$SOURCE PORT=$PORT $ZFLAG make exe"

echo "Indexing and serving at localhost:$PORT...(Ctrl-C to stop it)"
echo "Command:"
echo "$COMMAND"

echo "------------------------"
eval "$COMMAND"

