# iDMED (v1.4.0)

## _Notas da release_

## Relatórios 

### Relatórios do serviço de Saúde TARV

#### Relatórios de Stock
- Balancete Diário (Novo)
#### Relatórios de Gestão de Farmácia
- Utentes Abandono - **Ticket #3596 (Novo)**
- MMIA - Actualização do MMIA para contabilização de utentes em PrEP - **Ticket #3582 (Actualização)**
- MMIA - Ajustes Negativos e Perdas - **Ticket #3724**
- Utentes que Abandonaram e Retornaram (Novo)
- Segundas Linhas Terapêuticas (Novo)
- Linhas Terapêuticas Usadas (Novo)
#### Relatórios de Monitoria e Avaliação
- Utentes Registados a partir do iDMED (Novo)


## Funcionalidades e Formulários

####  Módulo de Gestão de Utentes
- Registro de Prescrição e Dispensa - **Ticket #3723 (Actualização)**

## Correcções de Erros

#### Módulo de Gestão de Utentes
- Erro durante o processo de união de Utentes - **Ticket #3646**
- Lentidão ao Abrir Painel de Utentes- **Ticket #3633**
- Lentidão ao Dispensar Medicamentos - **Ticket #3653**
#### Módulo de Relatórios:
- Histórico de Levantamento de Utentes Referidos - **Ticket #3609**
- MMIA - Inconsistência de dados - **Ticket #3582**
- MMIA - Dispensas CCR não reflectem no MMIA - **Ticket #3598**

## Documentos

#### Notas da Release:
- iDMED - Release Notes_Sept_2024_PT
#### Documentos de Requisitos iDMED_Web:
- iDMED_REL_029_Balancete_Diário_v.1.0
- iDMED_REL_030_Utentes_Abandono_v.1.0
- iDMED_REL_031_Utentes_Abandonaram_retornaram_v.1.0
- iDMED_REL_032_Utentes_Segunda_Linha_v.1.0
- iDMED_REL_033_Linhas_Terapeuticas_Usadas_v.1.0
- iDMED_REL_034_Utentes_Registrados_iDMED_v.1.0



## Installation

Primeiro instale o docker [Docker](https://docs.docker.com/get-started/.).
Localize o arquivo .zip de instalação fornecidos no pacote desta release no [sharedrive]( https://drive.google.com/drive/folders/1H3dN9ddTq2dq7c9y9_xcUV-9LHhFPYqD) na pasta Code Package
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
$ docker login hub.csaude.org.mz
# Introduzir utilizador/senha. 
# Nota: Solicitar credenciais a Equipa de Administração de Sistemas da C-Saúde
```

Para uma nova instalação

```sh
$ docker-compose up -d db && docker-compose logs -f
# Verifique se a mensagem a seguir é ilustrada "PostgreSQL init process complete; ready for start up."

$ $ docker-compose run --rm initscript
# Verifique se a mensagem a seguir é ilustrada "DATABASE CREATED." ou "DATABASES ALREADY EXISTS "

$ docker-compose down && docker-compose up -d backendserver && docker-compose logs -f
# Verifique se os containers estão em execução
# Verifique se a mensagem a seguir é ilustrada  "Grails application running at http://localhost:8884 in environment: production"

$ docker-compose run --rm initializationscript
$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# Verifique se o iDMED esta em execução

$ docker-compose run --rm updatescript
$ docker-compose run --rm initbucardoscript
# Verifique se a base de dados e schema "bucardo" foram criados

$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# Verifique se o iDMED esta em execução
```
Abra o seu navegador, e a aplicação estará em execução em:
```sh
http://[localhost/COLOCAR_IP]:5000
```
Select the Health Facility

Para uma actualização
```sh
$ docker-compose run --rm updatescript
$ docker-compose run --rm initbucardoscript
# Verifique se a base de dados e schema "bucardo" foram criados

$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# check whether iDMED is up running
```

Abra o seu navegador, e a aplicação estará em execução em:
```sh
http://[localhost/COLOCAR_IP]:5000
```

## Preparação e Execução do Serviço Bucardo
Primeiro, precisamos garantir que os esquemas das bases de dados **source** e **target** sejam iguais, ou pelo menos que as tabelas que serão usadas para a sincronização estejam devidamente alinhadas. 

Usando a linha de comando, execute o comando abaixo para acessar o serviço de banco de dados dentro do contêiner Docker:

```sh
docker exec -it csaude-idmed-current_db_1 /bin/bash
```
Nota: Pode utilizar um cliente de banco de dados PostgreSQL do seu domínio para executar os comandos

### Efectue o backup da base de dados do iDMED
```sh
postgres#  pg_dump --file "backupIdmedDB_1.4.0.backup" --host "localhost" --port "9876" --username "postgres" --no-password --format=c --blobs --data-only  --inserts --column-inserts --verbose "idmed";
```
Baixe o arquivo **schemaProvincialServer01-v15.sql** com o novo esquema da base de dados do iDMED através deste [Link](https://drive.google.com/file/d/1sVKRaRVNOsedcLnhHTCpxZxpISCmBZG6/view?usp=drive_link)

### Efectue o restore a nova base de dados
```sh
postgres# DROP DATABSE idmed;
postgres# CREATE DATABASE idmed;

postgres# pg_restore --host "localhost" --port "9876" --username "postgres" --no-password --dbname "idmed" --verbose "schemaProvincialServer01-v15.sql";

postgres# pg_restore --host "localhost" --port "9876" --username "postgres" --no-password --dbname "idmed" --verbose "backupIdmedDB_1.4.0.backup";
```

### Execução do Serviço iDMED
```sh
$ docker-compose down && docker-compose up -d frontendserver && docker-compose logs -f
# Verifique se o iDMED esta em execução
```

### Inicialização do Serviço bucardo
```sh
$ docker-compose up -d bucardo && docker-compose logs -f
# Verifique se o bucardo esta em execução
```
Usando a linha de comando, execute o comando abaixo para acessar o serviço de banco de dados dentro do contêiner Docker ou um cliente de banco de dados PostgreSQL do seu domínio para executar os comandos
```sh
postgres# UPDATE bucardo.db SET dbhost=[add_host], dbport=[add_port], dbname=[add_db_provincial] WHERE name = 'idmedCentral';
postgres# SELECT * from bucardo.db WHERE name = 'idmedCentral';
# Verifique a altetação na base de dados
```
### Reinicie o Serviço bucardo
```sh
$ docker-compose restart bucardo && docker-compose logs -f
# Verifique se o bucardo esta em execução
``` 
### Verificação do estado do serviço bucardo
Usando a linha de comando, execute o comando abaixo para acessar o serviço de banco de dados dentro do contêiner Docker:

```sh
docker exec -it idmed-bucardo-1 /bin/bash
```
Dentro do contêiner, execute o seguinte comando:
```sh
root@:/# bucardo -h db -U bucardo status
```
Após a execução do comando, você deverá obter o seguinte resultado:
| Name | README | README | README | README | README | README |
| ---- | ------ | ------ | ------ | ------ | ------ | ------ |
| idmed_sync | Good | 16:14:50 | 46m 53s | 9/9  | none |  |


| Name | README | README | README | README | README | README |
| ---- | ------ | ------ | ------ | ------ | ------ | ------ |
| idmed_sync | Bad | 16:14:50 | 46m 53s | 9/9  | none |  |

Se o resultado obtido for ***Bad***, execute o comando a seguir para identificar o erro e contacte o helpdesk para suporte:
```sh
root@:/# tail -f /var/log/bucardo/log.bucardo
```

## License
CSAUDE
