###########################################
########## INCLUDE CONFIGS FILES  #########
###########################################

# WHICH SYS/OS ARE WE ON ??

if [[ $(sw_vers -productName 2> /dev/null) ]]; then
    # if [ $(sw_vers -productName) == "Mac OS X" ]; then export OS_NAME="MacOS";
    # else export $(sw_vers -productName); fi;
    [[ $(sw_vers -productName) = "Mac OS X" ]] && export OS_NAME="MacOS" || export OS_NAME=$(sw_vers -productName);
    export OS_VERSION=$(sw_vers -productVersion);
    export OS_KERNEL=$(sw_vers -buildVersion); # NOT ACTUALLY "KERNEL" ON MacOS HERE
else 
    [[ $(uname -o) = "GNU/Linux" ]] && export OS_NAME="Linux" || export OS_NAME=$(uname -o);
    export OS_VERSION=$(uname -s);
    export OS_KERNEL=$(uname -r);
fi;

OS_NAME_LOWER=$(echo $OS_NAME | awk '{print tolower($0)}');

