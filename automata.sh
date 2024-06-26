#!/bin/bash

#WARNING: This is not an official tool, it is only a personal script created to check basic information from the supportconfig extracted files. Furthermore, it can present innacurate retrieved information on some cases. So, you should always double check against the proper supportconfig files. I am not responsible for and assume no liability for any mistakes caused by the use of this script.

echo "To easily use this script, add it to a folder and create an alias on your ~/.bashrc file. Then, execute the alias name within the extracted supportconfig folder".

#System version
echo ""
echo $(egrep '^VERSION=' basic-environment.txt | cut -d "\"" -f2)

#Baseproduct
grep -o "baseproduct.*" updates.txt | head -n1 | cut -d' ' -f3

# System kernel and its year
paste <(egrep '^Linux' basic-environment.txt | cut -d " " -f3)  <(grep -o "UTC.*" basic-environment.txt | cut -d' ' -f2)

#Proxy check
grep "^PROXY_ENABLED" updates.txt

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

#Cloud provider
egrep -q "Microsoft|Amazon|Google" basic-environment.txt && cloudsystem=1
cloudprovider=$(grep -oP "Manufacturer: \K.*" basic-environment.txt)


#Uncommon subscriptions status
grep -oP '(?<=identifier).*(?=Subscription)' updates.txt | grep -q "L3" && echo -e "\x1B[01;91mL3 systems are only supported if the issue is a bug \x1B[0m"
egrep -q "Evaluation Subscription" updates.txt && echo -e "\x1B[01;91mEvaluation subscriptions are not supported by SUSE Technical Support \x1B[0m"
egrep -q "Long Term Service Pack Support" updates.txt && echo -e "LTSS Subscription"
egrep -q "Inherited Subscription" updates.txt && echo -e "Inherited Subscription, please check the updates.txt for details"
egrep -q "Partner" updates.txt && echo -e "Partner subscription"


#Checks if it is a SUMA-related system
if [[ -f plugin-susemanagerclient.txt ]] && egrep -q "susemanager:" updates.txt
    then
        echo -e "The system looks like to be bootstrapped to SUSE Manager" && suma_reg=1
        if
          egrep -q "^salt-minion" rpm.txt
          then
              echo "Classic Salt installed" && suma=4
        elif egrep -q "^venv-salt-minion" rpm.txt
          then
             echo "Salt bundle installed" && suma=4
       else
    :
        fi
else
    :
fi


if [[ -d spacewalk-debug ]] | egrep -q ^release-notes-susemanager rpm.txt | egrep -q ^SUSE-Manager-Server-release rpm.txt
    then
    egrep -o 'SUSE Manager release.*' basic-environment.txt && suma=1
elif egrep -q "SUSE-Manager-Retail-Branch-Server-release" rpm.txt
    then
    echo "SUMA Retail Branch" && suma=2
elif [[ -f plugin-susemanagerproxy.txt ]]
    then
    echo "SUMA Proxy" && suma=3
elif egrep -q "^venv-salt-minion" rpm.txt
    then
    echo "Salt bundle installed" && suma=4
else
    :
fi

#RMT Server check
egrep -q "rmt-server" rpm.txt && echo -e "\x1B[01;32mRMT Server\x1B[0m"


# Cloud packages check
if  egrep -q "cloud-regionsrv-client|regionServiceClientConfigEC2|regionServiceCertsEC2|cloud-regionsrv-client-plugin-gce|regionServiceClientConfigGCE|regionServiceCertsGCE|regionServiceClientConfigAzure|regionServiceCertsAzure|regionServiceClientConfigSAPEC2" rpm.txt
    then
    echo "Cloud packages installed" && cloud=1
else
    echo "Cloud packages not installed"
fi


