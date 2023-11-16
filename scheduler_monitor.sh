#!/bin/bash
TEST_RUN=${1}
PROJECT_ID=${2}
USER_CREDS=${3}

SUCESS_STRING=SUCCESS
FAILED_STRING=FAILED
SLEEP_TIME=30
echo "Monitoring scheduled TestRun: $TEST_RUN for ProjectId: $PROJECT_ID "
echo 


get_schedule_exec_details()(
    echo "Test Run: $TEST_RUN"
    echo
    local HTTP_RESPONSE=$(curl --request GET --url https://testops.katalon.io/api/v1/smart-scheduler/$TEST_RUN --header 'accept: */*' --header "authorization: Basic $USER_CREDS"  | jq '.' )
    #echo $HTTP_RESPONSE
    local RUNNING_CONFIG=$(echo $HTTP_RESPONSE | jq '.runConfiguration' )
    local SCHEDULE_NAME=$(echo $RUNNING_CONFIG | jq -r '.name')
    local SCHEDULE_ID=$(echo $RUNNING_CONFIG | jq -r '.id')
    local LATEST_JOB=$(echo $RUNNING_CONFIG | jq '.latestJob' )
    local EXECUTION_ID=$(echo $LATEST_JOB | jq -r '.execution.order')
    echo
    echo "Schedule ID: $SCHEDULE_ID - Schedule Name: $SCHEDULE_NAME"
    echo
    # https://testops.katalon.io/api/v1/executions?projectId=1099142&order=620
    #Y2FybG9zcEB3aW5kc29yc3RvcmUuY29tOjE0MjBjYTQzLTc1YjUtNDI3YS04ZDkwLWY2ZTY0NGE4OTJhMw==
    local TEST_RUN_RESPONSE=$(curl --request GET --url "https://testops.katalon.io/api/v1/executions?projectId=1099142&order=621" --header 'accept: */*' --header "authorization: Basic Y2FybG9zcEB3aW5kc29yc3RvcmUuY29tOjE0MjBjYTQzLTc1YjUtNDI3YS04ZDkwLWY2ZTY0NGE4OTJhMw=="  | jq -r '.' )
    local JOBS=$(echo "$TEST_RUN_RESPONSE" | jq  -c '.jobs')
    local JOBS_LENGTH=$(echo "$JOBS" | jq length)
    echo
    echo Found: $JOBS_LENGTH jobs to be executed
    echo
    
    indx=0;
    success_jobs=0;
    jobs_string=''
    while (( $indx < $JOBS_LENGTH ))
    do
        job=$(echo "$JOBS" | jq -r ".[$indx]")
        JOB_ORDER=$(echo $job | jq -r '.order')
        JOB_STATUS=$(echo $job | jq -r '.status')
        JOB_STARTED=$(echo $job | jq -r '.startTime')
        JOB_ENDED=$(echo $job | jq -r '.stopTime')
        echo Analizing Job id: $JOB_ORDER with status: $JOB_STATUS

        if [[ "$JOB_STATUS" == "$SUCESS_STRING" || "$JOB_STATUS" == "$FAILED_STRING"  ]];
        then
            success_jobs=`expr $success_jobs + 1`
        fi;

        indx=`expr $indx + 1`
        jobs_string="$jobs_string \n JobId: $JOB_ORDER - Status: $JOB_STATUS - started At: $JOB_STARTED  -  ended At: $JOB_ENDED"
    done;

    if [[ $success_jobs == $JOBS_LENGTH ]]; 
    then
        echo
        echo Jobs completed execution "( $success_jobs of $JOBS_LENGTH )"
        echo -e Results: $jobs_string
        exit;
    fi;

    echo Sleeping for $SLEEP_TIME seconds
    sleep $SLEEP_TIME
    get_schedule_exec_details

)


get_schedule_exec_details 