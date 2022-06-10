#!/bin/bash
# This script is made to cleanup multiple objects such as service, deploy etc.
# Can be helpful to fix batch of multiple corrupted objects
usage()
{
cat << EOF
usage: bash ./cleanup-k8s.sh -n namespace -o objectname
-n    | --namespace         (Required)            Namespace to resolve ( example: uat1-my-app )
-o    | --objectname        (Required)            Object to resolve ( example: svc, deploy)
-h    | --help                                    Brings up this menu
EOF
}

namespace=
objectname=

while [ "$1" != "" ]; do
    case $1 in
        -n | --namespace )
            shift
            namespace=$1
            ;;
        -o | --objectname )
            shift
            objectname=$1   
            ;;          
        -h | --help )    
        usage
            exit
        ;;
        *)              
        usage
            exit 1
    esac
    shift
done

if [ -z $namespace ]; then
    echo "Namespace is required, provide it with the flag: -n namespace or run -h for help"
    exit
fi

if [ -z $objectname ]; then
    echo "Object name is required, provide it with the flag: -o svc or run -h for help"
    exit
fi

echo $namespace $objectname
failed_objects=`kubectl get $objectname -n $namespace |awk 'NR>1 {print $1}'`

bakfile=$(mktemp /tmp/cleanup-k8s-backup.XXXXXX)
tmpfile=$(mktemp /tmp/cleanup-k8s.XXXXXX)

echo "Creating a backup of failed resource to local file such as $bakfile"
echo "Running the command: kubectl get $objectname -o yaml > $bakfile"
kubectl get $objectname -o yaml -n $namespace > $bakfile

echo "Neating the object....."
echo "Running the command: kubectl get $objectname -o yaml | kubectl neat > $tmpfile"
kubectl get $objectname -o yaml -n $namespace | kubectl neat > $tmpfile


for DELETED in $failed_objects
do 
echo "Deleting the failed object in k8s"
echo "Running the command: kubectl delete $DELETED -n $namespace"
kubectl delete $objectname $DELETED -n $namespace
done

echo "Applying nested object to k8s"
echo "Running the command: kubectl apply -f $tmpfile -n $namespace"
kubectl apply -f $tmpfile -n $namespace
