#!/bin/bash

# MUST be customized
APITOKEN="..."    # see LeanIX -> Admin -> Developers -> API Tokens
WORKSPACEID="..." # see LeanIX -> Admin -> Developers -> API Tokens
HOSTNAME="https://app.leanix.net" # change the host name if required
CURL="/usr/bin/curl -s" # if curl is not located in /usr/bin, change accordingly

# CAN be customized
EXPORT_FILENAME="export-`date '+%Y-%m-%d'`.xlsx"
SURVEY_FILENAME="poll_result" # for each survery run, we append the id and the survey run + ".xlsx"

# SHOULD NOT be customized (only in case of API changes)
BASEURL="$HOSTNAME/services/pathfinder/v1/exports"
POLLURL="$HOSTNAME/services/poll/v2"
EXPORTSURL="$BASEURL?exportType=SNAPSHOT\&pageSize=40\&sorting=createdAt\&sortDirection=DESC"

function getAccessToken() {
        ACCESSTOKEN=`eval ${CURL} --request POST --url https://app.leanix.net/services/mtm/v1/oauth2/token -u apitoken:$APITOKEN --data grant_type=client_credentials | sed -e "s/.*\"access_token\":\"\([a-zA-Z0-9_\.\-]*\).*/\1/"`
	CURL_AUTH="$CURL --header \"Authorization: Bearer $ACCESSTOKEN\""
}

getAccessToken

echo "Triggering export..."
eval ${CURL_AUTH} --request POST \
  --url "$BASEURL/fullExport?exportType=SNAPSHOT"
echo
echo "Waiting for export to complete, this may take some time..."

while [ "x$STATUS" != "xCOMPLETED" ]; do
	# refreshing the access token in case that the export takes longer than the validity of the token (we never know...)
	getAccessToken
	STATUS=`eval ${CURL_AUTH} \
	  --url "$EXPORTSURL" | python -c 'import sys, json; print json.load(sys.stdin)["data"][0]["status"]'`
	sleep 5
done
echo "Export completed. Downloading..."

DOWNLOAD_KEY=`eval ${CURL_AUTH} \
  --url "$EXPORTSURL" | python -c 'import sys, json; print json.load(sys.stdin)["data"][0]["downloadKey"]'`
URL="$BASEURL/downloads/$WORKSPACEID/?key=$DOWNLOAD_KEY"

eval ${CURL_AUTH} \
  --header 'Accept: application/octet-stream' \
  --url $URL > $EXPORT_FILENAME

echo "Saved to file $EXPORT_FILENAME."
file $EXPORT_FILENAME


echo "Downloading surveys..."
SURVEYSURL="$POLLURL/polls?workspaceId=$WORKSPACEID"
SURVEY_IDS=`eval ${CURL_AUTH} \
  --url "$SURVEYSURL" | python -c 'import sys, json;
res = json.load(sys.stdin)["data"];
for poll in res:
	print poll["id"]+" ";'`

for id in $SURVEY_IDS; do
	SURVEY_RUNS_URL="$POLLURL/polls/$id/pollRuns?workspaceId=$WORKSPACEID"
	SURVEY_RUNS=`eval ${CURL_AUTH} \
	  --url "$SURVEY_RUNS_URL" | python -c 'import sys, json;
res = json.load(sys.stdin)["data"];
for runs in res:
	print runs["id"]+" ";'`
	for run in $SURVEY_RUNS; do
		echo Survey $id, run $run
		URL="$POLLURL/pollRuns/$run/poll_results.xlsx?workspaceId=$WORKSPACEID"
		
		eval ${CURL_AUTH} \
		  --header 'Accept: application/octet-stream' \
		  --url $URL > "$SURVEY_FILENAME-$id-$run.xlsx"
		file "$SURVEY_FILENAME-$id-$run.xlsx"
	done
done
