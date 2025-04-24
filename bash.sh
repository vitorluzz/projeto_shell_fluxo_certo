#!/bin/bash

echo "  
  ______ _                    _____          _        
 |  ____| |                  / ____|        | |       
 | |__  | |_   ___  _____   | |     ___ _ __| |_ ___  
 |  __| | | | | \ \/ / _ \  | |    / _ \ '__| __/ _ \ 
 | |    | | |_| |>  < (_) | | |___|  __/ |  | || (_) |
 |_|    |_|\__,_/_/\_\___/   \_____\___|_|   \__\___/ 
                                                      
"

echo "Iniciando FLUXO-CERTO..."

echo "Verificação de dependências do sistema..."

echo "Atualizando o SO..."
sudo apt update && sudo apt upgrade -y
echo "Sistema Operacional atualizado com sucesso!"

# VERIFICAÇÃO DO GIT
echo "Verificando se o Git está instalado..."
git --version > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Cliente já possui o Git instalado!"
else
    echo "Cliente não possui o Git instalado!"
    echo "Instalando o Git..."
    sudo apt install -y git
    echo "Instalação do Git concluída!"
fi

# VERIFICAÇÃO JAVA
echo "Verificando se o Java está instalado..."
java -version
if [ $? -eq 0 ]; then
    echo "Cliente já possui o Java instalado!"
else
    echo "Cliente não possui o Java instalado!"	
    echo "Instalando o Java..."
    sudo apt install -y openjdk-21-jdk
    echo "Instalação do Java concluída!"
fi

# VERIFICAÇÃO DOCKER
echo "Verificando se o Docker está instalado..."
docker --version
if [ $? -eq 0 ]; then
    echo "Cliente já possui o Docker instalado!"
else
    echo "Cliente não possui o Docker instalado!"	
    echo "Instalando o Docker..."
    sudo apt install -y docker.io
    echo "Instalação do Docker concluída!"
fi

echo "Iniciando os serviços de docker..."
sudo systemctl start docker

# BANCO DE DADOS
echo "Acessando o diretório do banco de dados..."

cd bancoDeDadosMYSQL || exit
if [ "$(sudo docker ps -a -q -f name=container-bd)" ]; then
    echo "Container do banco de dados já existe."
    if [ "$(sudo docker ps -q -f name=container-bd)" ]; then
        echo "Container do banco já está em execução."
    else
        echo "Iniciando o container do banco de dados..."
        sudo docker start container-bd
    fi
else
    echo "Criando e iniciando o container do banco de dados..."
    sudo docker build -t imagem-bd-fluxo-certo .
    sudo docker run -d --name container-bd -p 3306:3306 imagem-bd-fluxo-certo
fi
echo "Saindo do diretório do banco de dados..."
cd ..


# SITE FLUXO-CERTO
echo "Acessando o diretório do site..."
cd siteFluxoCerto || exit

if [ "$(sudo docker ps -a -q -f name=container_fluxocerto)" ]; then
    echo "Container do site já existe."
    if [ "$(sudo docker ps -q -f name=container_fluxocerto)" ]; then
        echo "Container do site já está em execução."
    else
        echo "Iniciando o container do site..."
        sudo docker start container_fluxocerto
    fi
else
    echo "Criando e iniciando o container do site..."
    sudo docker build -t fluxocerto .
    sudo docker run -d -p 8080:8080 --name container_fluxocerto fluxocerto
fi

echo "Saindo do diretório do site..."
cd ..

# ETL
echo "Copiando o arquivo JAR que está no docker para dentro da instância..."
sudo docker cp container_fluxocerto:/usr/src/app/java/conexao-banco/target/conexao-banco-1.0-SNAPSHOT-jar-with-dependencies.jar ./conexao-banco.jar

echo "Executando o JAR"
java -jar conexao-banco.jar

echo "Tratamento de dados foi um sucesso!"

echo "  
  ______ _                    _____          _        
 |  ____| |                  / ____|        | |       
 | |__  | |_   ___  _____   | |     ___ _ __| |_ ___  
 |  __| | | | | \ \/ / _ \  | |    / _ \ '__| __/ _ \ 
 | |    | | |_| |>  < (_) | | |___|  __/ |  | || (_) |
 |_|    |_|\__,_/_/\_\___/   \_____\___|_|   \__\___/ 
                                                      
"
echo "✅ Sua aplicação está rodando com sucesso!"
IP=$(curl -s http://checkip.amazonaws.com)
echo "🌐 Acesse em: http://$IP:8080"

