# iDMED (v1.5.0 SNAPSHOT)

## Relatórios

### Relatórios do serviço de Saúde TARV

#### Relatórios de Gestão de Farmácia
- Faltosos ao levantamento de ARVs para APSS - **Ticket #3655**

#### Relatórios de Monitoria e Avaliação
- Dispensas Não Sincronizadas para o OpenMRS - **Ticket #3713**


## Funcionalidades e Formulários

####  Módulo de Gestão de Utentes
- Alerta ao criar prescrição para pacientes - **Ticket #3656 (Novo)**
- Dispensa de Medicamentos a pacientes inativos - **Ticket #3437 (Novo)**
- Atribuição automática de Location UUID - **Ticket #3677 (Novo)**
- Sincronização de Dados de Utentes do OpenMRS para iDMED (Novo)

#### Módulo de Gestão de Stock
- Distribuição de Stock (Novo)

#### Módulo de Administração Geral:
- Constrangimento no acesso aos sectores clínicos - **Ticket #3777**
- Configuração de Sector Clínico - **Ticket #3774**
- Update do parent_clinic_id - **Ticket #3804**


## Documentos

#### Notas da Release:
- iDMED - 1.5.0 Release Notes_Dec_2024

#### Documentos de Requisitos iDMED_Web:
- iDMED_STK_005_Distribuição
- iDMED_PAT_004_Registo_Manutenção_Prescrições
- iDMED_REL_035_Dispensas_Não_Sincronizadas
- iDMED_REL_015_Faltosos_Levantamento_ARVs_APSS
- iDMED_Mobile_STK_FUNC_002_Distribuição_Stock


## Installation

