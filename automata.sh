#!/bin/bash

#WARNING: This is not an official tool, it is only a personal script created to check basic information from the supportconfig extracted files. Furthermore, it can present innacurate retrieved information on some cases. So, you should always double check against the proper supportconfig files. I am not responsible for and assume no liability for any mistakes caused by the use of this script.

echo "To easily use this script, add it to a folder and create an alias on your ~/.bashrc file. Then, execute the alias name within the extracted supportconfig folder".

# .config file containing KSAR_PATH
KSAR_PATH=~/.config/automata

# System kernel
echo Kernel $(grep -oP '(?<=Linux ).*(?=-default)' basic-environment.txt | cut -d " " -f2)
# Shows if the kernel is tainted
grep -oP '(?<=Status -- ).*(?= )' basic-health-check.txt | grep -q "Tainted" && sed -n '/Status/,/^#/p' basic-health-check.txt | cut -d "#" -f3

#Subscription status
status_check()
{
if grep -q "ACTIVE" updates.txt
    then
    grep -q "Standard Subscription" updates.txt && echo "Standard Subscription"
    grep -q "Priority Subscription" updates.txt && echo "Priority Subscription"
# Checks for an expired subscription
elif grep -q "EXPIRED" updates.txt
    then
     echo -e "EXPIRED"
fi
}

# Cloud packages check
if  egrep -q "cloud-regionsrv-client|regionServiceClientConfigEC2|regionServiceCertsEC2|cloud-regionsrv-client-plugin-gce|regionServiceClientConfigGCE|regionServiceCertsGCE|regionServiceClientConfigAzure|regionServiceCertsAzure" rpm.txt
    then
    echo "Cloud packages installed" && CLOUD=1
else
    echo "Cloud packages not installed"
fi

# Checks if it is a SUMA Master and its version
if [[ -d spacewalk-debug ]] || grep -q "^susemanager" rpm.txt || grep -q "^SUSE-Manager-Server-release" rpm.txt
    then
    status_check
    grep -o 'SUSE Manager release.*' basic-environment.txt
# Salt minions keys status
    sed -n '/Denied/,/^ *$/p' plugin-saltminionskeys.txt && SUMA=1
# Or checks if it is a SUMA Proxy or Minion
elif [[ -f plugin-susemanagerproxy.txt ]]
    then
    echo "SUMA Proxy" && SUMA=1
elif [[ -f plugin-susemanagerclient.txt ]] || grep -q "venv-salt-minion" rpm.txt
    then
    echo "SUMA Minion" && SUMA=1
# Checks if it is a SMT Server or Client
elif grep -q "enabled" smt.txt
    then
    echo "SMT Server"
elif grep -q "smt-client" rpm.txt
    then
    echo "SMT Client"
# Checks if it is a RMT Server
elif [[ -f plugin-rmt.txt ]]
    then
    echo "RMT Server"
elif grep -q "susecloud" updates.txt
    then
    echo "Registered to a cloud SMT"
else
    echo "Please, manually check the updates.txt file"
fi

if [[ $SUMA -eq $CLOUD ]]
    then
    echo "SUMA servers or clints should not have cloud packages installed"
else
    :
fi


# Quantity of available updates
echo $(grep ^Found updates.txt | cut -d ":" -f1 | head -1)


# Creates the file errors.txt with the ocurrences with the most common words that indicate an issue
errors()
{
    egrep -ri -e "error" -e "fail" -e "warning" -e "crash" -e "refused" -e "fatal" | sort -u > errors.txt
}

read -p 'Input YES to create an errors.txt file with unique ocurrences of errors, fails, warnings, crashes and refusals?  ' ERRORS
grep -q YES <<< $ERRORS && errors

# Creates the file power.txt with power-related ocurrences
power()
{
    egrep -ri -e "shutdown" -e "reboot" | sort -u > power.txt
}

read -p 'Input YES to create a power.txt file with unique ocurrences of shutdown and reboot events?  ' POWER
grep -q YES <<< $POWER && power

# Adds ksar path and/or open the ksar app
ksar()
{
if [[ -e $KSAR_PATH ]]
    then
        source $KSAR_PATH
    else
        read -p 'Please, input the kSar run.sh path: ' KSAR_RUN
    read -p 'Make it a permanent path saving it to ~/.config ? ' PERMANENT_PATH
        grep -q YES <<< $PERMANENT_PATH &&
        echo "KSAR_RUN=${KSAR_RUN}" > $KSAR_PATH
fi
    /bin/bash $KSAR_RUN
}

read -p 'Input YES to open a sar file:  ' KSAR
echo
grep -q YES <<< $KSAR &&
ksar
