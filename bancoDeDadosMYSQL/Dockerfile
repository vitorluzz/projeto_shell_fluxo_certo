# use a imagem oficial do MySQL como imagem base
FROM mysql:latest
# defina variáveis de ambiente para a senha do rrot do MySQL
ENV MYSQL_ROOT_PASSWORD=urubu100
# copie os scripts SQL de inicialização para um diretório temporário no container
COPY ./tabelas.sql /docker-entrypoint-initdb.d/
# exponha a porta padrão do MySQL
EXPOSE 3306