#!/bin/bash

START_TIME=$(date +%s)

# ETL
# Verificar se o container 'container-java' existe
if ! sudo docker ps -a --format '{{.Names}}' | grep -q "^container-java$"; then
    echo "❌ O container 'container-java' não existe."
    echo "   Verifique se o nome está correto ou crie o container antes de executar este script."
    exit 1
fi

# Verificar se o container 'container-java' está rodando
if ! sudo docker ps --format '{{.Names}}' | grep -q "^container-java$"; then
    echo "ℹ️ O container 'container-java' existe, mas não está rodando. Tentando iniciar..."
    sudo docker start container-java > /dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Container 'container-java' iniciado com sucesso!"
    else
        echo "❌ Falha ao iniciar o container 'container-java'."
        exit 1
    fi
else
    echo "✅ O container 'container-java' já está em execução."
fi

echo "Iniciando o processo de ETL..."

echo "Copiando o arquivo JAR que está no docker para dentro da instância..."
sudo docker cp container_fluxocerto:/usr/src/app/java/extracao-dados/target/extracaoDados.jar ./extracaoDados.jar

echo "Copiando o arquivo JAR para dentro do container Java..."
sudo docker cp ./extracaoDados.jar container-java:/home/extracaoDados.jar


echo "Executando o JAR dentro do container Java..."
sudo docker exec container-java bash -c "source ~/.bashrc && java -jar /home/extracaoDados.jar"

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
echo "🌐 Acesse a aplicação rodando em: http://fluxocerto.duckdns.org/"
echo ""
echo ""
echo "🔗 Ou então, caso não tenha acesso ao IP Fixo do DuckDNS, acesse a aplicação rodando em: http://$IP:8080"
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
echo "⏱️ Tempo total do processo ETL: ${ELAPSED_TIME} segundos."
echo ""
echo "==============================================================================="