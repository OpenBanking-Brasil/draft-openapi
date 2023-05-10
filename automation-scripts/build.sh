#!/usr/bin/env bash

PATH_PARM1="$1"
PROJECT_ROOT_DIR=`git rev-parse --absolute-git-dir | cut -d '.' -f1`
PATH_PARM1=$PROJECT_ROOT_DIR'/swagger-apis/'$PATH_PARM1
echo 'Verificando arquivo: '$PATH_PARM1

if [ -f "$PATH_PARM1" ]
then

  DICT_PATH=$PROJECT_ROOT_DIR/dictionary

  TEMP_GEN_DICTIONARY_DIR=$PROJECT_ROOT_DIR/temp-dict-dir
  OPTIONS='-c'

  chmod + $PROJECT_ROOT_DIR/automation-scripts/dictionary_generator
  mkdir $TEMP_GEN_DICTIONARY_DIR

  API_FOLDER_BASE_PATH="$TEMP_GEN_DICTIONARY_DIR"

  swagger-cli bundle \
        "-r " + $PATH_PARM1 \
        --outfile "$API_FOLDER_BASE_PATH/temp.yml" --type=yaml

  PATH_PARM1="$API_FOLDER_BASE_PATH/temp.yml"

  ruby $PROJECT_ROOT_DIR/automation-scripts/dictionary_generator ${OPTIONS- } \
  -f $PATH_PARM1 \
  -o $DICT_PATH

  rm -rf $TEMP_GEN_DICTIONARY_DIR
  sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $PROJECT_ROOT_DIR/dictionary/*.csv
  sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $PROJECT_ROOT_DIR/dictionary/example/*.csv
else
   echo "Arquivo não encontrado"
fi