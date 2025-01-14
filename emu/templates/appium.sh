NODECONFIG='{
        "capabilities":
        [
            {
            "maxInstances": 1,
            "platformName": "Android",
            "automationName": "UiAutomator2",
            "deviceId": "'"$DEVICE_ID"'"
            }
        ],
        "configuration":
        {
            "cleanUpCycle":5000,
            "timeout":60000,
            "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
            "maxSession": 6,
            "register": true,
            "registerCycle": 5000,
            "hubPort": 4444,
            "hubHost": "'"$HUB_HOST"'",
            "hubProtocol": "http"
        }
}'

echo $NODECONFIG>nodeconfig-android.json
xvfb-run appium --nodeconfig nodeconfig-android.json --relaxed-security
