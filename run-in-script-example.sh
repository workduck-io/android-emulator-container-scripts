CONTAINER_ID=$1
shift
PARAMS="$@"
sudo docker run \
 --device /dev/kvm \
 --publish 8554:8554/tcp \
 --publish 5554:5554/tcp \
 --publish 5555:5555/tcp \
 --publish 4723:4723/tcp \
 --publish 1717:1717/tcp \
 -e TOKEN="$(cat ~/.emulator_console_auth_token)" \
 -e ADBKEY="$(cat ~/.android/adbkey)" \
 -e TURN \
 -e EMULATOR_PARAMS="${PARAMS}"  \
 ${CONTAINER_ID}