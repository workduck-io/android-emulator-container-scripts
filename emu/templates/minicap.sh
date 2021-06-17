# Copyright 2019 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is the forwarding port. Higher ports are preferred as to not interfere
# with $ADB_PATH's ability to scan for emulators.
sleep 180
ADB_PATH=android/sdk/platform-tools/adb
ABI=$($ADB_PATH shell getprop ro.product.cpu.abi)
SDK=$($ADB_PATH shell getprop ro.build.version.sdk)
install_minicap() {
  echo "Installing minicap"
  $ADB_PATH push /root/node_modules/minicap-prebuilt/prebuilt/$ABI/lib/android-$SDK/minicap.so /data/local/tmp/minicap.so
  $ADB_PATH push /root/node_modules/minitouch-prebuilt/prebuilt/$ABI/bin/minitouch /data/local/tmp/minitouch
  $ADB_PATH push /root/node_modules/minicap-prebuilt/prebuilt/$ABI/bin/minicap /data/local/tmp/minicap
  $ADB_PATH shell chmod 755 /data/local/tmp/minicap
  $ADB_PATH shell chmod 755 /data/local/tmp/minitouch
  $ADB_PATH shell chmod 644 /data/local/tmp/minicap.so
  ADB_OUTPUT=$($ADB_PATH shell LD_LIBRARY_PATH=/data/local/tmp /data/local/tmp/minicap -i)
  echo $ADB_OUTPUT
  WIDTH=$(echo $ADB_OUTPUT | python3 -c "import sys, json; print(json.load(sys.stdin)['width'])")
  HEIGHT=$(echo $ADB_OUTPUT | python3 -c "import sys, json; print(json.load(sys.stdin)['height'])")
  
  nohup $ADB_PATH shell LD_LIBRARY_PATH=/data/local/tmp /data/local/tmp/minicap -P ${WIDTH}x${HEIGHT}@$(expr $WIDTH / 2)x$(expr $HEIGHT / 2)/0 &
  echo Width : $WIDTH, Height : $HEIGHT
  $ADB_PATH forward tcp:1717 localabstract:minicap
  echo "Installed minicap"
}

install_minicap