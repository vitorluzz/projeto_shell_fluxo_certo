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

# Instalação do Java em paralelo
instalar_java() {
    echo "🔧 Verificando se o Java está instalado..."
    if type -p java > /dev/null; then
        echo "✅ Java já está instalado!"
    else
        echo "⏳ Java não encontrado. Instalando..."
        sudo apt install -y openjdk-21-jdk
        echo "✅ Java instalado com sucesso!"
    fi
}

# Instalação do Docker
instalar_docker() {
    echo "🔧 Verificando se o Docker está instalado..."
    if command -v docker > /dev/null 2>&1; then
        echo "✅ Docker já está instalado!"
    else
        echo "⏳ Instalando Docker..."
        sudo apt install -y docker.io
        echo "✅ Docker instalado com sucesso!"
    fi

    echo "🚀 Iniciando serviço do Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
}

# Instalação do Docker Compose
instalar_docker_compose() {
    echo "🔧 Verificando se o Docker Compose está instalado..."
    if command -v docker-compose > /dev/null 2>&1; then
        echo "✅ Docker Compose já está instalado!"
    else
        echo "⏳ Instalando Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "✅ Docker Compose instalado com sucesso!"
    fi

    echo "📦 Versão do Docker Compose:"
    sudo docker-compose version
}

# Subir containers com Docker Compose
start_containers() {
    echo "🚀 Iniciando containers com Docker Compose..."
    sudo docker-compose up -d || { echo "❌ Falha ao iniciar os containers!"; exit 1; }
    echo "✅ Todos os containers foram iniciados com sucesso!"
}

# Iniciar instalação do Java em paralelo
instalar_java &

# Fluxo sequencial: Docker → Compose → Containers
instalar_docker
instalar_docker_compose
start_containers

# Esperar instalação do Java, se ainda estiver rodando
wait

echo "✅ Ambiente FLUXO-CERTO preparado com sucesso!"

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
