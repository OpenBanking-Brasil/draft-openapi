#!/usr/bin/env bash


PROJECT_ROOT_DIR=`git rev-parse --absolute-git-dir | cut -d '.' -f1`
DICT_PATH=$PROJECT_ROOT_DIR/dictionary
COMPONENTS_BASE_PATH=$PROJECT_ROOT_DIR/swagger-components
GENERATED_SWAGGERS_PATH=$PROJECT_ROOT_DIR/swagger-apis
GENERATED_DICTIONARIES_PATH=$PROJECT_ROOT_DIR/dictionary
GENERATED_SWAGGERS_TO_GEN_DICTIONARIES_PATH=

chmod + $PROJECT_ROOT_DIR/automation-scripts/dictionary_generator

APIS=(
  "accounts"
  "acquiring_services"
  "capitalization_bonds"
  "consents"
  "credit_cards"
  "customers"
  "exchange"
  "financings"
  "insurances"
  "investments"
  "invoice_financings"
  "loans"
  "payments"
  "pension"
  "resources"
  "unarranged_accounts_overdraft"
)

for API in "${APIS[@]}"
do
  API_VERSION=`cat "$COMPONENTS_BASE_PATH/_${API}_apis_part.yml" | yq '.info.version'`
  API_FOLDER_NAME=`echo $API | sed -e 's/_/-/g'`
  
  swagger-cli bundle \
    -r "$COMPONENTS_BASE_PATH/_${API}_apis_part.yml" \
    --outfile "${GENERATED_SWAGGERS_PATH}/$API_FOLDER_NAME/$API_VERSION.yml" --type=yaml

  swagger-cli validate ${GENERATED_SWAGGERS_PATH}/$API_FOLDER_NAME/$API_VERSION.yml

  ruby $PROJECT_ROOT_DIR/automation-scripts/dictionary_generator ${OPTIONS- } \
    -f "${GENERATED_SWAGGERS_PATH}/$API_FOLDER_NAME/$API_VERSION.yml" \
    -o $DICT_PATH
done

sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $PROJECT_ROOT_DIR/dictionary/*.csv
sed -i '1s/^\(\xef\xbb\xbf\)\?/\xef\xbb\xbf/' $PROJECT_ROOT_DIR/dictionary/example/*.csv