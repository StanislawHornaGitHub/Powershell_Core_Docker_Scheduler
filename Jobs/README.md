# Jobs
Each configured job to be executed should be located in dedicated directory, 
which is also an execution location for task sub-process.
This allows to build tasks using relative paths for importing custom modules, working with files, etc.
Task directories are not cleared, so remaining files can be used as a temp ones,
to store important information between subsequent task runs.
Tasks can create separate threads and processes which are not taken under consideration for TasksRunningSimultaneouslyLimit parameter in InstanceConfig.json

Executables to run which are pointed out in JobConfig.json must be located
directly in directory dedicated for particular task, as presented below:

    Jobs
      ├───<Directory_for_task_1>
      │   └── <task_1_file_to_run>
      │
      ├───<Directory_for_task_2>
      │   └──<task_2_file_to_run>
      │
      └───<Directory_for_task_3>
          └──<task_3_file_to_run>

