#!/bin/bash
function check_socket() {
    for ((i=$1;i<$2;i=i+2)); do
        var=`lsof -i:$i;`
        if [[ -z "$var" ]]
        then
            echo $i
            break
        fi
    done
}

GRPC_PORT=$(check_socket 8554 8600)
ADB_PORT_ADMIN=$(check_socket 5554 5600)
ADB_PORT=$(expr $ADB_PORT_ADMIN + 1)
APPIUM_PORT=$(check_socket 4723 4800)

echo $GRPC_PORT $ADB_PORT_ADMIN $ADB_PORT $APPIUM_PORT

HUB_HOST=$(echo $(ip route show | awk '/docker0/ {print $9}'))
echo $HUB_HOST

DEVICE_ID=$(echo $(nanoid))

CONTAINER_ID=$1
sudo nohup docker run \
 --device /dev/kvm \
 --publish $GRPC_PORT:8554/tcp \
 --publish $ADB_PORT_ADMIN:5554/tcp \
 --publish $ADB_PORT:5555/tcp \
 --publish $APPIUM_PORT:4723/tcp \
 -e TOKEN="$(cat ~/.emulator_console_auth_token)" \
 -e ADBKEY="$(cat ~/.android/adbkey)" \
 -e TURN \
 -e HUB_HOST=$HUB_HOST \
 -e DEVICE_ID=$DEVICE_ID \
 ${CONTAINER_ID} &

sleep 180
URL=http://localhost:$APPIUM_PORT/wd/hub/session
DBURL=http://localhost:3000/devices

device_details() {
    echo "Device Details"
    DATA=$(curl --location --request POST $URL \
            --header 'Content-Type: application/json' \
            --data-raw '{
                "desiredCapabilities": {
                    "platformName": "Android"
                }
            }')

    echo $DATA
    DEVICE_API_LEVEL=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['deviceApiLevel'])")
    PLATFORM_VERSION=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['platformVersion'])")
    DEVICE_SCREEN_SIZE=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['deviceScreenSize'])")
    DEVICE_SCREEN_DENSITY=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['deviceScreenDensity'])")
    DEVICE_MODEL=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['deviceModel'])")
    DEVICE_MANUFACTURE=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['deviceManufacturer'])")
    PIXEL_RATIO=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['pixelRatio'])")
    STAT_BAR_HEIGHT=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['statBarHeight'])")
    VIEWPORT_RECT_T=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['viewportRect']['top'])")
    VIEWPORT_RECT_L=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['viewportRect']['left'])")
    VIEWPORT_RECT_W=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['viewportRect']['width'])")
    VIEWPORT_RECT_H=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['value']['viewportRect']['height'])")

    SESSION_ID=$(echo $DATA | python3 -c "import sys, json; print(json.load(sys.stdin)['sessionId'])")

    echo $DEVICE_API_LEVEL $DEVICE_MANUFACTURE $DEVICE_SCREEN_SIZE $DEVICEUDID 
    DBRESPONSE=$(curl --location --request POST $DBURL \
           --header 'Content-Type: application/json' \
           --data-raw '{
                "port": "'"1720"'",
                "tag": "newTag",
                "version": {
                    "android":"'"$DEVICE_API_LEVEL"'",
                    "emulator": "emulator-linux_x64-7324830"
                },
                "status": 2,
                "deviceInfo": {
                    "deviceUDID":"'"$DEVICE_ID"'",
                    "deviceApiLevel":'"$DEVICE_API_LEVEL"',
                    "platformVersion":"'"$PLATFORM_VERSION"'",
                    "deviceScreenSize":"'"$DEVICE_SCREEN_SIZE"'",
                    "deviceScreenDensity":'"$DEVICE_SCREEN_DENSITY"',
                    "deviceModel":"'"$DEVICE_MODEL"'",
                    "deviceManufacturer":"'"$DEVICE_MANUFACTURE"'",
                    "pixelRatio":'"$PIXEL_RATIO"',
                    "statBarHeight":'"$STAT_BAR_HEIGHT"',
                    "viewportRect": {
                        "top":'"$VIEWPORT_RECT_T"',
                        "left":'"$VIEWPORT_RECT_L"',
                        "width":'"$VIEWPORT_RECT_W"',
                        "height":'"$VIEWPORT_RECT_H"'
                    }
                },
                "hostIp": "'"$HUB_HOST"'"
            }')
    
    echo $DBRESPONSE
    DELETE_SESSION=$(curl --location --request DELETE $URL/$SESSION_ID)
    echo $DELETE_SESSION
}

device_details