Primeiro instale o docker [Docker](https://docs.docker.com/get-started/.).
Localize o arquivo .zip de instalação fornecidos no pacote desta release no [gitHub]() na pasta Code Package
Copia o arquivo 'csaude-idmed-current_Instalation.zip' para o DIRECTORIO idmedSetup e execute os comandos

### Offline
```sh
$ unzip csaude-idmed_current_Instalation.zip
$ unzip idmed-images.tar.xz
$ docker load -i idmed-images.tar
```

ou

### Online
```sh
$ unzip csaude-idmed_current_Instalation.zip
```

## Actualize o ficheiro .env com a informação de aceeso partilhada. Caso nao teha recebido, por favor solicite a equipa da CSAUDE.

```sh
### DB AND BACKUP SERVICE
POSTGRES_HOST=[dbHost]
POSTGRES_DB=[idmedDB]
POSTGRES_USER=[idmedUserDB]
POSTGRES_PASSWORD=[idmedPASSDB]
POSTGRES_EXTRA_OPTS="-Z6 --schema=public --blobs"
SCHEDULE=@weekly
BACKUP_KEEP_DAYS=3
BACKUP_KEEP_WEEKS=2
BACKUP_KEEP_MONTHS=1
HEALTHCHECK_PORT=8989

### BUCARDO TARGET CONF
TARGET_DB_NAME=[ProvincialDBName]
TARGET_DB_USER=[ProvincialDBUser]
TARGET_DB_PASS=[ProvincialDBPASS]
TARGET_DB_PORT=[ProvincialDBPORT]
TARGET_DB_HOST=[ProvincialDBHOST]

### BUCARDO SOURCE CONF
SOURCE_DB_NAME=[idmedDB]
SOURCE_DB_USER=[idmedUserDB]
SOURCE_DB_PASS=[idmedPASSDB]

# BACKEND
DB_USER=[idmedUserDB]
DB_PASS=[idmedPASSDB]
DB_URL=jdbc:postgresql://db:5432/idmed
```

# Para uma nova instalação

```sh
$ docker-compose --env-file .env up -d db && docker-compose logs -f
# Verifique se a mensagem a seguir é ilustrada "PostgreSQL init process complete; ready for start up."

$ docker-compose--env-file .env run --rm initscript
# Verifique se a mensagem a seguir é ilustrada "DATABASE CREATED." ou "DATABASES ALREADY EXISTS "

$ docker-compose --env-file .env run --rm initializationscript
$ docker-compose --env-file .env down && docker-compose up -d frontendserver && docker-compose logs -f
# Verifique se o iDMED esta em execução

$ docker-compose --env-file .env run --rm updatescript
$ docker-compose --env-file .env run --rm initbucardoscript
# Verifique se a base de dados e schema "bucardo" foram criados

$ docker-compose --env-file .env up -d bucardo && docker-compose logs -f
# Verifique se a sincronizacao com "bucardo" esta em execução

$ docker-compose down && docker-compose --env-file .env up -d frontendserver bucardo && docker-compose logs -f
# Verifique se o iDMED esta em execução
```
Abra o seu navegador, e a aplicação estará em execução em:
```sh
http://[localhost/COLOCAR_IP]:5000
```
Select the Health Facility

# Para uma actualização

## Preparação e Execução da actualização
Primeiro, precisamos garantir que o serviço de base de dados seja o unico em execução.

Usando a linha de comando, execute o comando abaixo:

```sh
$ docker-compose down && docker-compose --env-file .env up -d db && docker-compose logs -f
# Verifique se a mensagem a seguir é ilustrada "PostgreSQL init process complete; ready for start up."
```

### 1. Efectue o backup da base de dados do iDMED
```sh

$ docker-compose --env-file .env run --rm initbackupdatabasescript
# Cria uma base de dados "idmedbackup" para o backup da versao 1.4.0

$ docker-compose --env-file .env run --rm backupscript
# Verifique se o backup esta em execução
```

### 2. Efectue o restore a nova base de dados
```sh
$ docker-compose --env-file .env run --rm restorescript
# Verifique se o Restore esta em execução para a base de dados idmedbackup

$ docker-compose --env-file .env run --rm renamedatabasescript
# Verifique a existencia das bases de dados "idmed_backup_1_4_0" e "idmed"
```

### 3. Execução do Serviço iDMED
```sh
$ docker-compose down && docker-compose --env-file .env up -d backendserver && docker-compose logs -f
# Verifique se os containers estão em execução
# Verifique se a mensagem a seguir é ilustrada  "Grails application running at http://localhost:8884 in environment: production"

$ docker-compose run --rm updatescript
# Actualização da database idmed to para a versão 1.5.0
```

### 4. Inicialização do Serviço bucardo
```sh
$ docker-compose --env-file .env run --rm initbucardoscript
# Verifique se a base de dados com "bucardo" esta em execução

$ docker-compose down && docker-compose --env-file .env up -d frontendserver bucardo && docker-compose logs -f
# Verifique se a sincronizacao com "bucardo" esta em execução
```

### 5. Verificação do estado do serviço bucardo
Usando a linha de comando, execute o comando abaixo para acessar o serviço de banco de dados dentro do contêiner Docker:

```sh
docker exec -it idmed-bucardo-1 /bin/bash
```
Dentro do contêiner, execute o seguinte comando:
```sh
root@:/# bucardo -h db -U bucardo status
```
Após a execução do comando, deverá obter o seguinte resultado:
| Name | README | README | README | README | README | README |
| ---- | ------ | ------ | ------ | ------ | ------ | ------ |
| idmed_sync | Good | 16:14:50 | 46m 53s | 9/9  | none |  |

ou

| Name | README | README | README | README | README | README |
| ---- | ------ | ------ | ------ | ------ | ------ | ------ |
| idmed_sync | Bad | 16:14:50 | 46m 53s | 9/9  | none |  |

Se o resultado obtido for ***Bad***, execute o comando a seguir para identificar o erro e contacte o helpdesk para suporte:
```sh
root@:/# tail -f /var/log/bucardo/log.bucardo
```

### 6. Inicialização do Serviço de Replica Lógica
Usando a linha de comando, execute o comando abaixo para a criação de uma subscricão para a base de dados:
```sh
$ docker-compose --env-file .env run --rm  initlogicalreplicationscript
# Verifique se a informação de subscricao foi criado
```

```sh
$ docker-compose logs -f
# Verifique se a informação de inicio de criação de WAL foi iniciada com sucesso.
```

Go to the Browser your application is running at
```sh
http://[localhost/COLOCAR_IP]:5000
```
## License
CSAUDE
