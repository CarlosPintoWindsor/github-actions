#!/bin/bash
TEST_RUN=${1}
USER_CREDS=${2}
SUCESS_STRING=SUCCESS
echo "Monitoring scheduled Run test $TEST_RUN"
echo Trigger Http Rest call


get_schedule_exec_details()(
    echo "TEst Run: $TEST_RUN - Creds: $USER_CREDS"
    local HTTP_RESPONSE=$(curl --request GET --url https://testops.katalon.io/api/v1/smart-scheduler/$TEST_RUN --header 'accept: */*' --header "authorization: Basic $USER_CREDS"  | jq '.' )
    #echo $HTTP_RESPONSE
    local RUNNING_CONFIG=$(echo $HTTP_RESPONSE | jq '.runConfiguration' )
    local SCHEDULE_NAME=$(echo $RUNNING_CONFIG | jq '.name')
    local SCHEDULE_ID=$(echo $RUNNING_CONFIG | jq '.id')
    local LATEST_JOB=$(echo $RUNNING_CONFIG | jq '.latestJob' )
    local JOB_ID=$(echo $LATEST_JOB | jq '.id')
    local JOB_STATUS=$(echo $LATEST_JOB | jq '.status')
    local EXECUTION_ID=$(echo $LATEST_JOB | jq '.execution.order')
    local JOB_ORDER=$(echo $LATEST_JOB | jq 'order')
    local QUEUED_AT=$(echo $LATEST_JOB | jq '.queuedAt')
    local STARTED_AT=$(echo $LATEST_JOB | jq '.startTime')
    local STOPPED_AT=$(echo $LATEST_JOB | jq '.stopTime')
    echo "Schedule ID: $SCHEDULE_ID - Schedule Name: $SCHEDULE_NAME"
    echo "Latest job Id: $JOB_ID - Job Order: $JOB_ORDER -  Exec Id: $EXECUTION_ID - Job Status: $JOB_STATUS - Queued At: $QUEUED_AT - Started At: $STARTED_AT - Stopped At: $STOPPED_AT "

    if [ "$JOB_STATUS" != "$SUCESS_STRING" ]; then
        echo Sleeping for 30 seconds
        sleep 30
        get_schedule_exec_details
        return "Ok"
    fi;

    echo "Schedule finished "

)


get_schedule_exec_details 