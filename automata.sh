#!/bin/bash

#WARNING: This is not an official tool, it is only a personal script created to check basic information from the supportconfig extracted files. Furthermore, it can present innacurate retrieved information on some cases. So, you should always double check against the proper supportconfig files. I am not responsible for and assume no liability for any mistakes caused by the use of this script.

echo "To easily use this script, add it to a folder and create an alias on your ~/.bashrc file. Then, execute the alias name within the extracted supportconfig folder".

# .config file containing KSAR_PATH
KSAR_PATH=~/.config/automata

#System version
echo ""
echo $(egrep '^VERSION=' basic-environment.txt | cut -d "\"" -f2)

# System kernel
echo "Kernel $(egrep '^Linux' basic-environment.txt | cut -d " " -f3)"


# Cloud packages check
if  egrep -q "cloud-regionsrv-client|regionServiceClientConfigEC2|regionServiceCertsEC2|cloud-regionsrv-client-plugin-gce|regionServiceClientConfigGCE|regionServiceCertsGCE|regionServiceClientConfigAzure|regionServiceCertsAzure" rpm.txt
    then
    echo "Cloud packages installed" && CLOUD=1
else
    echo "Cloud packages not installed"
fi


#Subscription status
if grep -q "ACTIVE" updates.txt
    then
    grep -q "Standard Subscription" updates.txt && echo -e "\x1B[01;32mStandard Subscription\x1B[0m"
    grep -q "Priority Subscription" updates.txt && echo -e "\x1B[01;32mPriority Subscription\x1B[0m"
# Checks for an expired subscription
elif grep -q "EXPIRED" updates.txt
    then
    echo -e "\x1B[01;91mEXPIRED\x1B[0m"
else
    :
fi

#L3 Subscription status
grep -oP '(?<=identifier).*(?=Subscription)' updates.txt | grep -q "L3" && L3=1


if [[ -d spacewalk-debug ]] | grep -q ^release-notes-susemanager rpm.txt | grep -q ^SUSE-Manager-Server-release rpm.txt
    then
    grep -o 'SUSE Manager release.*' basic-environment.txt && SUMA=1
# Or checks if it is a SUMA Proxy, Retail Proxy Branch or Minion
elif grep -q "SUSE-Manager-Retail-Branch-Server-release " rpm.txt
    then
    echo "SUMA Retail Branch" && SUMA=2
elif [[ -f plugin-susemanagerproxy.txt ]]
    then
    echo "SUMA Proxy" && SUMA=3
elif [[ -f plugin-susemanagerclient.txt ]] || egrep "^venv-salt-minion" rpm.txt
    then
    echo "SUMA Minion" && SUMA=4
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
    echo "Registered to the cloud:  $(grep -oP "(?<=^url: https://).*(?=.susecloud)" updates.txt)"
elif grep -q "Not Registered" updates.txt
    then
    echo -e "\x1B[01;91mThis system looks like to be not registered to SCC. Please check the updates.txt file \x1B[0m"
elif [[ $L3 -eq 1 ]]
    then
    echo -e "\x1B[01;91mL3 systems are not supported by SUSE Technical Support \x1B[0m"
else
    echo "Please, manually check the updates.txt file"
fi


if [[ $SUMA -gt 1 ]] && [[ $CLOUD -eq 1 ]]
    then
    echo -e "\x1B[01;91mSUMA servers or clients should not have cloud packages installed \x1B[0m"
else
    :
fi


# Quantity of available updates
echo -e "\x1B[01;93m$(grep ^Found updates.txt | cut -d ":" -f1 | head -1)\x1B[0m"

# Shows if the kernel is tainted
grep -oP '(?<=Status -- ).*(?= )' basic-health-check.txt | grep -q "Tainted" && TAINTED=1

if [[ $SUMA -eq 1 ]]
    then
    read -p 'Show Salt minions key status? ' SALTKEYS
    case "$SALTKEYS" in
    [yY][eE][sS]|[yY])
        sed -n '/Denied/,/^ *$/p' plugin-saltminionskeys.txt
        ;;
    esac
else
    :
fi

if [[ $TAINTED -eq 1 ]]
    then
    read -p 'Show loaded proprietary modules? ' SHOW_TAINTED

    case "$SHOW_TAINTED" in
    [yY][eE][sS]|[yY])
        sed -n '/Status/,/^#/p' basic-health-check.txt | cut -d "#" -f3
        ;;
    esac
else
    :
fi

# Creates the file errors.txt with the ocurrences with the most common words that indicate an issue
errors()
{
    egrep -ria -e "error" -e "fail" -e "warning" -e "crash" -e "refused" -e "fatal" | sort -u > errors.txt
}

read -p 'Would you like to create an errors.txt file with unique ocurrences of errors, fails, warnings, crashes and refusals?  ' ERRORS
case "$ERRORS" in
    [yY][eE][sS]|[yY])
        errors
        ;;
esac

# Creates the file power.txt with power-related ocurrences
power()
{
    egrep -ria -e "shutdown" -e "reboot" | sort -u > power.txt
}

read -p 'Would you like to create a power.txt file with unique ocurrences of shutdown and reboot events?  ' POWER
case "$POWER" in
    [yY][eE][sS]|[yY])
        power
        ;;
esac

# Adds ksar path and/or open the ksar app
ksar()
{
    if [[ -e $KSAR_PATH ]]
    then
        source $KSAR_PATH
    else
        read -p 'Please, input the kSar run.sh path: ' KSAR_RUN
        read -p 'Input YES to create a permanent path saving it to ~/.config ' PERMANENT_PATH
        grep -q YES <<< $PERMANENT_PATH &&
        echo "KSAR_RUN=${KSAR_RUN}" > $KSAR_PATH
    fi

    /bin/bash $KSAR_RUN
}

read -p 'Input YES to open a sar file:  ' KSAR
echo
grep -q YES <<< $KSAR &&
ksar
