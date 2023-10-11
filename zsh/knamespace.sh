alias knamespace='f(){

if [ -z "$1" ]
then
      echo "It will show all namespaces";
else
     kubectl config set-context --current --namespace=$1
     echo "You are now in namespace $1"
     return 0
fi


OUTPUT=($(kubectl get namespaces | grep -v NAME |   cut -d " " -f1 ));

INDEX=1
for i in "${(@)OUTPUT}"; do
   echo "$INDEX - $OUTPUT[$INDEX]"
   INDEX=$((INDEX+1))
done
echo "Write namespace’s number you want to change..."
read  ELECCION;

echo "You’ve chosen $ELECCION"

COMANDOFINAL="kubectl config set-context --current --namespace=$OUTPUT[ELECCION] "

echo $COMANDOFINAL;
eval $COMANDOFINAL;
echo "You are now in namespace $OUTPUT[ELECCION]"
unset -f f;};
f'