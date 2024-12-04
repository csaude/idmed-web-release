#/bin/bash

# Entrypoint Script
# Author: colaco.nhongo@csaude.org.mz
# Version: 1.5.0
# October 21th, 2022
# Update Dec 2nd, 2024

#!/bin/bash

# Source the environment variables
set -o allexport
source .env
set +o allexport

echo "P"| bucardo -h db install
bucardo -h db -U bucardo add db main db=$SOURCE_DB_NAME user=$SOURCE_DB_USER pass=$SOURCE_DB_PASS host=db
bucardo -h db -U bucardo add db idmedCentral db=$TARGET_DB_NAME user=$TARGET_DB_USER pass=$TARGET_DB_PASS port=$TARGET_DB_PORT host=$TARGET_DB_HOST

# bucardo -h db -U bucardo add db idmedCentral db=idmed_maputo0 user=postgres pass=1csaude2 port=5432 host=idmed.csaude.org.mz

# Executa o sub_entrypoint
sh ./sub_entrypoint.#!/bin/sh

# Configuracao para inicio da replica
bucardo -h db -U bucardo add dbgroup idmed_dbgroup main:source idmedCentral:target
bucardo -h db -U bucardo add sync idmed_sync dbgroup=idmed_dbgroup relgroup=idmed_relgroup conflict_strategy=bucardo_latest_all_tables autokick=1

bucardo -h db -U bucardo validade idmed_relgroup

bucardo -h db -U bucardo -P bucardo start
#bucardo -h db -U bucardo update sync idmed_sync onetimecopy=2 autokick=1
#bucardo -h db -U bucardo reload config
#bucardo -h db -U bucardo update sync idmed_sync autokick=1

#Visualizacao de Logs
tail -f /var/log/bucardo/log.bucardo
