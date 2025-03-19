#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Configurações de banco de dados
my $dsn = "DBI:Pg:dbname=idmed;host=localhost;port=9876";
my $user = "postgres";
my $password = "postgres";

# Conectar ao banco de dados
my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 });

# Log de início de execução
print "Iniciando a execução do script de replicação...\n";

# Função para verificar condições específicas
sub should_replicate {
    my ($record) = @_;
    
    # Log do início da verificação de replicação
    print "Verificando se o registro de origin = $record->{origin} deve ser replicado...\n";
    
    # Verificar o origin na tabela de configuração
    my $sth = $dbh->prepare("SELECT description FROM system_configs WHERE value='LOCAL'");
    $sth->execute($record->{origin});
    my $exists = $sth->fetchrow_arrayref();
    
    # Log do resultado da verificação
    if ($exists) {
        print "O registro de origin = $record->{origin} foi aprovado para replicação.\n";
    } else {
        print "O registro de origin = $record->{origin} NÃO será replicado.\n";
    }

    return 1 if $exists;
    return 0;
}

# Função que será chamada pelo Bucardo
sub execute_customcode {
    my ($record) = @_;
    
    # Log de início da execução da função customizada
    print "Executando a função customizada para o registro...\n";
    
    my $result = should_replicate($record) ? 1 : 0;
    
    # Log do fim da execução
    if ($result) {
        print "Replicação concluída com sucesso para o registro.\n";
    } else {
        print "Replicação abortada para o registro.\n";
    }

    return $result;
}

# Log de fim da execução do script
print "Fim da execução do script de replicação.\n";

1;  # O script deve retornar 1 para indicar sucesso

