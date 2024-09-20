# iDMED (v1.4.0)
## Installation

Primeiro instale o docker [Docker](https://docs.docker.com/get-started/.).
Localize o arquivo .zip de instalação fornecidos no pacote desta release no [sharedrive]( https://drive.google.com/drive/folders/1moEGeZISjc7xRH80TLxYwWhbtIVD9-Yv) na pasta Code Package
Copia o arquivo 'csaude-idmed-current_Instalation.zip' para o DIRECTORIO idmedSetup e execute os comandos

```sh
$ unzip csaude-idmed_current_Instalation.zip
$ unzip idmed-images.tar.xz
$ docker load -i idmed-images.tar
```

Para uma nova instalação

```sh
$ docker-compose up -d db && docker-compose logs -f
# check whether logs show the message "PostgreSQL init process complete; ready for start up."

$ $ docker-compose run --rm initscript
# check whether logs show the message "PostgreSQL init process complete; ready for start up."

$ docker-compose down && docker-compose up -d backendserver && docker-compose logs -f
# check whether containers are running
# logs show the message "Grails application running at http://localhost:8884 in environment: production"

$ docker-compose run --rm initializationscript
# check whether logs show the message "PostgreSQL init process complete; ready for start up."

$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# check whether iDMED is up running

$ docker-compose run --rm updatescript
$ docker-compose run --rm initbucardoscript
# check whether bucardo db and schema are created

$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# check whether iDMED is up running
```

Para uma actualização
```sh
$ docker-compose run --rm updatescript
$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# check whether iDMED is up running
```

Go to the Browser your aplication is running at
```sh
http://[localhost/COLOCAR_IP]:5000
```
Select the Health Facility

## License
CSAUDE
