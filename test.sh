#!/bin/bash
set +x
#ssh key
cat $key > sshkey
cat $env > nb-tb-connector.env
chmod 600 nb-tb-connector.env
chmod 600 sshkey
statusCode=1
APP="nb-tb-connector-prod"
TSTAMP=$(date +%Y.%m.%d-%H.%M.%S)
TSSRV="$TSTAMP $APP:"
RELEASE=$(sed -E -n '/<artifactId>(nb-tb-connector)<\/artifactId>.*/{n;p}' pom.xml | grep -Po '\d\.\d')
Msg="$TSSRV Build in corso"
URL="https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
CHAT="chat_id=${CHAT_ID}"
curl -s -X POST $URL -d $CHAT -d "text=$Msg"
ssh -i sshkey -o "StrictHostKeyChecking no" $USR@$IP "sudo service nb-tb-conn stop"
docker-compose -f nb-tb-connector-test.yaml up -d
while [[ $(docker inspect nb-tb-connector --format='{{.State.Health.Status}}') == 'starting' ]]; do
  echo "starting in progress"
done
if [[ $(docker inspect nb-tb-connector --format='{{.State.Health.Status}}') == 'healthy' ]]
then
  echo "container started"
  appstate=$(curl ${INTIP}:3030/actuator/health | jq -r '.status')
  echo $appstate
  if [[ $appstate == 'UP' ]]; then
    echo "test ok"
    Msg="$TSSRV test ok"
    curl -s -X POST $URL -d $CHAT -d "text=$Msg"
    docker login -u $USERNAME -p $PASSWORD
    docker tag smartcommunitylab/nb-tb-connector:latest smartcommunitylab/nb-tb-connector:$RELEASE
    docker push smartcommunitylab/nb-tb-connector:$RELEASE
    docker push smartcommunitylab/nb-tb-connector:latest
    docker-compose -f nb-tb-connector-test.yaml down
    statusCode=0
  else
    echo "test failed"
    docker-compose -f nb-tb-connector-test.yaml down
    Msg="$TSSRV test failed"
    curl -s -X POST $URL -d $CHAT -d "text=$Msg"
    statusCode=1
  fi
else
  echo "starting containter failed"
  docker-compose -f nb-tb-connector-test.yaml down
  Msg="$TSSRV starting containter failed"
  curl -s -X POST $URL -d $CHAT -d "text=$Msg"
fi
docker-compose -f nb-tb-connector-test.yaml down
docker system prune -a -f
docker volume prune -f
ssh -i sshkey -o "StrictHostKeyChecking no" $USR@$IP "sudo service nb-tb-conn start"
rm sshkey
rm nb-tb-connector.env
echo $statusCode
exit $statusCode
