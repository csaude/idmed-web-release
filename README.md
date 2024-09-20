# iDMED (v1.4.0)

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
