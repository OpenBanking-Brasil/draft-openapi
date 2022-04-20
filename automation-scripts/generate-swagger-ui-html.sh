#!/usr/bin/env bash

previousApiName=
previousApiDirPath=
jsonArrayTemplate='[%s]'
jsonObjectsBuilt=
jsonArrayBuilt=

PROJECT_ROOT_DIR=`git rev-parse --absolute-git-dir | cut -d '.' -f1`
SWAGGER_BASE_PATH=$PROJECT_ROOT_DIR/swagger-apis

echo "Starting Swagger index.html generation."

for file in $SWAGGER_BASE_PATH/**/*
do
    ext=`echo $file|awk -F . '{print $NF}'`
    apiName=`realpath $file | cut -d '/' -f 9 `

    if [[ $ext == "yml" ]] 
    then
        apiVersion=`basename -s .yml $file`
        jsonObj="{\"name\": \"$apiVersion\", \"url\": \"./$apiVersion.yml\"}"

        if [[ $previousApiName == '' ]] 
        then
            jsonObjectsBuilt=$jsonObj
        elif [[ $previousApiName == $apiName ]] 
        then
            jsonObjectsBuilt="$jsonObjectsBuilt,$jsonObj"
        elif [[ ! -f "$SWAGGER_BASE_PATH/$previousApiName/index.html" ]]
        then
            echo "Generated index.html for $previousApiName API."
            jsonArrayBuilt="[$jsonObjectsBuilt]"
            urlsPrimaryName=`echo $jsonArrayBuilt | jq -r '.[. | length -1].name'`
            cp $PROJECT_ROOT_DIR/swagger-ui-template-page.html "$previousApiDirPath/index.html"

            sed -i "s@{{URLS_SWAGGER_UI}}@$jsonArrayBuilt@" $previousApiDirPath/index.html
            sed -i "s@{{URLS_PRIMARY_NAME_SWAGGER_UI}}@\"$urlsPrimaryName\"@" $previousApiDirPath/index.html

            jsonObjectsBuilt=$jsonObj
        fi
        previousApiDirPath=`dirname $file` 
        previousApiName=$apiName
    fi

done
echo "Swagger index.html generation is done."
