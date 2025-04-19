# Fluxo Certo - Script de Execução

Este repositório faz parte do projeto **Fluxo Certo** e contém um Shell Script para facilitar a execução e inicialização do ambiente do projeto de forma automatizada.

## 📜 Sobre o Script

O objetivo deste script é:

- Automatizar o processo de inicialização do projeto Fluxo Certo
- Garantir que todas as dependências estejam instaladas corretamente
- Rodar os serviços necessários (como servidores, banco de dados, etc.)
- Fornecer uma maneira rápida e padronizada de subir o ambiente local

## 🚀 Como usar

### Pré-requisitos

Antes de executar o script, certifique-se de que você possui:

- Linux ou WSL no Windows (ambiente Unix-like)
- Permissões para executar scripts `.sh`
- Dependências básicas como: `bash`, `curl`, `git`, `docker`, etc.

### Passo a passo

1 - Criando o repositório:

1.1 Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/fluxo-certo-script.git
   cd fluxo-certo-script
   ```
   
1.2 Dê permissão de execução ao script:

```bash
chmod +x executar.sh
```

1.3 Execute o script:

```bash
./executar.sh
```

2 - Configurar as variáveis de ambiente dentro da sua instância EC2:

2.1 Acesse o bashrc da sua instância:
```bash
nano ~/.bashrc
```

2.2 Edite ele configurando as chaves de acesso:
```bash
export AWS_ACCESS_KEY_ID=suachavedeacesso...
export AWS_SECRET_ACCESS_KEY=suachavedeacesso...
export AWS_SESSION_TOKEN=suachavedeacesso...                                         
```

2.3 Salve as alterações:

CTRL O + Enter + CTRL X

