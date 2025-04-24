# Usa a imagem oficial do Node.js
FROM node:latest

# Instala o Git dentro do container (necessário para o clone)
RUN apt-get update && apt-get install -y git

# Define o diretório de trabalho dentro do container
WORKDIR /usr/src/app

# Clona o repositório diretamente no container
RUN git clone https://github.com/FaelPavani/FluxoCerto .

# Atualiza o repositório para garantir que temos a versão mais recente
RUN git pull

# Copia o arquivo .env para a pasta public dentro do projeto
COPY .env ./public/.env

# Instala as dependências do projeto
RUN npm install

# Exponha a porta usada pela aplicação (modifique se necessário)
EXPOSE 8080

# Define o comando padrão para iniciar a aplicação
CMD ["npm", "start"]