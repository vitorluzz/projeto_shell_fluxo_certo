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

echo "Atualizando o SO..."
sudo apt update
echo "Sistema Operacional atualizado com sucesso!"

# Funções para verificar e instalar
verificar_git() {
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
}

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

verificar_docker() {
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
}

# Rodar tudo em paralelo
verificar_git &
verificar_java &
verificar_docker &

# Esperar todos os processos terminarem
wait

echo "Verificações e instalações concluídas!"

echo ""
echo "==============================================================================="
echo ""

# Iniciar o serviço do Docker
echo "Iniciando os serviços de docker..."
sudo systemctl start docker

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

# Rodar os dois em paralelo
start_banco &
start_site &

# Esperar os dois terminarem
wait

echo "Containers prontos!"

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

