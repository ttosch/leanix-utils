# MUST be customized
APITOKEN="..."    # see LeanIX -> Admin -> Developers -> API Tokens
WORKSPACEID="..." # see LeanIX -> Admin -> Developers -> API Tokens
HOSTNAME="https://app.leanix.net" # change the host name if required
CURL="/usr/bin/curl -s" # if curl is not located in /usr/bin, change accordingly

# CAN be customized
EXPORT_FILENAME="export-`date '+%Y-%m-%d'`.xlsx"
SURVEY_FILENAME="poll_result" # for each survery run, we append the id and the survey run + ".xlsx"
