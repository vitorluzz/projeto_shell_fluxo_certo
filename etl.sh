#!/bin/bash

START_TIME=$(date +%s)

echo "Iniciando o processo de ETL..."
# ETL


echo "Executando o jar ..."

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