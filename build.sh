#!/bin/bash

CONFIG="$PWD/dxr.config"
DXR="$PWD/dxr"
DXR_PORT=8000

PRINT_USAGE() {
    echo ""
    echo "./build.sh --source=<absolute path to the source directory> [options]"
    echo ""
    echo "options:"
    echo "    --detach                      run in background as a service"
    echo "    --port=PORT                   which host port should be used to serve indexed codebase (default: 8000)"
    echo "    --command=DXR_COMMAND         what command should be executed inside the DXR container; can be file path (default: index & serve)"
    echo "    --x-disable-private-volume    workaround for read-only container failure"
    echo "    --x-force-compose-api-118     workaround to export COMPOSE_API_VERSION=1.18"
    echo ""
}


while [[ $# -gt 0 ]]; do
    case "$1" in
    --source=*)
        SOURCE=$1
        SOURCE="${SOURCE:9}"  # trim the option itself to get values after "--source="
        ;;

    --port=*)
        DXR_PORT=$1
        DXR_PORT="${DXR_PORT:7}"
        ;;

    --detach)
        DETACH="1"
        ;;

    --command=*)
        DXR_COMMAND=$1
        DXR_COMMAND="${DXR_COMMAND:10}"
        ;;

    --x-disable-private-volume)
        DISABLE_PRIVATE_VOLUME="1"
        ;;

    --x-force-compose-api-118)
        COMPOSE_API_FLAG="COMPOSE_API_VERSION=1.18"
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

# make the command script if user didn't specify one.
if test -z ${DXR_COMMAND+x}
then
  DXR_COMMAND="make all && cd /home/dxr && dxr index --config /home/dxr/dxr.config && dxr serve --all --port $DXR_PORT"
fi

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


if test -f "$SOURCE/cxx"
then
  echo "CXX wrapper copying succeed"
else
  echo "ERROR: Cannot find the CXX wrapper under: $SOURCE"
  exit -1
fi

if test -f "$SOURCE/cc"
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

# if "command" is not a file path:
if [ ! -f "$DXR_COMMAND" ];
then
  DXR_COMMAND_FILE="`mktemp`"
  echo "#!/bin/bash"  >> $DXR_COMMAND_FILE
  echo "$DXR_COMMAND" >> $DXR_COMMAND_FILE
else
  DXR_COMMAND_FILE="$DXR_COMMAND"  
fi

COMMAND="cd $DXR && CONFIG=$CONFIG SOURCE=$SOURCE DXR_COMMAND_FILE=$DXR_COMMAND_FILE DXR_PORT=$DXR_PORT $ZFLAG $COMPOSE_API_FLAG make run"
COMMAND_FILE="`mktemp`"
echo "#!/bin/bash" >> $COMMAND_FILE
echo "$COMMAND" >> $COMMAND_FILE

echo "Indexing and serving at localhost:$PORT...(Ctrl-C to stop it)"
echo "Command:"
echo "$COMMAND"

echo "------------------------"
if [ "1" == "$DETACH" ];
then
  nohup bash $COMMAND_FILE &
else
  bash $COMMAND_FILE
fi

