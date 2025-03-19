# iDMED (v1.6.0)

## Relatórios

### Relatórios do Serviço de Saúde TARV

#### Relatórios de Gestão de Farmácia
- **Faltosos ao levantamento de ARVs para APSS** - *Ticket #3655*

#### Relatórios de Monitoria e Avaliação
- **Dispensas Não Sincronizadas para o OpenMRS** - *Ticket #3713*

---

## Funcionalidades e Formulários

### Módulo de Gestão de Stock
- **Distribuição de Stock** (*Novo*)

### Módulo de Administração Geral
- **Constrangimento no acesso aos sectores clínicos** - *Ticket #3777*
- **Configuração de Sector Clínico** - *Ticket #3774*
- **Update do `parent_clinic_id`** - *Ticket #3804*
- **Atribuição automática de `Location UUID`** - *Ticket #3677* (*Novo*)

---

## Documentos

### Notas da Release
- **iDMED - 1.5.0 Release Notes_Dec_2024**

### Documentos de Requisitos iDMED_Web
- **iDMED_STK_005_Distribuição**
- **iDMED_PAT_004_Registo_Manutenção_Prescrições**
- **iDMED_REL_035_Dispensas_Não_Sincronizadas**
- **iDMED_REL_015_Faltosos_Levantamento_ARVs_APSS**
- **iDMED_Mobile_STK_FUNC_002_Distribuição_Stock**

---


## Instalação

