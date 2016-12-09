#!/bin/bash

SOURCE=$1
CONFIG="$PWD/dxr.config"
DXR="$PWD/dxr"

if test -e "$1"
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

COMMAND="cd $DXR && CONFIG=$CONFIG SOURCE=$SOURCE make exe"

echo "Indexing and serving at localhost:8000...(Ctrl-C to stop it)"
echo "Command:"
echo "$COMMAND"

echo "------------------------"

