# iDMED (v1.7.0)

## Relatórios do Serviço de Saúde TARV

### Relatórios de Gestão de Farmácia
 **Relatório de Dispensas não Sincronizadas para o OpenMRS**
 - **Remoção do histórico das dispensas sincronizadas para o SESP** - *Ticket 3960*
 - **Remoção de dispensas de pacientes em trânsito** - *Ticket 3713*

**Relatório de Histórico de Levantamentos**
- **Inclusão da coluna com a US de Proveniência do Paciente em Trânsito** - *Ticket 3826*

**Relatório MMIA**
- **Discrepâncias no MMIA** - *Ticket 3826*
---

## Funcionalidades e Formulários

### Módulo de Gestão de Utentes
#### Pesquisa e Visualização de Utente
- **Visualização dos dados demográficos e clínicos do utente mediante scan de código de barras**  - *Novo*
  
- **Gestão de Prescrições e Dispensas**
  - **Remoção da validação do preenchimento da Linha terapêutica nas dispensas dos regimes de TPT** - *Ticket #3990*
  - **Prescrição TPT: Situação do paciente iDMED diferente do OpenMRS** - *Ticket #3967 e #3968*
  - **iDMED - Remoção de prescrição do paciente** - *Ticket #3980*
  - **Pedido para usar UUID do paciente para verificar estado no SESP antes da dispensa** - *Ticket #4040*
  - **Carregamento de foto da prescrição**- *Novo*
  - **Remoção da sincronização das dispensas dos utentes em trânsito, para o SESP na US de proveniência.**

- **Módulo de Gestão de Grupos**
  - **Erro na Dispensa de Medicamentos para Grupos** - *Ticket #4046*
    
- **Módulo de Gestão de Stock**
  - **Auditoria para inventários e Ajustes** - *Ticket #4048*
- **Módulo de Administração**
  - **Criação dos perfis de utilizadores segundo as funcionalidades necessárias.**- *Ticket #3948*
  - **Inclusão dos medicamentos e regime pALD (ABC+3TC+DTG (3DFC DTG5mg))** - *Novo*

- **Criação/Importação de utentes**
  - **iDMED - Pacientes PREP são carregados com data de admissão errada** - *Ticket 3978*
- **Gestão de prescrições e Dispensas**
  - **iDMED - Regimes TPT nao tem medicamentos mapeados** - *Ticket 3979*
       
- **Registo de Inventário**
  - **Problema na Visualização Completa dos Números de Lote no iDMED** - *Ticket #4045*
       
- **Registo de Inventário**
  - **Problema na Visualização Completa dos Números de Lote no iDMED** - *Ticket #4045*
---

## Documentos

### Notas da Release
- **iDMED - 1.6.0 Release Notes_Mar_2025**


#### Guia de instalação:
- **iDMED_Guia_Instalação_1.7.0**

### Documentos de Requisitos iDMED_Web
- **iDMED_ADM_003_Gestao_Perfis**
- **iDMED_ADM_013_LogsRegistry**
- **iDMED_PAT_001_Registo_Manutenção_Utentes**
- **iDMED_PAT_004_Registo_Manutenção_Prescrições**
- **iDMED_PAT_005_Registo_Manutenção_Dispensa_Medicamentos**
- **iDMED_REL_005_HistoricoDeLevantamentos**
- **iDMED_REL_003_Registo_Manutenção_Histórico_Clínico**
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
