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

# Update the file .env with the provided information.

# BUCARDO TARGET CONF
```sh
TARGET_DB_NAME=[provincial_idmed_db]
TARGET_DB_USER=[provincial_idmed_db_user]
TARGET_DB_PASS=[provincial_idmed_db_pass]
TARGET_DB_PORT=[provincial_idmed_db_port]
TARGET_DB_HOST=[provincial_idmed_db_host]
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
