#!/bin/bash

START_TIME=$(date +%s)

echo "  
 
███████╗██╗     ██╗   ██╗██╗  ██╗ ██████╗       ██████╗███████╗██████╗ ████████╗ ██████╗ 
██╔════╝██║     ██║   ██║╚██╗██╔╝██╔═══██╗     ██╔════╝██╔════╝██╔══██╗╚══██╔══╝██╔═══██╗
█████╗  ██║     ██║   ██║ ╚███╔╝ ██║   ██║     ██║     █████╗  ██████╔╝   ██║   ██║   ██║
██╔══╝  ██║     ██║   ██║ ██╔██╗ ██║   ██║     ██║     ██╔══╝  ██╔══██╗   ██║   ██║   ██║
██║     ███████╗╚██████╔╝██╔╝ ██╗╚██████╔╝     ╚██████╗███████╗██║  ██║   ██║   ╚██████╔╝
╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝       ╚═════╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ 
                                                                                                                                          
"
echo "Iniciando FLUXO-CERTO..."
echo "Verificação de dependências do sistema..."

handle_error() {
    echo "❌ $1"
    exit 1
}

esperar_liberacao_apt() {
    echo "⏳ Aguardando liberação do APT..."
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        sleep 2
    done
}

instalar_java() {
    echo "🔧 Verificando se o Java está instalado..."
    if type -p java > /dev/null; then
        echo "✅ Java já está instalado!"
    else
        esperar_liberacao_apt
        echo "⏳ Java não encontrado. Instalando..."
        sudo apt install -y openjdk-21-jdk || handle_error "Erro ao instalar o Java"
        echo "✅ Java instalado com sucesso!"
    fi
}

instalar_docker() {
    echo "🔧 Verificando se o Docker está instalado..."
    if command -v docker > /dev/null 2>&1; then
        echo "✅ Docker já está instalado!"
    else
        esperar_liberacao_apt
        echo "⏳ Instalando Docker..."
        sudo apt install -y docker.io || handle_error "Erro ao instalar o Docker"
        echo "✅ Docker instalado com sucesso!"
    fi

    echo "🚀 Iniciando serviço do Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
    instalar_docker_compose
}

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
    start_containers
}

start_containers() {
    echo "🚀 Iniciando containers com Docker Compose..."
    sudo docker-compose up -d || handle_error "Falha ao iniciar os containers"
    echo "✅ Todos os containers foram iniciados com sucesso!"
}

esperar_mysql() {
    echo "⏳ Aguardando o MySQL iniciar (pode levar alguns segundos)..."
    until sudo docker exec container-bd mysqladmin ping -h"localhost" -uroot -purubu100 --silent; do
        printf "."
        sleep 2
    done
    echo "✅ MySQL está pronto para conexões!"
}

# Sequencial para evitar conflito de APT
instalar_java
instalar_docker

esperar_mysql

echo "✅ Ambiente FLUXO-CERTO preparado com sucesso!"
echo ""
echo "==============================================================================="
echo ""

echo "🚀 Iniciando configuração de rede e proxy reverso..."

limpando_apt() {
    echo "⏳ Limpando possíveis travas do APT..."

    pid=$(lsof /var/lib/dpkg/lock-frontend 2>/dev/null | awk 'NR==2 {print $2}')
    if [ -n "$pid" ]; then
        echo "🔪 Matando processo que segura o lock (PID: $pid)..."
        sudo kill -9 "$pid"
    else
        echo "✅ Nenhum processo segurando o lock do APT."
    fi

    echo "🧹 Removendo arquivos de lock..."
    sudo rm -f /var/lib/dpkg/lock-frontend
    sudo rm -f /var/lib/dpkg/lock

    echo "🔄 Reconfigurando pacotes pendentes..."
    sudo dpkg --configure -a

    echo "✅ Limpeza do APT concluída!"
}

limpando_apt

echo "📦 Instalando o Nginx..."
esperar_liberacao_apt
sudo apt install nginx -y || handle_error "ERRO AO INSTALAR O NGINX"

echo "🔧 Criando configuração do Nginx para fluxocerto.duckdns.org..."
sudo bash -c 'cat > /etc/nginx/sites-available/fluxocerto <<EOF
server {
    listen 80;
    server_name fluxocerto.duckdns.org;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF' || handle_error "ERRO AO CRIAR O ARQUIVO DE CONFIGURAÇÃO DO NGINX"

echo "🔗 Ativando o site e removendo o default..."
sudo ln -sf /etc/nginx/sites-available/fluxocerto /etc/nginx/sites-enabled/fluxocerto || handle_error "ERRO AO ATIVAR O SITE"
sudo rm -f /etc/nginx/sites-enabled/default || handle_error "ERRO AO REMOVER O SITE PADRÃO"

echo "🧪 Testando configuração do Nginx..."
sudo nginx -t || handle_error "CONFIGURAÇÃO INVÁLIDA DO NGINX"

echo "🔄 Reiniciando o Nginx..."
sudo systemctl restart nginx || handle_error "ERRO AO REINICIAR O NGINX"

echo "✅ Proxy reverso configurado com sucesso!"

# Mostrar o tempo total
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

echo ""
echo "⏱️ Tempo total de preparação do ambiente: ${ELAPSED_TIME} segundos."

echo ""
echo "==============================================================================="
echo ""

echo "Configurando as variáveis de ambiente AWS..."
if java -jar catch-tokens.jar; then
  echo "✅ Tokens AWS capturados com sucesso."
else
  echo "❌ Erro ao executar catch-tokens.jar."
  exit 1
fi

echo ""
echo "Adicionando as credenciais do banco de dados no arquivo aws_credentials.txt..."
if echo -e "\nexport DB_HOST=jdbc:mysql://localhost:3306/fluxoCerto\nexport DB_USERNAME=admin\nexport DB_PASSWORD=urubu100" >> aws_credentials.txt; then
  echo "✅ Credenciais do banco adicionadas ao arquivo."
else
  echo "❌ Erro ao adicionar credenciais ao arquivo."
  exit 1
fi

echo ""
echo "Enviando o arquivo com as credenciais para o container Java..."
if sudo docker cp aws_credentials.txt container-java:/home/aws_credentials.txt; then
  echo "✅ Arquivo copiado para o container com sucesso."
else
  echo "❌ Erro ao copiar arquivo para o container."
  exit 1
fi

echo ""
echo "Adicionando as credenciais no bashrc do container..."
if sudo docker exec container-java sh -c 'cat /home/aws_credentials.txt >> ~/.bashrc'; then
  echo "✅ bashrc atualizado com sucesso."
else
  echo "❌ Erro ao atualizar o bashrc no container."
  exit 1
fi

echo ""
echo "Atualizando o bashrc do container..."
if sudo docker exec container-java sh -c 'source ~/.bashrc'; then
  echo "✅ Variáveis carregadas no bashrc do container."
else
  echo "⚠️ Não foi possível aplicar as variáveis com source (isso é comum em exec)."
fi

echo ""
echo "✅ Variáveis de ambiente AWS e Banco de Dados configuradas com sucesso!"
echo ""

echo ""
echo "==============================================================================="
echo ""

