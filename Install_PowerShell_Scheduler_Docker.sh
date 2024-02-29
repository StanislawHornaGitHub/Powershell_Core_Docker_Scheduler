#!/bin/sh

### DESCRIPTION
# This script will build and run Docker container running Task Scheduler.

### OUTPUTS
# Newly created Container ID

### EXIT CODES
# 0 - Success
# 1 - Failed to change directory to Script root dir
# 2 - Failed to build Docker image
# 3 - Failed to stop old Docker container
# 4 - Failed to remove old Docker container
# 5 - Failed to start new Docker container

### CHANGE LOG
# Author:   Stanislaw Horna
# GitHub Repository:  https://github.com/StanislawHornaGitHub/Powershell_Core_Docker_Scheduler
# Created:  21-Jan-2024
# Version:  1.1

# User editable variables
DockerContainerName="TaskScheduler"
DockerImageName="task_scheduler"

# Echo colors definition
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Script input parameters
ScriptInvokation=$0

Main() {
    SetCorrectDirectory
    BuildDockerContainer
    RemoveOldContainer
    RunDockerContainer
    echo "New $DockerContainerName ID: $(docker ps -a -q -f name="$DockerContainerName")"
}

SetCorrectDirectory() {
    ScriptRootDir=$(dirname "$ScriptInvokation")
    cd "$ScriptRootDir" || ExitWithError 1 "Failed to change directory"
}

BuildDockerContainer() {

    # Build Docker image
    docker build -t $DockerImageName . || ExitWithError 2 "Failed to build container image"

    PrintSuccess "Docker image successfully built"
}

RemoveOldContainer() {

    # Get ID of currently running container
    ContainerID=$(docker ps -a -q -f name="$DockerContainerName")

    # Check if container exists
    if [ -n "$ContainerID" ]; then

        # Stop container
        docker stop "$ContainerID" || ExitWithError 3 "Failed to stop old container"

        # Remove container
        docker rm "$ContainerID" || ExitWithError 4 "Failed to remove old container"

        PrintSuccess "Old container successfully removed"
    else
        echo "Container with name $DockerContainerName not found"
    fi
}

RunDockerContainer() {

    # Run Docker container
    ## --restart unless-stopped - restart container if it stops, only if it was not stopped manually
    ## --name - name of container
    ## -d - run container in background
    docker run \
        --restart unless-stopped \
        --name $DockerContainerName \
        -d \
        $DockerImageName || ExitWithError 5 "Failed to start new container"

    PrintSuccess "New container successfully started"
}

PrintError() {
    Message=$1

    # If message is not empty print error message
    if [ -n "$Message" ]; then

        # Print error message with Error word in red
        echo "${RED} Error: ${RESET}$Message"
    fi
}

PrintSuccess() {
    Message=$1

    # If message is not empty print success message
    if [ -n "$Message" ]; then

        # Print success message with Success word in green
        echo "${GREEN} Success: ${RESET}$Message"
    fi
}

ExitWithError(){
    ExitCode=$1
    ErrorMessage=$2

    PrintError "$ErrorMessage"
    exit "$ExitCode"
}

Main
