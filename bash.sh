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

# VERIFICAÇÃO UNZIP
echo "Verificando se o unzip está instalado..."
unzip -v > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Cliente já possui o unzip instalado!"
else
    echo "Cliente não possui o unzip instalado!"
    echo "Instalando o unzip..."
    sudo apt install -y unzip
    echo "Instalação do unzip concluída!"
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
    sudo docker run -d -p 3000:3000 --name container_fluxocerto fluxocerto
fi

echo "Saindo do diretório do site..."
cd ..

# BUCKET S3

echo "Entrando no container do Fluxo Certo..."
sudo docker exec -it container_fluxocerto bash

echo "Acessando o diretório dos dados brutos..."
cd Documentos/Bases\ de\ Dados/

echo "Atualizando o container..."
apt update && apt install -y awscli

read -p "Digite o nome do bucket S3 (sem 's3://'): " nome_bucket

nome_arquivo1="curated - entrada passageiros por linha 2020 - 2024.csv"
nome_arquivo2="curated - Demanda de Passageiros por Estação 2020 - 2024.csv"

# Upload do primeiro arquivo
if [ -f "$nome_arquivo1" ]; then
    echo "Fazendo upload de '$nome_arquivo1' para o bucket 's3://$nome_bucket/' ..."
    
    aws s3 cp "$nome_arquivo1" "s3://$nome_bucket/$nome_arquivo1"
    
    if [ $? -eq 0 ]; then
        echo "✅ Upload de '$nome_arquivo1' concluído com sucesso!"
    else
        echo "❌ Erro ao fazer upload de '$nome_arquivo1'."
    fi
else
    echo "❌ Arquivo '$nome_arquivo1' não encontrado no diretório atual."
fi

# Upload do segundo arquivo
if [ -f "$nome_arquivo2" ]; then
    echo "Fazendo upload de '$nome_arquivo2' para o bucket 's3://$nome_bucket/' ..."
    
    aws s3 cp "$nome_arquivo2" "s3://$nome_bucket/$nome_arquivo2"
    
    if [ $? -eq 0 ]; then
        echo "✅ Upload de '$nome_arquivo2' concluído com sucesso!"
    else
        echo "❌ Erro ao fazer upload de '$nome_arquivo2'."
    fi
else
    echo "❌ Arquivo '$nome_arquivo2' não encontrado no diretório atual."
fi

echo "Saindo do diretório dos dados brutos..."
cd ..
cd ..

echo "Entrando no diretório do ETL..."
cd java/conexao-banco/target/