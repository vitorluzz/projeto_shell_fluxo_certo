#!/bin/bash

START_TIME=$(date +%s)

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

verificar_docker_e_containers() {
    echo "Verificando se o Docker está instalado..."
    if command -v docker > /dev/null 2>&1; then
        echo "Docker já está instalado!"
    else
        echo "Docker não está instalado. Instalando..."
        sudo apt update && sudo apt install -y docker.io
        echo "Docker instalado com sucesso!"
    fi

    echo "Iniciando o serviço do Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # Instalar Docker Compose em paralelo
    instalar_docker_compose &

    # Iniciar containers com docker-compose
    start_containers

    # Esperar instalação do docker-compose finalizar (se ainda estiver rodando)
    wait
    echo "Ambiente Docker e containers prontos!"
}


# Função para verificar e instalar o Docker Compose
instalar_docker_compose() {
    echo "Verificando se o Docker Compose está instalado..."
    if command -v docker-compose > /dev/null 2>&1; then
        echo "Docker Compose já está instalado!"
    else
        echo "Instalando Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose instalado com sucesso!"
    fi

    echo "Verificando versão do Docker Compose..."
    docker-compose version
}

# Função para iniciar os containers do banco e do site
start_containers() {
    echo "Iniciando todos os containers necessários..."
    sudo docker-compose up -d
    echo "Todos os containers foram iniciados com sucesso!"
}

instalar_docker_compose &
start_containers

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

echo ""
echo "==============================================================================="
echo ""


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
echo ""
echo "🌐 Acesse a aplicação rodando em: http://$IP:8080"
echo ""
echo ""
echo ""
echo "🔍 Testando conexão..."
if curl -s --head --request GET "http://$IP:8080" | grep "200 OK" > /dev/null; then
    echo "✅ Conexão bem-sucedida! Tudo certo!"
else
    echo "⚠️ Atenção: Não foi possível validar a conexão automaticamente."
    echo "   Verifique se os containers estão rodando ou tente novamente em alguns segundos."
fi

# Mostrar o tempo total
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

echo ""
echo "⏱️ Tempo total de preparação: ${ELAPSED_TIME} segundos."
echo ""
echo "==============================================================================="
