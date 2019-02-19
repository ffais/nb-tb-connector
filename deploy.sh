#!/bin/bash
set +x
#ssh key
cat $key > sshkey
chmod 600 sshkey
statusCode=1
APP="nb-tb-connector-prod"
TSTAMP=$(date +%Y.%m.%d-%H.%M.%S)
TSSRV="$TSTAMP $APP:"
RELEASE=$(sed -E -n '/<artifactId>(nb-tb-connector)<\/artifactId>.*/{n;p}' pom.xml | grep -Po '\d\.\d')
Msg="$TSSRV Deploy in corso"
URL="https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
CHAT="chat_id=${CHAT_ID}"
curl -s -X POST $URL -d $CHAT -d "text=$Msg"
ssh -i sshkey -o "StrictHostKeyChecking no" $USR@$INTIP "kubectl set image deployments/nb-tb-connector nb-tb-connector=smartcommunitylab/nb-tb-connector:$RELEASE"
ssh -i sshkey -o "StrictHostKeyChecking no" $USR@$INTIP "kubectl rollout status deployment nb-tb-connector"
if [[ $? -eq 0 ]]; then
  ssh -i sshkey -o "StrictHostKeyChecking no" $USR@$INTIP "kubectl get deployments nb-tb-connector -o json" > dpstatus
  availableReplicas=$(cat dpstatus | jq -r '.status.availableReplicas')
  updatedReplicas=$(cat dpstatus | jq -r '.status.updatedReplicas')
  readyReplicas=$(cat dpstatus | jq -r '.status.readyReplicas' )
  if [ $availableReplicas == '1' ] && [ $updatedReplicas == '1' ] && [ $readyReplicas == '1' ]; then
    statusCode=0
    Msg="$TSSRV Deploy ok"
    curl -s -X POST $URL -d $CHAT -d "text=$Msg"
  fi
fi
rm sshkey
rm dpstatus
echo $statusCode
exit $statusCode
