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



#Subscription status
if  egrep -q "ACTIVE" updates.txt
    then
    egrep -q "Standard Subscription" updates.txt && echo -e "\x1B[01;32mStandard Subscription\x1B[0m"
    egrep -q "Priority Subscription" updates.txt && echo -e "\x1B[01;32mPriority Subscription\x1B[0m"
# Checks for an expired subscription
elif egrep -q '"subscription_status":"EXPIRED"' updates.txt
    then
    echo -e "\x1B[01;91mEXPIRED Subscription\x1B[0m"
else
    :
fi

#Uncommon subscriptions status
grep -oP '(?<=identifier).*(?=Subscription)' updates.txt | grep -q "L3" && echo -e "\x1B[01;91mL3 systems are not supported by SUSE Technical Support \x1B[0m"
egrep -q "Evaluation Subscription" updates.txt && echo -e "\x1B[01;91mEvaluation subscriptions are not supported by SUSE Technical Support \x1B[0m"
egrep -q "Long Term Service Pack Support" updates.txt && echo -e "LTSS Subscription"
egrep -q "Inherited Subscription" updates.txt && echo -e "Inherited Subscription, please check the updates.txt for details"


#Checks if it is a SUMA-related system
if [[ -d spacewalk-debug ]] | egrep -q ^release-notes-susemanager rpm.txt | egrep -q ^SUSE-Manager-Server-release rpm.txt
    then
    egrep -o 'SUSE Manager release.*' basic-environment.txt && SUMA=1
elif egrep -q "SUSE-Manager-Retail-Branch-Server-release " rpm.txt
    then
    echo "SUMA Retail Branch" && SUMA=2
elif [[ -f plugin-susemanagerproxy.txt ]]
    then
    echo "SUMA Proxy" && SUMA=3
elif [[ -f plugin-susemanagerclient.txt ]] || egrep -q "^salt-minion" rpm.txt
    then
    echo "SUMA Minion using regular salt service"
elif egrep -q "^venv-salt-minion" rpm.txt
    then
    echo "SUMA Minion using venv-salt minion service"
else
    :
fi



# Cloud packages check
if  egrep -q "cloud-regionsrv-client|regionServiceClientConfigEC2|regionServiceCertsEC2|cloud-regionsrv-client-plugin-gce|regionServiceClientConfigGCE|regionServiceCertsGCE|regionServiceClientConfigAzure|regionServiceCertsAzure" rpm.txt
    then
    echo "Cloud packages installed" && CLOUD=1
else
    echo "Cloud packages not installed"
fi


egrep -q "susecloud" updates.txt && echo "Registered to the cloud:  $(grep -oP "(?<=^url: https://).*(?=.susecloud)" updates.txt)" && CLOUDREG=1


if  egrep -q "susemanager:" updates.txt
    then
    echo -e "System bootstrapped to SUSE Manager" && SUMA_REG=1
elif egrep -q '"subscription_status":"ACTIVE"' updates.txt
    then
    echo -e "\x1B[01;32mSCC Active subscription\x1B[0m"
elif egrep -q "Not Registered" updates.txt
    then
    echo -e "\x1B[01;91mThe system looks like to be not registered to SCC. Please check the updates.txt file \x1B[0m"
else
    :
fi


#  SUMA Cloud client and packages check


if [[ $SUMA_REG -eq 1 ]] && [[ $SUMA -eq 4 ]] && [[ $CLOUDREG -eq 1 ]] && [[ $CLOUD -eq 1 ]]
    then
    echo -e "\x1B[01;93mThe system looks like a properly registered SUMA PAYG client and cloud subscription provider, please verify updates.txt \x1B[0m"
elif [[ $SUMA -eq 4 ]] && [[ $CLOUDREG -eq 1 ]] && [[ $CLOUD -eq 1 ]]
    then
    echo -e "\x1B[01;91mThe system is a PAYG client, registered and contacting only cloud instead of SUMA. \x1B[0m"
elif [[ $SUMA -ge 1 ]] && [[ $CLOUD -eq 1 ]]
    then
    echo -e "\x1B[01;91mSUMA servers or BYOS clients should not have cloud packages installed \x1B[0m"
else
    :
fi



# Quantity of available updates
echo -e "\x1B[01;93m$(egrep ^Found updates.txt | cut -d ":" -f1 | head -1)\x1B[0m"

# Shows if the kernel is tainted
grep -oP '(?<=Status -- ).*(?= )' basic-health-check.txt | egrep -q "Tainted" && TAINTED=1

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
read -p 'Create an errors.txt file with unique ocurrences of errors, fails, warnings, crashes and refusals?  ' ERRORS
    case "$ERRORS" in
    [yY][eE][sS]|[yY])
        egrep -ria -e "error" -e "fail" -e "warning" -e "crash" -e "refused" -e "fatal" -e "unable" | sort -u > errors.txt
        ;;
    esac

# Creates the file power.txt with power-related ocurrences
read -p 'Create a power.txt file with unique ocurrences of shutdown and reboot events?  ' POWER
    case "$POWER" in
    [yY][eE][sS]|[yY])
        egrep -ria -e "shutdown" -e "reboot" | sort -u > power.txt
        ;;
    esac

# Adds ksar path and/or open the ksar app
ksar()
{
    if [[ -e $KSAR_PATH ]]
    then
        source $KSAR_PATH
    else
        read -p 'Input the kSar run.sh path: ' KSAR_RUN
        read -p 'Input YES to create a permanent path saving it to ~/.config ' PERMANENT_PATH
        egrep -q YES <<< $PERMANENT_PATH &&
        echo "KSAR_RUN=${KSAR_RUN}" > $KSAR_PATH
    fi

    /bin/bash $KSAR_RUN
}

read -p 'Input YES to open a sar file:  ' KSAR
echo
egrep -q YES <<< $KSAR &&
ksar
