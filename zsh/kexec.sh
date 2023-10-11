alias kexec='f(){

PATTERN="";

if [ $# -eq 0 ]; then
	PATTERN=".*";
else
        PATTERN="$1";
        echo "It will show pods with selector $1 and namespace $2";
fi

ESPACIO_NOMBRE_VAR="";
if [ -z "$2" ]
then
      ESPACIO_NOMBRE_VAR="";
else
      ESPACIO_NOMBRE_VAR=" --namespace $2 ";
fi

OUTPUT=($(kubectl get pods $ESPACIO_NOMBRE_VAR | grep -v NAME | grep -v Evicted|  cut -d " " -f1 | grep -e $PATTERN));

echo Showing pods...

INDEX=1
for i in "${(@)OUTPUT}"; do
   echo "$INDEX - $OUTPUT[$INDEX]"
   INDEX=$((INDEX+1))
done
echo "Write pod’s number you want to exec..."
read  ELECCION;


INITCONTAINERS=($(kubectl get pods $OUTPUT[ELECCION] $ESPACIO_NOMBRE_VAR -o custom-columns="INITCONTAINER:.spec.initContainers[*].name" --no-headers=true))

INITCONTAINERS=("${(s:,:)INITCONTAINERS}")

CONTAINERS=($(kubectl get pods $OUTPUT[ELECCION] $ESPACIO_NOMBRE_VAR -o custom-columns="CONTAINER:.spec.containers[*].name" --no-headers=true))

CONTAINERS=("${(s:,:)CONTAINERS}")

TOTALCONTAINERS=()
TOTALCONTAINERS+=("${INITCONTAINERS[@]}")

TOTALCONTAINERS+=("${CONTAINERS[@]}")

echo Showing containers...

INDEXCONTAINER=1
for i in "${(@)INITCONTAINERS}"; do
   echo "$INDEXCONTAINER - $i (Init Container)"
   INDEXCONTAINER=$((INDEXCONTAINER+1))
done
for i in "${(@)CONTAINERS}"; do
   echo "$INDEXCONTAINER - $i"
   INDEXCONTAINER=$((INDEXCONTAINER+1))
done

echo "Write container’s number you want to exec..."
read  ELECCIONCONTAINER;



echo "You’ve chosen  pod $ELECCION: $OUTPUT[ELECCION] $ESPACIO_NOMBRE_VAR container $ELECCIONCONTAINER: $INITCONTAINERS[ELECCIONCONTAINER]"


echo "Press enter to execute default value (bash || sh) or write your own command and then press enter:"
read COMMANDINPUT

COMMANDTOEXECUTE=""

if [ -z "$COMMANDINPUT" ]; then
    COMMANDTOEXECUTE="bash || sh"
else
    COMMANDTOEXECUTE=$COMMANDINPUT
fi


COMANDOFINAL="kubectl exec -it $OUTPUT[ELECCION] $INITCONTAINERS[ELECCIONCONTAINER] -- $COMMANDTOEXECUTE"

echo $COMANDOFINAL $ESPACIO_NOMBRE_VAR;
sleep 1
eval $COMANDOFINAL $ESPACIO_NOMBRE_VAR;
unset -f f;};
f'