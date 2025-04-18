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

echo "Atualizando o SO..."
sudo apt update && sudo apt upgrade
echo "Sistema Operacional atualizado com sucesso!"

echo "Verificando se o Java está instalado..."
java -version # Verficando a versao atual do java

if[$? = 0]; # Se o retorno for igual a 0

then #entao,
		echo "Cliente já possui o java instalado!"
		
	else # se nao,
		echo "Cliente não possui o java instalado!"	
		echo "Instalando o java..."
		sudo apt install openjdk-21-jdk
		echo "Instalação foi feita com sucesso!"
		
fi # Fechando o if

echo "Verificando se o docker está instalado..."

docker --version # Verificando a versão do docker

if[$? -eq 0]; # Se o retorno f	or igual a 0

	then #entao,
		echo "Cliente já possui o docker instalado!"
		
	else # se nao,
		echo "Cliente não possui o docker instalado!"	
		echo "Instalando o docker..."
		sudo apt install -y docker.io
		echo "Instalação foi feita com sucesso!"
		
fi # Fechando o if


echo "Iniciando os serviços de docker..."
sudo systemctl start docker

# BANCO DE DADOS
echo "Acessando a pasta do banco de dados..."

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
echo "Saindo da pasta do banco de dados..."
cd ..


# SITE FLUXO-CERTO
echo "Acessando a pasta do site..."
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

echo "Saindo da pasta do site..."
cd ..