# Docker Task Scheduler
Docker container to schedule and run configured tasks.
Tool allows to schedule particular script to be executed in specified time intervals.

Supported tasks languages:
- PowerShell Core
- Python
- Bash

# Configuration

> [!IMPORTANT]
> Bash script will NOT install Docker. It will build and run Docker container ONLY

In order to properly set up everything you need to:

1. [Configure `InstanceConfig.json`](/TaskScheduler/)
2. [Configure `JobConfig.json`](/TaskScheduler/)
3. [Save scripts to corresponding tasks in `./Jobs`](/Jobs/)
4. Once previous steps are completed simply run `Install_PowerShell_Scheduler_Docker.sh`

> [!CAUTION]
> Bash script sets container to be re-started in case of any failures.
> Manual stop will prevent staring the container again

# My projects compatible with scheduler
- [GitHub Statistics](https://github.com/StanislawHornaGitHub/GitHub_Statistics)
