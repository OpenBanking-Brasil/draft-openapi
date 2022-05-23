#!/bin/bash

#---------------------------------------------------------------------------------
# Objetivo desse script 
# 1 - Recuperar listagem de todas as pastas dentro de swagger-apis
# 2 - Recuperar listagem de todos os arquivos .yml dentro de cada pasta
# 3 - Realizar estrutura do html com listagem das versões mapeadas
# 4 - Selecionar a última versão para servir como referencia inical no swagger. 
#---------------------------------------------------------------------------------

previousApiName=
previousApiDirPath=
jsonObjectsBuilt=
jsonArrayTemplate='[%s]'
jsonArrayBuilt=
jsonObjectsBuiltWithSpace= 
exceptionsDir='central-directory'
PROJECT_ROOT_DIR=`git rev-parse --absolute-git-dir | cut -d '.' -f1`
SWAGGER_BASE_PATH=$PROJECT_ROOT_DIR

echo "Starting Swagger index.html generation."

for fileDirApi in $SWAGGER_BASE_PATH/swagger-apis/**
do
    echo $fileDirApi
    apiName=`realpath $fileDirApi | cut -d '/' -f 9 `
    jsonArrayBuilt= 
    jsonObjectsBuilt= 
    jsonObjectsBuiltWithSpace= 
    for file in $fileDirApi/**
    do 
        echo $file
        ext=`echo $file|awk -F . '{print $NF}'`

        if [[ $ext == "yml" ]] 
        then
            apiVersion=`basename -s .yml $file`
            jsonObj="{\"name\": \"$apiVersion\", \"url\": \"./$apiVersion.yml\"}"
            jsonObjectsBuilt="$jsonObjectsBuilt,$jsonObj"
            jsonObjectsBuiltWithSpace="$jsonObjectsBuiltWithSpace,\n\t\t\t\t\t\t\t\t$jsonObj"
        fi
    done

    if [[ $jsonObjectsBuilt  != ""  ]];then
        modifiedWithSpace="${jsonObjectsBuiltWithSpace:17}"
        modified="${jsonObjectsBuilt:1}"

        jsonArrayBuiltWithSpace="[$modifiedWithSpace]"
        jsonArrayBuilt="[$modified]"

        urlsPrimaryName=`echo $jsonArrayBuilt | jq -r '.[. | length -1].name'`

        cp $SWAGGER_BASE_PATH/swagger-ui-template-page.html "$fileDirApi/index.html"

        sed -i "s@{{URLS_SWAGGER_UI}}@$jsonArrayBuiltWithSpace@" $fileDirApi/index.html
        sed -i "s@{{URLS_PRIMARY_NAME_SWAGGER_UI}}@\"$urlsPrimaryName\"@" $fileDirApi/index.html
    fi
done

echo "Swagger index.html generation is done."
