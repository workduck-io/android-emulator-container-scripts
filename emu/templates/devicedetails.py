import requests
import json
import time 

time.sleep(150)
URL = "http://localhost:4723/wd/hub/session/"

payload = json.dumps({
    "desiredCapabilities": {
        "platformName": "Android",
        "automationName":"UiAutomator2"
    }
})
headers = {
    'Content-Type': 'application/json'
}

response = requests.request("POST", url=URL, headers=headers, data=payload)
data = response.json()

# deviceInfoDetails = {}
# deviceInfoDetails = dict({
#     "deviceUDID": data['value']['deviceUDID'],
#     "deviceApiLevel": data['value']['deviceApiLevel'],
#     "platformVersion": data['value']['platformVersion'],
#     "deviceScreenSize": data['value']['deviceScreenSize'],
#     "deviceScreenDensity": data['value']['deviceScreenDensity'],
#     "deviceModel": data['value']['deviceModel'],
#     "deviceManufacturer": data['value']['deviceManufacturer'],
#     "pixelRatio": data['value']['pixelRatio'],
#     "statBarHeight": data['value']['statBarHeight'],
#     "viewportRect": data['value']['viewportRect']
# })

# print(deviceInfoDetails)

# # dbURL = ""
# # dbPayload = json.dumps(deviceInfoDetails)
# # dbResponse = requests.request(
# #     "POST", url=dbURL, headers=headers, data=dbPayload)
# # print(dbResponse)

# deleteURL = "http://localhost:4723/wd/hub/session/" + data['sessionId']
# deleteResponse = requests.request("DELETE", url=deleteURL)
# print(deleteResponse)

print(data)
