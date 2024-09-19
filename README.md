CURRENT VERSION: iDMED V1.2.0
=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>>=>=>>=>=>>=>=>>=>=>

configure docker compose to create new log file daily docker

=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>INSTALATION=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>

Copia o arquivo 'csaude-idmed-SNAPSHOT_current_Instalation.zip' para o DIRECTORIO idmedSetup e execute o comando
 
## try
 
### terminal A:                                                        

```bash
$ unzip csaude-idmed-SNAPSHOT_current_Instalation.zip
$ docker load -i idmed-images.tar
 
```
=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>NEW INSTALATION ONLY=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
### terminal A:                                                        

```bash

$ docker-compose up -d db && docker-compose logs -f
# check whether logs show the message "PostgreSQL init process complete; ready for start up."
 
```
### terminal B:
```bash
$ docker-compose run --rm initscript

### terminal A:

```bash
$ docker-compose down && docker-compose up -d backendserver && docker-compose logs -f
# check whether containers are running
# logs show the message "Grails application running at http://localhost:8884 in environment: production"
```

### terminal B:
```bash
$ docker-compose run --rm initializationscript

```

### terminal A:

```bashc
$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# check whether iDMED is up running

Go to the Browser your aplication is running at http://[localhost/COLOCAR_IP]:5000
[Select the Health Facility]

```bash
$ docker-compose run --rm updatescript
$ docker-compose run --rm initbucardoscript
# check whether bucardo db and schema are created

$ docker-compose down && docker-compose up -d frontendserver bucardo && docker-compose logs -f
# check whether iDMED is up running

=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>UPDATE ONLY=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>
### terminal B:
```bash
$ docker-compose run --rm updatescript
```

### terminal A:

```bashc
$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# check whether iDMED is up running

Go to the Browser your aplication is running at http://[localhost/COLOCAR_IP]:5000

$ docker-compose run --rm initbucardoscript
$ docker-compose up -d bucardo
# check whether bucardo db and schema are created
