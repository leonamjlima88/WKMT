# WKMT
Multitier

### Banco de dados
Postgres.

Necessário rodar script de criação das tabelas: "script_database.sql" localizado na pasta raiz do projeto.

Configurar credenciais para acesso ao banco de dados no arquivo uMain.pas na seção de constantes

  CONN_DATABASE   = 'postgres';
  
  CONN_SERVER     = 'localhost';
  
  CONN_USERNAME   = 'postgres';
  
  CONN_PASSWORD   = 'secret';
  
  CONN_DRIVER_ID  = 'PG';
  
  CONN_VENDOR_LIB = 'C:\Program Files\PostgreSQL\15\pgAdmin 4\bin\libpq.dll';
  
