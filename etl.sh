#!/bin/bash

START_TIME=$(date +%s)

echo "Iniciando o processo de ETL..."
# ETL
echo "Copiando o arquivo JAR que está no docker para dentro da instância..."
sudo docker cp container-fluxocerto:/usr/src/app/java/extracao-dados/target/extracaoDados.jar ./extracaoDados.jar

echo "Copiando o arquivo JAR para dentro do container Java..."
sudo docker cp ./extracaoDados.jar container_java:/home/extracaoDados.jar


echo "Executando o JAR dentro do container Java..."
sudo docker exec -it container_java java -jar /home/extracaoDados.jar

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