# iDMED Mobile (v1.5.0)
## Installation

Primeiro instale o docker [Docker](https://docs.docker.com/get-started/.).
Localize o arquivo .zip de instalação fornecidos no pacote desta release no [sharedrive]( https://drive.google.com/drive/folders/1moEGeZISjc7xRH80TLxYwWhbtIVD9-Yv) na pasta Code Package
Copia o arquivo 'csaude-idmed-current_Instalation.zip' para o DIRECTORIO idmedSetup e execute os comandos

```sh
$ unzip csaude-idmed_current_Instalation.zip
$ unzip idmed-images.tar.xz
$ docker load -i idmed-images.tar
```

## Update the file .env with the provided information.

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
```
Para uma nova instalação

```sh
$ docker-compose --env-file .env up -d db && docker-compose logs -f
# check whether logs show the message "PostgreSQL init process complete; ready for start up."

$ docker-compose --env-file .env run --rm initscript
# check whether logs show the message "PostgreSQL init process complete; ready for start up."

$ docker-compose --env-file .env run --rm initializationscript
# check whether logs show the message "PostgreSQL init process complete; ready for start up."

$ docker-compose --env-file .env down && docker-compose up -d frontendserver && docker-compose logs -f
# check whether iDMED is up running

$ docker-compose --env-file .env run --rm updatescript

$ docker-compose --env-file .env run --rm initbucardoscript
# check whether bucardo db and schema are created

# # Update the file csaude-idmed-current/app/.env with the provided information.
$ docker-compose --env-file .env up -d bucardo && docker-compose logs -f

$ docker-compose down && docker-compose --env-file .env up -d frontendserver bucardo && docker-compose logs -f
# check whether iDMED is up running
```

Para uma actualização
```sh
# Create backup database
$ docker-compose --env-file .env run --rm initbackupdatabasescript

# Configure the backup database and run the backup
$ docker-compose --env-file .env run --rm backupscript

# Run restorescript
$ docker-compose --env-file .env run --rm restorescript

# Rename the databases
$ docker-compose --env-file .env run --rm renamedatabasescript

# Update the database idmed to version 1.5.0
$ docker-compose down && docker-compose --env-file .env up -d backendserver && docker-compose logs -f
$ docker-compose run --rm updatescript

# As root update file /pgmaster-data/postgresql.conf WITH
# ..
# wal_level = logical
# max_replication_slots = 100
# ..

$ docker-compose --env-file .env run --rm  initlogicalreplicationscript
# check whether a postgres subsription is created

$ docker-compose --env-file .env run --rm initbucardoscript
# check whether bucardo db and schema are created

$ docker-compose down && docker-compose --env-file .env up -d frontendserver bucardo && docker-compose logs -f
# check whether iDMED is up running
```

Go to the Browser your aplication is running at
```sh
http://[localhost/COLOCAR_IP]:5000
```
Select the Health Facility

## License
CSAUDE
