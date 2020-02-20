#!/bin/bash
## Loop que coleta cada nome e seta uma variavel

#echo 'Digite o nome do grupo'
#read GRUPO

#echo 'Digite o nome do usuario'
#read USER


#echo 'digite numero do chamado'

#read CHAMADO

# Declarar variaveis
#Local onde serao armazenados os arquivos gerados
DIR1=/var/jenkins_home/scripts_dir/grupos-jenkins
L_USER=$DIR1/users.txt
L_GRUPO=$DIR1/grupo.txt
L_JOBS=$DIR1/jobs.txt
# Coleta os jobs de um Grupo e envia para o arquivo definido na variavel GRUPO. Utiliza o grep para coletar apenas os nomes 
echo > $L_JOBS

for GRUPO in $(cat $L_GRUPO); do
echo " $GRUPO"

java -jar ../jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin get-view $GRUPO |grep string  |cut -d '>' -f 2 |cut  -d '<' -f 1 >> $L_JOBS

done


ARQ1=$L_JOBS
ARQ2=$DIR1/lista-projetos
#grep prd  $ARQ1  > $DIR1/prod.txt
#PROD=$DIR1/prod.txt

#Acessa o arquivo gerado acima, e baixa o job correspondente jogando os dados para um xml correspondente ao nome
for ARQUIVO in `cat $ARQ1`
do
    echo ${ARQUIVO}  
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin get-job ${ARQUIVO} > $DIR1/${ARQUIVO}.xml
 #   sleep 2
done

cp $ARQ1 $ARQ2


#Verificar se o usuario existe, se não ele adiciona no arquivo .xml e em seguida o upload do arquivo 

for ARQUIVO  in `cat $ARQ1` 
do for USER in $(cat $L_USER); do
        if      cat $DIR1/${ARQUIVO}.xml |grep $USER > /dev/null
        then
               echo "$DIR1/${ARQUIVO}.xml -> EXISTE"

######Verifica se o  projeto é prod pelo nome, se sim, insere as permissões e em seguida deleta da lista o nome desse projeto. 
 elif  echo $ARQUIVO |egrep -q 'prd' ; then

	echo "$ARQUIVO -> PROD"
	sleep 2


#then.
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>com.cloudbees.plugins.credentials.CredentialsProvider.View:$USER</permission>'" $DIR1/${ARQUIVO}.xml
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>hudson.model.Item.Read:$USER</permission>'" $DIR1/${ARQUIVO}.xml
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>hudson.model.Item.Workspace:$USER</permission>'" $DIR1/${ARQUIVO}.xml
#		java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin update-job  ${ARQUIVO}  < $DIR1/${ARQUIVO}.xml

		sleep 2
	
		sed -i "/${ARQUIVO}/d" $ARQ1
#######################################################
### Insere nos demais projetos " HML - ACEITE - DEV) as permissões abaixo


        else
              echo "$DIR1/${ARQUIVO}.xml -> NAO"
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>com.cloudbees.plugins.credentials.CredentialsProvider.View:$USER</permission>'" $DIR1/${ARQUIVO}.xml
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>hudson.model.Item.Read:$USER</permission>'" $DIR1/${ARQUIVO}.xml
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>hudson.model.Item.Workspace:$USER</permission>'" $DIR1/${ARQUIVO}.xml
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>hudson.model.Item.Build:$USER</permission>'" $DIR1/${ARQUIVO}.xml
		sed -i "/\/hudson.security.AuthorizationMatrixProperty/i <permission>hudson.model.Item.Cancel:$USER</permission>'" $DIR1/${ARQUIVO}.xml
#		java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin update-job  ${ARQUIVO}  < $DIR1/${ARQUIVO}.xml

       fi
done
done
#java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin update-job  ${ARQUIVO}  < $DIR1/${ARQUIVO}.xml




for  VAR1 in $(cat $ARQ2 ); do
#if echo $VAR1 |egrep -q "$GRUPO"; then
#		echo " $VAR1"
echo "realizando o uplodad de  $VAR1 para o Jenkins"
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:admin update-job  ${VAR1}  < $DIR1/${VAR1}.xml
#	sleep 2	
#	else
#		echo " ----- OK ---- "
#	fi
done
		

# BKP do diretorio gerado
#tar cf /tmp/$CHAMADO.tar.gz $DIR1

#Remover arquivos gerados.