### Pré-requisitos
1. Instale o Docker seguindo as instruções no [site oficial](https://docs.docker.com/get-started/).
2. Certifique-se de que a versão do Docker Compose seja superior a `v1.25.0`.
3. Baixe o pacote de instalação `.zip` no [GitHub]() na pasta `Code Package`.
4. Copie o arquivo `csaude-idmed-current_Instalation.zip` para o diretório `idmedSetup` e execute os comandos:

#### **Instalação Offline**
```sh
$ unzip csaude-idmed_current_Instalation.zip
$ unzip idmed-images.tar.xz
$ docker load -i idmed-images.tar
```

#### **Instalação Online**
```sh
$ unzip csaude-idmed_current_Instalation.zip
```

### Configuração do ficheiro `.env`
Atualize o arquivo `.env` com as credenciais fornecidas. Caso não tenha recebido, solicite à equipa da CSAUDE.

```sh
### Configuração da Base de Dados e Backup
POSTGRES_HOST=[dbHost]
POSTGRES_DB=[idmedDB]
POSTGRES_USER=[idmedUserDB]
POSTGRES_PASSWORD=[idmedPASSDB]
POSTGRES_PORT=5432
POSTGRES_EXTRA_OPTS="-Z6 --schema=public --blobs"
SCHEDULE=@weekly
BACKUP_KEEP_DAYS=3
BACKUP_KEEP_WEEKS=2
BACKUP_KEEP_MONTHS=1
HEALTHCHECK_PORT=8989

### Configuração do Bucardo (Destino)
TARGET_DB_NAME=[ProvincialDBName]
TARGET_DB_USER=[ProvincialDBUser]
TARGET_DB_PASS=[ProvincialDBPASS]
TARGET_DB_PORT=[ProvincialDBPORT]
TARGET_DB_HOST=[ProvincialDBHOST]

### Configuração do Bucardo (Origem)
SOURCE_DB_NAME=[idmedDB]
SOURCE_DB_USER=[idmedUserDB]
SOURCE_DB_PASS=[idmedPASSDB]

### Configuração do Backend (Origem)
DB_USER=[idmedUserDB]
DB_PASS=[idmedPASSDB]
DB_URL=jdbc:postgresql://db:5432/idmed
```
---

## Execução do iDMED

### Para uma **Nova Instalação**

```sh
$ docker-compose --env-file .env up -d db && docker-compose logs -f
# Verifique se a mensagem a seguir é ilustrada "PostgreSQL init process complete; ready for start up."

$ docker-compose --env-file .env run --rm initscript
# Verifique se a mensagem a seguir é ilustrada "DATABASE CREATED." ou "DATABASES ALREADY EXISTS "

$ docker-compose --env-file .env run --rm initializationscript
$ docker-compose --env-file .env down && docker-compose up -d frontendserver && docker-compose logs -f
# Verifique se o iDMED esta em execução

$ docker-compose --env-file .env run --rm initdbscript
$ docker-compose --env-file .env run --rm initbucardoscript
# Verifique se a base de dados e schema "bucardo" foram criados

$ docker-compose --env-file .env up -d bucardo && docker-compose logs -f
# Verifique se a sincronizacao com "bucardo" esta em execução

$ docker-compose down && docker-compose --env-file .env up -d frontendserver && docker-compose logs -f
# Verifique se o iDMED esta em execução

$ docker-compose --env-file .env up -d bucardo && docker-compose logs -f
# Verifique se a sincronização com "bucardo" está em execução
```
---

## Acesse o iDMED
```sh
Abra o seu navegador, e a aplicação estará em execução em:
http://[localhost/COLOCAR_IP]:5000
```
---

## Para uma **Atualização**

### 1. Preparação e Execução da Atualização
Primeiro, precisamos garantir que o serviço de base de dados seja o unico em execução.

```sh
$ docker-compose down && docker-compose --env-file .env up -d db && docker-compose logs -f
# Verifique se a mensagem a seguir é ilustrada "PostgreSQL init process complete; ready for start up."
```

### 2. Efectue o backup da base de dados do iDMED
```sh
$ docker-compose --env-file .env run --rm backupscript
# Verifique se o backup esta em execução
```

### 3. Execução do Serviço iDMED
```sh
$ docker-compose --env-file .env run --rm updatescript
# Actualização da database idmed to para a versão 1.6.0

$ docker-compose down && docker-compose --env-file .env up -d backendserver && docker-compose logs -f
# Verifique se a mensagem a seguir é ilustrada  "Grails application running at http://localhost:8884 in environment: production"

$ docker-compose down && docker-compose --env-file .env up -d frontendserver && docker-compose logs -f
# Verifique se o serviço "iDMED" esta em execução
```

## Acesse o iDMED
```sh
Abra o seu navegador, e a aplicação estará em execução em:
http://[localhost/COLOCAR_IP]:5000
```
---

## Inicialização e Verificação do Serviço Bucardo

### 1. Inicialização do Bucardo
```sh
$ docker-compose --env-file .env run --rm initbucardoscript
# Verifique se a base de dados "bucardo" existe

$ docker-compose --env-file .env run --rm bucardosyncdatascript
# Verifique se o envio de dados para o servidor provincial executou com sucesso

$ docker-compose --env-file .env up -d bucardo && docker-compose logs -f
# Verifique se o serviço "bucardo" está em execução
```

### 2. Verificação do Estado do Bucardo
```sh
docker exec -it idmed_bucardo_1 /bin/bash
# Acessar o serviço de banco de dados dentro do contêiner Docker

# Dentro do contêiner, execute o seguinte comando
root@:/# bucardo -h db -U bucardo status
```

Após a execução do comando, deverá obter o seguinte resultado:
| Name | State | Last Good | Time | Last I/D | Last Bad | Time |
| ---- | ------ | ------ | ------ | ------ | ------ | ------ |
| idmed_sync | Good | 16:14:50 | 46m 53s | 9/9  | none |  |

ou

| Name | State | Last Good | Time | Last I/D | Last Bad | Time |
| ---- | ------ | ------ | ------ | ------ | ------ | ------ |
| idmed_sync | Bad | 16:14:50 | 46m 53s | 9/9  | none |  |

Se o resultado obtido for ***Bad***, execute o comando a seguir para identificar o erro e contacte o helpdesk para suporte:
```sh
root@:/# tail -f /var/log/bucardo/log.bucardo

## Resolução de possíveis Erros

### Verificação do Serviço de Réplica Lógica
```sh
$ docker-compose logs -f
```
Se encontrar os seguintes erros, siga os procedimentos:

1. **Erro: Chave duplicada**
   ```
   ERROR: duplicate key value violates unique constraint ....
   ```
   **Solução:**  
   ```sql
   ALTER SUBSCRIPTION sub_uuid SKIP (lsn = '0/1562C10');
   ```
   *sub_uuid* é o nome da subscrição e *lsn* é o último valor registrado no erro.

2. **Erro: Replication slot ativo**
   ```
   ERROR: could not start WAL streaming: ERROR: replication slot "xxxyyyzzz" is active for *PID 25860*
   ```
   **Solução:**  
   ```sql
   ALTER SUBSCRIPTION sub_uuid REFRESH PUBLICATION WITH (copy_data = false);
   ```
   *sub_uuid* é o nome da subscrição e *PID* é o último processo registrado no erro.
Se o erro persistir, contacte o helpDesk e envie a mensagem ilustrada *PID 25860* para o suporte


## Licença
**CSAUDE**
