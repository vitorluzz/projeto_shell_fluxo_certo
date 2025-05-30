#!/bin/bash
START_TIME=$(date +%s)
echo "======================================================================================"
echo "  
 
███████╗██╗     ██╗   ██╗██╗  ██╗ ██████╗       ██████╗███████╗██████╗ ████████╗ ██████╗ 
██╔════╝██║     ██║   ██║╚██╗██╔╝██╔═══██╗     ██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗
█████╗  ██║     ██║   ██║ ╚███╔╝ ██║   ██║     ██║     █████╗  ██████╔╝   ██║   ██║   ██║
██╔══╝  ██║     ██║   ██║ ██╔██╗ ██║   ██║     ██║     ██╔══╝  ██╔══██╗   ██║   ██║   ██║
██║     ███████╗╚██████╔╝██╔╝ ██╗╚██████╔╝     ╚██████╗███████╗██║  ██║   ██║   ╚██████╔╝
╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝       ╚═════╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ 
                                                                                                                                          
"

echo "🚀 Inicializando containers e preparando ambiente da aplicação..."

# Lista de containers esperados
containers=("container-bd" "container-java" "container_fluxocerto")

# Função para verificar e iniciar container
iniciar_container() {
    nome="$1"

    # Verifica se o container existe
    if ! sudo docker ps -a --format '{{.Names}}' | grep -q "^${nome}$"; then
        echo "❌ Container '${nome}' não existe. Crie ou recupere o container manualmente."
        return
    fi

    # Verifica se o container está rodando
    if ! sudo docker ps --format '{{.Names}}' | grep -q "^${nome}$"; then
        echo "⏳ Iniciando container '${nome}'..."
        sudo docker start "$nome" > /dev/null
        if [ $? -eq 0 ]; then
            echo "✅ Container '${nome}' iniciado com sucesso."
        else
            echo "❌ Falha ao iniciar o container '${nome}'."
        fi
    else
        echo "✅ Container '${nome}' já está rodando."
    fi
}

# Itera sobre todos os containers e os inicia
for c in "${containers[@]}"; do
    iniciar_container "$c"
done

# Atualizar repositório dentro do container_fluxocerto
echo ""
echo "🔄 Executando 'git pull' no container_fluxocerto..."
sudo docker exec container_fluxocerto bash -c "cd /usr/src/app && git pull"

echo ""
echo "▶️ Iniciando a aplicação com 'npm run dev' no container_fluxocerto..."
sudo docker exec -d container_fluxocerto bash -c "cd /usr/src/app && npm install && npm run dev"

echo ""
echo "✅ Processo de inicialização concluído com sucesso!"

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
echo "⏱️ Tempo total de preparação do ambiente: ${ELAPSED_TIME} segundos."

echo "======================================================================================"
