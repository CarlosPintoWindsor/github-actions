#!/bin/bash
TEST_RUN=${1}
USER_CREDS=${2}
echo "Monitoring scheduled Run test $TEST_RUN"
echo Trigger Http Rest call

get_schedule_exec_details 



get_schedule_exec_details()(

    local SCHEDULE_ID=${1}

    local HTTP_RESPONSE= $(curl --request GET \
     --url https://testops.katalon.io/api/v1/smart-scheduler/$TEST_RUN \
     --header 'accept: */*' \
     --header "authorization: Basic $USER_CREDS" ` | jq '.' )
    
    echo $HTTP_RESPONSE
)