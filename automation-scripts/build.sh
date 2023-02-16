#!/usr/bin/env bash
PROJECT_ROOT_DIR=`git rev-parse --absolute-git-dir | cut -d '.' -f1`
DICT_PATH=$PROJECT_ROOT_DIR/dictionary
COMPONENTS_BASE_PATH=$PROJECT_ROOT_DIR/swagger-components
GENERATED_SWAGGERS_PATH=$PROJECT_ROOT_DIR/swagger-apis
GENERATED_DICTIONARIES_PATH=$PROJECT_ROOT_DIR/dictionary
GENERATED_SWAGGERS_TO_GEN_DICTIONARIES_PATH=
TEMP_GEN_DICTIONARY_DIR=$PROJECT_ROOT_DIR/temp-dict-dir
chmod + $PROJECT_ROOT_DIR/automation-scripts/dictionary_generator
mkdir $TEMP_GEN_DICTIONARY_DIR

APIS=(
  "accounts"
 # "acquiring_services"
 # "capitalization_bonds"
  "consents"
  "credit_cards"
  "customers"
 # "exchange"
  "financings"
 # "insurances"
 # "investments"
  "invoice_financings"
  "loans"
  # "payments"
 # "pension"
  "resources"
  "unarranged_accounts_overdraft"
)

function genSwaggerFiles(){
    WITH_REF=$1
    API=$2
    OPTIONS=$3
    API_VERSION=`cat "$COMPONENTS_BASE_PATH/_${API}_apis_part.yml" | yq '.info.version'`
    API_FOLDER_NAME=`echo $API | sed -e 's/_/-/g'`
    API_FOLDER_BASE_PATH=
    [[ $WITH_REF == 1 ]] && API_FOLDER_BASE_PATH="$TEMP_GEN_DICTIONARY_DIR/$API_FOLDER_NAME" || API_FOLDER_BASE_PATH="${GENERATED_SWAGGERS_PATH}/$API_FOLDER_NAME"
    [[ $WITH_REF == 1 ]] && PARAM="-r" || PARAM=""
    swagger-cli bundle \
      $PARAM "$COMPONENTS_BASE_PATH/_${API}_apis_part.yml" \
      --outfile "$API_FOLDER_BASE_PATH/$API_VERSION.yml" --type=yaml
    swagger-cli validate ${GENERATED_SWAGGERS_PATH}/$API_FOLDER_NAME/$API_VERSION.yml

    echo '#### Validations ####'
    RETORNO=`python3 -m openapi_spec_validator "${GENERATED_SWAGGERS_PATH}/$API_FOLDER_NAME/$API_VERSION.yml"`
    echo $RETORNO
    echo '#### End Validations ####'
    
    sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $API_FOLDER_BASE_PATH/$API_VERSION.yml

    if [[ $RETORNO == "OK" ]]
    then

      echo "Starting dictionary"

      if [[ $WITH_REF == 1 ]]
      then
        ruby $PROJECT_ROOT_DIR/automation-scripts/dictionary_generator ${OPTIONS- } \
        -f "$API_FOLDER_BASE_PATH/$API_VERSION.yml" \
        -o $DICT_PATH
        echo $DICT_PATH
      fi
    fi
}

for API in "${APIS[@]}"
do
 genSwaggerFiles 0 $API
 genSwaggerFiles 1 $API '-c'
done
rm -rf $TEMP_GEN_DICTIONARY_DIR
sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $PROJECT_ROOT_DIR/dictionary/*.csv
sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $PROJECT_ROOT_DIR/dictionary/example/*.csv