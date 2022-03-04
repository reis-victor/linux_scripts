#!/bin/bash

echo "WARNING: This is not an official tool, it is only a personal script created by me and only intended to be used for checking basic information from the supportconfig extracted files. Furthermore, it can present innacurate retrieved information on some cases.So, you should always double check against the proper supportconfig files. I am not responsible for and assume no liability for any mistakes caused by the use of this script."

echo "Do you wish to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo "To easily use this script, add it to a folder and create an alias on your ~/.bashrc file. Then, execute the alias name within the extracted supportconfig folder".

# .config file containing KSAR_PATH
KSAR_PATH=~/.config/automata

# System kernel
echo Kernel $(grep -oP '(?<=Linux ).*(?=-default)' basic-environment.txt | cut -d " " -f2)
# Shows if the kernel is tainted
grep -oP '(?<=Status -- ).*(?= )' basic-health-check.txt | grep -q "Tainted" && sed -n '/Status/,/^#/p' basic-health-check.txt | cut -d "#" -f3

# Subscription Status
grep -q "ACTIVE" updates.txt && grep -q "Standard Subscription" updates.txt && echo "Active Standard Subscription" || echo "Active Priority Subscription"
grep -q "EXPIRED" updates.txt && echo -e "\033[31mEXPIRED SUBSCRIPTION\033[0m"

# Quantity of available updates
echo $(grep ^Found updates.txt | cut -d ":" -f1 | head -1)

# If it is a Suse Manager
# Checks if it is a SUMA Master and its version
if [[ -e spacewalk-debug ]]
   then	
	   echo "SUMA Master" $(grep '^susemanager' rpm.txt | awk '{print $6}' | head -n1)
	 
# Salt minions keys status
           sed -n '/Denied/,/^ *$/p' plugin-saltminionskeys.txt

# Or checks if it is a SUMA Proxy or Minion
elif [[ -e plugin-susemanagerproxy.txt ]]
    then	
	   echo "SUMA Proxy"
	   
elif [[ -e plugin-susemanagerclient.txt ]]
    then	
	   echo "SUMA Minion"

else	   
# Else, checks if it is a CEPH admin
      [[ -e ceph ]] && echo "CEPH admin"
fi

# Shows the most common words ocurrences related to system issues
errors()
{
    egrep -ri -e "error" -e "fail" -e "warning" -e "crash" -e "refused" -e "fatal" | sort -u > errors.txt
}

read -p 'Input YES to create an errors.txt file with unique ocurrences of errors, fails, warnings, crashes and refusals?  ' ERRORS
grep -q YES <<< $ERRORS && errors

# Shows power ocurrences
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
