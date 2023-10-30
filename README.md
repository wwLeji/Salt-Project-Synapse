![Logo](https://imagizer.imageshack.com/img922/7023/lhgfe7.png)

# Salt Project

The purpose of this project is to simplify actions across the entire Synapse fleet. It enables, using a "master" workstation, the execution of commands, access to files, launching programs, as well as many other actions on all other machines of the company, referred to as "minions."


## Deployment

To use this tool, a specific configuration is required. Install the Master on a Linux PC, which will be responsible for executing all the commands. Then, install the Salt agent on the targets. The minions can be on macOS, Windows, or Linux.

The connection between the master and minions is not automatic. After proper configuration of both, you'll need to accept the request from the minion to the master, directly on the master. Once connected, it's also possible (and necessary for using the scripts) to group the minions into categories such as Windows, Linux, Mac, Mac-M, Mac-Intel.

Once all of this is completed, everything is ready to operate.


## How to use

The main aim of this project is to launch orders for minions. To achieve this, the evolution of the project has led us to the principle of queuing.
Since this change, the main file is the start-queue file, which can be executed as follows:
```bash
    ./utils/queue-files/start-queue
```
This will launch the main program, giving us a choice of many things.
To begin with, we'll need to choose which command to run on the minions, and we have a choice of 7.

```bash
    Choose the task you want to execute :
    1. Get firewall status
    2. Enable firewall
    3. Disable firewall
    4. Launch update
    5. Change update file
    6. Manual command
    7. First check connection
    Enter your choice : 
```

The first 3 are self-explanatory, so I don't need to explain them. Next comes the "Launch update" choice, which allows you to launch a small program called "update", located directly on the target machines. Choice 5 lets us modify this update file, adding tasks, applications to be updated or installed. Choice 6 is equally straightforward, allowing you to execute custom commands. And the last one gives us an overview of the number of machines available and connected, and therefore able to receive a task.


The second choice (if you didn't take 7) looks like this:
```bash
    Choose all tags needed or one tag needed :
    1. All tags needed
    2. One tag needed
    3. One PC only choosed by name
    Enter your choice : 
```

This will determine how the minion selection works. Here, we're using tags to choose, and we'll decide whether to select only those machines that contain all the tags we've given, or only those machines that contain at least one of the given tags.
The third option allows us not to use tags, but to select a machine directly by name.

Next comes the choice of tags, where you have to enter the desired tags by hand.

```bash
    Choose tags to search for :
    Enter your choice : 
```

Here the answer might look something like this

```bash
    Enter your choice : #mac-m #dev
```
The number of tags chosen is unlimited

Once the tags have been entered, the program informs us of the number of minions selected thanks to the tags.

```bash
    5 PC found
    Check #list.txt for more details
```

You'll then need to set the number of repetitions you want, or the commands will attempt to run. 
```bash
    Choose the maximum number of retries :
    Enter your choice : 
```

The program will stop if all commands have been executed successfully, but in the meantime, the launch loop will run X times.

Then comes the last option to be entered, which is the waiting time between each attempt. 
```bash
    Choose the waiting time between each retry :
    Enter your choice : 
```
It's a value in seconds, so you don't have to keep launching ping tests.


Then the program begins its work, which can be seen in a window that opens automatically.

This window is updated as the program runs, showing us the progress of tasks, and looks like this

```bash
    Firewall status :

    mac-bobi: not connected
    mac-julien-m : not connected
    mac-intel-test : not connected
    mac-m1-test : not connected
    mac-intel-paris : not connected

    Loading...
    try 1/10
    Estimated time : 250 seconds
```

At the top is the name of the current Task, followed by the names of the minions involved, with a status for each of them. At first, they're not connected, then the first loop advances, and if possible, unlocked machines on the network become connected:

```bash
    Firewall status :

    mac-bobi: not connected
    mac-julien-m: connected
    mac-intel-test : connected
    mac-m1-test : not connected
    mac-intel-paris : connected

    Loading...
    try 1/10
    Estimated time : 250 seconds
```

Then, the executions are launched on the available, connected machines. And if everything's working, the status changes to "done".


```bash
    Firewall status :

    mac-bobi: not connected
    mac-julien-m: done
    mac-intel-test : done
    mac-m1-test : not connected
    mac-intel-paris : done

    Loading...
    try 1/10
    Estimated time : 250 seconds
```

With this window, you can also interact with the program in progress, such as quitting the process entirely, or pausing it before starting the next loop. You can also display logs in this window, to see the output of machines that have already received the command. Finally, you can toggle full screen on and off, and zoom in and out.

So, for each loop, the program tries to see which machines are connected, then tries to run the commands on those that are connected, and which have not yet succeeded in executing the commands. This system avoids spamming machines that have already received their commands.


### Logs

You may have noticed during program use that the information following execution is not transcribed to the classic output. All necessary information is stored in an orderly fashion in the logs folder:
```bash
    /utils/queue-files/logs
```

### Args

The program can also be launched with arguments, which will allow you to launch it directly with the desired options. The arguments are as follows:

```bash
    -h                      Show help message

    -cmd                    Set the command to execute

        =gf                 Get firewall status
        =ef                 Enable firewall
        =df                 Disable firewall
        =lu                 Launch update
        =cu                 Change update file
        =mc                 Manual command
        =cc                 First check connection
    
    -tagoption              Set the tag option

        =at                 All tags needed
        =ot                 One tag needed
        =n                  On PC only choosed by name

    -tags                   Set the tags if needed (if tagoption=at or ot)

        ="#tag1,#tag2..."   Tags separated by commas
    
    -pc                     Set the PC name if needed (if tagoption=n)

        ="name"             Name of the PC

    -retries                Set the number of retries

        ="number"           Numeber of retries

    -wait                   Set the waiting time between each retry

        ="number"           Time between each retries in seconds
```

An example of this command can be :

```bash
    ./utils/queue-files/start-queue -cmd=ef -tagoption=ot -tags=#mac-m,#dev -retries=50 -wait=120
```

## Work In Progress

    - Setup on Server

## Authors

- [@wwLeji](https://github.com/wwLeji)