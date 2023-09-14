![Logo](https://imagizer.imageshack.com/img922/7023/lhgfe7.png)

# Salt Project

The purpose of this project is to simplify actions across the entire Synapse fleet. It enables, using a "master" workstation, the execution of commands, access to files, launching programs, as well as many other actions on all other machines of the company, referred to as "minions."


## Deployment

To use this tool, a specific configuration is required. Install the Master on a Linux PC, which will be responsible for executing all the commands. Then, install the Salt agent on the targets. The minions can be on macOS, Windows, or Linux.

The connection between the master and minions is not automatic. After proper configuration of both, you'll need to accept the request from the minion to the master, directly on the master. Once connected, it's also possible (and necessary for using the scripts) to group the minions into categories such as Windows, Linux, Mac, Mac-M, Mac-Intel.

Once all of this is completed, everything is ready to operate.
## How to use

The primary goal of this project is to launch an executable that gets installed on the minions using this command for example : 

```bash
  ./os/mac/update/change-update-file.sh
```

Here, all Mac machines in the fleet will receive an executable named "update" in their application folder. Those who already had it will simply see the file replaced by the new one. The file in question that is being deployed to the workstations is located at this address :

```bash
  /os/mac/update-file/update-m
  /os/mac/update-file/update-intel
```

There is a file for Mac M-series and another for Mac Intel.
 
Now that the computers are equipped with the file, we can launch the updates using the command :

```bash
  ./os/mac/update/update-all.sh
```

From this point onward, the affected machines (Mac) will launch the file in the background. In this case, the file is responsible for performing updates on applications and installing any missing ones. Of course, the file can be adjusted and modified to carry out the full range of tasks that a shell script can execute.
 
 
There's also another feature that allows you to check the status of the firewall. To do this, simply enter this command :

```bash
  ./os/mac/firewall/firewall-status.sh
```
Of course, it's also possible to activate the firewall across the entire fleet:

```bash
  ./os/mac/firewall/firewall-enable.sh
```
 
 
### Flag and logs

You may have noticed, but no information is provided to you after the execution of the scripts. However, they do indeed exist and are all stored in the logs folder :

```bash
  /os/mac/logs/
```

Everything is sorted and categorized here, named according to the performed task, date, and time.
 
But it's also possible to view these results in the terminal after executing a script by simply adding the "-l" flag, like this for example:

```bash
  ./os/mac/firewall/firewall-status.sh -l
```

## Update :

### Queue

A problem arose for all those who had already done so: tasks performed on locked or simply switched-off machines were not carried out. A simple error message indicated this. To solve this problem, there's now another way to launch tasks.
Using the command
```bash
  ./utils/queue-files/start-queue.sh
```
You are now able to launch a "queue".
First, you'll be asked to choose which task to run. You can make your choice using numbers, such as 1, 2, 3, etc., then enter.
Next, you'll need to select the list, previously edited, in the :
```bash
  /utils/queue-files/list-files
```
This is the list containing the machines on which the tasks will run. You can edit them, for example, one containing all Macs, or one containing all computers in a workgroup.
Next, you'll need to determine the number of tries the program will make before stopping (it will stop before stopping if all commands have succeeded).
And finally, you'll need to choose the number of seconds to wait between each trial.

To view the script's work in real time, open :
```bash
  utils/queue-files/loading.txt
```

The script will check if the workstations are connected, then check if the workstations have already received the command with successful execution, and finally attempt to launch the task on the connected machines, which did not execute the command correctly. Then wait S seconds, and try again, until the maximum number of attempts has been reached, or all tasks have been successfully executed.


## Work In Progress

    - Continue updating the update file.
    - Complete the Windows version.

## Link to an other project

This project is the direct continuation of another: "Deploy". The latter was designed to set up a new machine, or a refurbished old one. It allows you to properly prepare a computer for use, install applications via Homebrew for Mac, and set up security. The Salt Project was also designed to keep PCs up to date. Today, it's important to use both projects, as Salt Project doesn't install Homebrew, for example, so the machine has to be prepared beforehand. Here's a link to the original [Deploy](https://github.com/wwLeji/Deploy-Synapse) project.

## Authors

- [@wwLeji](https://github.com/wwLeji)