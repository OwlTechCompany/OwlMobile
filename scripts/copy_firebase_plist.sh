#!/bin/bash

if [ "${CONFIGURATION}" == "Debug Production" ] || [ "${CONFIGURATION}" == "Release Production" ]
then
    SCHEME="Production"
elif [ "${CONFIGURATION}" == "Debug Staging" ] || [ "${CONFIGURATION}" == "Release Staging" ]
then
    SCHEME="Staging"
else
    echo "Unknown configuration: " "${CONFIGURATION}"
    exit 1
fi

GOOGLESERVICE_PLIST_PATH=${PROJECT_DIR}/Owl/Configs/${SCHEME}/GoogleService-Info.plist
PLIST_DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app

echo "Will use scheme ${SCHEME}"
cp "${GOOGLESERVICE_PLIST_PATH}" "${PLIST_DESTINATION}"
echo "Copied ${GOOGLESERVICE_PLIST_PATH} to final destination: ${PLIST_DESTINATION}"
