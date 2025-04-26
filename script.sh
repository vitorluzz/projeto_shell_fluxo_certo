#!/bin/bash

echo "  
 
███████╗██╗     ██╗   ██╗██╗  ██╗ ██████╗  ██████╗███████╗██████╗ ████████╗ ██████╗ 
██╔════╝██║     ██║   ██║╚██╗██╔╝██╔═══██╗██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗
█████╗  ██║     ██║   ██║ ╚███╔╝ ██║   ██║██║     █████╗  ██████╔╝   ██║   ██║   ██║
██╔══╝  ██║     ██║   ██║ ██╔██╗ ██║   ██║██║     ██╔══╝  ██╔══██╗   ██║   ██║   ██║
██║     ███████╗╚██████╔╝██╔╝ ██╗╚██████╔╝╚██████╗███████╗██║  ██║   ██║   ╚██████╔╝
╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ 
                                                                                                                                          
"

echo "Iniciando FLUXO-CERTO..."

echo "Verificação de dependências do sistema..."

# Função para verificar e instalar Java
verificar_java() {
    echo "Verificando se o Java está instalado..."
    java -version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Cliente já possui o Java instalado!"
    else
        echo "Cliente não possui o Java instalado!"
        echo "Instalando o Java..."
        sudo apt install -y openjdk-21-jdk
        echo "Instalação do Java concluída!"
    fi
}

# Função para verificar e instalar Docker e já iniciar containers
verificar_docker_e_containers() {
    echo "Verificando se o Docker está instalado..."
    docker --version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Cliente já possui o Docker instalado!"
    else
        echo "Cliente não possui o Docker instalado!"
        echo "Instalando o Docker..."
        sudo apt install -y docker.io
        echo "Instalação do Docker concluída!"
    fi

    echo "Iniciando os serviços do Docker..."
    sudo systemctl start docker

    # Iniciar containers em paralelo também
    start_banco &
    start_site &
    
    wait
    echo "Containers prontos!"
}

# Função para o Banco de Dados
start_banco() {
    echo "Iniciando operações do Banco de Dados..."
    local dir_banco="./bancoDeDadosMYSQL"

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
        sudo docker build -t imagem-bd-fluxo-certo "$dir_banco"
        sudo docker run -d --name container-bd -p 3306:3306 imagem-bd-fluxo-certo
    fi
    echo "Banco de Dados pronto."
}

# Função para o Site Fluxo-Certo
start_site() {
    echo "Iniciando operações do Site Fluxo-Certo..."
    local dir_site="./siteFluxoCerto"

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
        sudo docker build -t fluxocerto "$dir_site"
        sudo docker run -d -p 8080:8080 --name container_fluxocerto fluxocerto
    fi
    echo "Site Fluxo-Certo pronto."
}

# Rodar Docker+containers e Java em paralelo
verificar_docker_e_containers &
verificar_java &

# Esperar ambos terminarem
wait

echo "✅ Ambiente preparado com sucesso!"

echo ""
echo "==============================================================================="
echo ""

echo "Iniciando o processo de ETL..."
# ETL
echo "Copiando o arquivo JAR que está no docker para dentro da instância..."
sudo docker cp container_fluxocerto:/usr/src/app/java/extracao-dados/target/extracaoDados.jar ./extracaoDados.jar

echo "Executando o JAR"
java -jar extracaoDados.jar

echo "Tratamento de dados foi um sucesso!"

echo "  
 
███████╗██╗     ██╗   ██╗██╗  ██╗ ██████╗  ██████╗███████╗██████╗ ████████╗ ██████╗ 
██╔════╝██║     ██║   ██║╚██╗██╔╝██╔═══██╗██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗
█████╗  ██║     ██║   ██║ ╚███╔╝ ██║   ██║██║     █████╗  ██████╔╝   ██║   ██║   ██║
██╔══╝  ██║     ██║   ██║ ██╔██╗ ██║   ██║██║     ██╔══╝  ██╔══██╗   ██║   ██║   ██║
██║     ███████╗╚██████╔╝██╔╝ ██╗╚██████╔╝╚██████╗███████╗██║  ██║   ██║   ╚██████╔╝
╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ 
                                                      
"
echo "✅ Sua aplicação está rodando com sucesso!"
IP=$(curl -s http://checkip.amazonaws.com)
echo "🌐 Acesse em: http://$IP:8080"