egrep -q "susecloud" updates.txt && echo "Registered to the cloud:  $(grep -oP "(?<=^url: https://).*(?=.susecloud)" updates.txt)" && CLOUDREG=1


# Cloud instance check
if  [[ $cloudreg -eq 1 ]] && [[ SUMA_REG -ne 1 ]]
    then
    echo -e "\x1B[01;91mThis system looks like a PAYG client, thus, it is only supported by its cloud vendor\x1B[0m" && payg=1
elif
    [[ $cloudsystem -eq 1 ]]
    then
    echo -e "This system looks like a BYOS instance from: $(grep -oP "Manufacturer: \K.*" basic-environment.txt)" && byos=1
else
    :
fi



if egrep -q '"subscription_status":"ACTIVE"' updates.txt
    then
    echo -e "\x1B[01;32mSCC Active subscription\x1B[0m"
elif egrep -q "Not Registered" updates.txt
    then
    echo -e "\x1B[01;91mThe system looks like to be not registered to SCC. Please check the updates.txt file \x1B[0m"
else
    :
fi


#  SUMA Cloud client and packages check
if [[ $suma_reg -eq 1 ]] && [[ $suma -eq 4 ]] && [[ $cloudreg -eq 1 ]] && [[ $cloud -eq 1 ]]
    then
    echo -e "\x1B[01;93mThe system looks like a properly registered SUMA PAYG client and cloud subscription provider, please verify updates.txt \x1B[0m"
elif [[ $suma -eq 4 ]] && [[ $cloudreg -eq 1 ]] && [[ $cloud -eq 1 ]]
    then
    echo -e "\x1B[01;91mThe system is a PAYG instance, registered and contacting only cloud instead of SUMA. \x1B[0m"
else
    :
fi


# SUMA guestregister.service check
guestregister=$(grep /usr/lib/systemd/system/guestregister.service systemd-status.txt | cut -d ";" -f2)

if [[ $suma -eq 4 ]]
    then
        if [[ $payg -eq 1 ]] && [[ $guestregister == " disabled" ]]
            then
                echo "A SUMA PAYG instance should have the guestregister.service enabled"
        elif [[ $byos -eq 1 ]] && [[ $guestregister == " enabled" ]]
            then
                echo "A SUMA BYOS instance should have the guestregister.service disabled"
        else
            :
        fi
else
    :
fi


#Azure regionsrv-enabler-azure.timer check
azuretimer=$(awk '/^regionsrv-enabler-azure.timer/ {print $2}' systemd.txt)

if [[ $suma -eq 4 ]] && [[ $cloudprovider == " Microsoft Corporation" ]]
    then
        if [[ $payg -eq 1 ]] && [[ $azuretimer == "disabled" ]]
            then
                echo "A SUMA PAYG instance should have the regionsrv-enabler-azure.timer enabled"
        elif [[ $byos -eq 1 ]] && [[ $azuretimer == "enabled" ]]
            then
                echo "A SUMA BYOS instance should have the regionsrv-enabler-azure.timer disabled"
        else
            :
        fi
else
    :
fi



# Quantity of available updates
echo -e "\x1B[01;93m$(egrep ^Found updates.txt | cut -d ":" -f1 | head -1)\x1B[0m"
echo

# Checks if any partition of the disk is above 90%
awk '/df -h/,/^$/' basic-health-check.txt | awk '/[9][0-9](\.[0-9]+)?%|100(\.[0]*)?%/' | awk '{printf "\033[31m%-15s %s\033[0m\n", $1, $5}'
echo "=================================================================================================="

# Shows if the kernel is tainted
grep -oP '(?<=Status -- ).*(?= )' basic-health-check.txt | egrep -q "Tainted" && tainted=1

if [[ $suma -eq 1 ]]
    then
    read -p 'Show Salt minions key status? ' SALTKEYS
    case "$saltkeys" in
    [yY][eE][sS]|[yY])
        sed -n '/Accepted/,/^ *$/p' plugin-saltminionskeys.txt
        ;;
    esac
else
    :
fi

if [[ $tainted -eq 1 ]]
    then
    read -p 'Systems with tainted kernel could be non-supported. Show loaded proprietary modules? ' show_tainted
    case "$show_tainted" in
    [yY][eE][sS]|[yY])
        sed -n '/Status/,/^#/p' basic-health-check.txt | cut -d "#" -f3
        ;;
    esac
else
    :
fi

# Creates the file errors.txt with the ocurrences with the most common words that indicate an issue
read -p 'Create an errors.txt file with unique ocurrences of errors, fails, warnings, crashes and refusals?  ' errors
    case "$errors" in
    [yY][eE][sS]|[yY])
        egrep -ria -e "error" -e "fail" -e "warning" -e "crash" -e "refused" -e "fatal" -e "unable" | sort -u > errors.txt
        ;;
    esac
