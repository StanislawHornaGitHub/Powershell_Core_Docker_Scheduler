#!/bin/sh

### DESCRIPTION
# This script will build and run Docker container running PowerShell Scheduler.


### INPUTS
# 1. DEBUG - optional true or false. Default: false

### OUTPUTS
# Newly created Container ID

### EXIT CODES
# 0 - Success
# 1 - Failed to change directory to Script root dir
# 2 - Failed to build Docker image
# 3 - Failed to stop old Docker container
# 4 - Failed to remove old Docker container

### CHANGE LOG
# Author:   Stanislaw Horna
# GitHub Repository:  https://github.com/StanislawHornaGitHub/HornaLAB
# Created:  21-Jan-2024
# Version:  1.0

# User editable variables
DockerContainerName="PowerShellScheduler"
DockerImageName="powershell_scheduler"

# Echo colors definition
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Script input parameters
ScriptInvokation=$0
DEBUG=$1

# Internal variables
CommandResult=""

Main() {
    SetCorrectDirectory
    DisableConsoleOutput
    BuildDockerContainer
    RemoveOldContainer
    RunDockerContainer
    echo "New $DockerContainerName ID: $(docker ps -a -q -f name="$DockerContainerName")"
}

SetCorrectDirectory() {
    ScriptRootDir=$(dirname "$ScriptInvokation")
    cd "$ScriptRootDir" || exit 1
}

BuildDockerContainer() {

    # Build Docker image
    docker build -t $DockerImageName .
    CriticalErrorHandling "Docker Image Build Succeeded" "Docker Image Build Failed" 2
}

RemoveOldContainer() {

    # Get ID of currently running container
    ContainerID=$(docker ps -a -q -f name="$DockerContainerName")

    # Check if container exists
    if [ -n "$ContainerID" ]; then

        # Stop container
        CommandResult=$(docker stop "$ContainerID")
        CriticalErrorHandling "Docker Container Stop Succeeded" "Docker Container Stop Failed" 3

        # Remove container
        CommandResult=$(docker rm "$ContainerID")
        CriticalErrorHandling "Docker Container Removal Succeeded" "Docker Container Removal Failed" 4
    else
        echo "Container with name $DockerContainerName not found"
    fi
}

RunDockerContainer() {

    # Run Docker container
    ## --restart unless-stopped - restart container if it stops, only if it was not stopped manually
    ## --name - name of container
    ## -d - run container in background
    CommandResult=$(docker run \
        --restart unless-stopped \
        --name $DockerContainerName \
        -d \
        $DockerImageName)
    CriticalErrorHandling "Docker Container Run Succeeded" "Docker Container Run Failed" 5

}

CriticalErrorHandling() {
    SuccessMessage=$1
    ErrorMessage=$2
    ExitCode=$3

    # Check if command error output is empty
    if [ $? -eq 0 ]; then

        # Print result of the command if debug is enabled and command output is not empty
        if [ "$DEBUG" = "true" ] && [ -n "$CommandResult" ]; then
            echo "$CommandResult"
        fi
        PrintSuccess "$SuccessMessage"
    else
        PrintError "$ErrorMessage"

        # Print result of the command if is not empty
        if [ -n "$CommandResult" ]; then
            echo "$CommandResult"
        fi
        exit "$ExitCode"
    fi
    CommandResult=""
}

PrintError() {
    Message=$1

    # If message is not empty print error message
    if [ -n "$Message" ]; then

        # Enable Console output temporarily
        EnableConsoleOutput

        # Print error message with Error word in red
        echo "${RED} Error: ${RESET}$Message"

        # Disable Console output
        DisableConsoleOutput
    fi
}

PrintSuccess() {
    Message=$1

    # If message is not empty print success message
    if [ -n "$Message" ]; then

        # Enable Console output temporarily
        EnableConsoleOutput

        # Print success message with Success word in green
        echo "${GREEN} Success: ${RESET}$Message "

        # Disable Console output
        DisableConsoleOutput
    fi
}

DisableConsoleOutput() {

    # Redirect all output to /dev/null if debug is not enabled
    if [ ! "$DEBUG" = "true" ]; then
        exec 3>&2
        exec 2>/dev/null
    fi
}

EnableConsoleOutput() {

    # Restore output to terminal if debug is not enabled
    if [ ! "$DEBUG" = "true" ]; then
        exec 2>&3
    fi
}

Main
