# DroneGov ODM

Implementa um Servidor de Processamento de Imagens de Drones utilizando o **WebODM** (OpenDroneMap).

Este projeto orquestra os serviços do WebODM utilizando **Podman Quadlets**, permitindo uma integração nativa com o **systemd**. Isso garante que os containers sejam gerenciados como serviços do sistema operacional, oferecendo maior estabilidade, controle de dependências e inicialização automática no boot.

## 🏗️ Concepção e Arquitetura

Este projeto utiliza **Quadlets** nativos do Podman com uma rede dedicada, replicando a facilidade de comunicação do Docker Compose mas com a robustez do Systemd.

*   **Rede Dedicada (`webodm.network`):** Os serviços comunicam-se através de uma rede bridge isolada chamada `webodm-net`.
*   **Serviços:**
    *   **WebApp:** Interface web do WebODM.
    *   **Worker:** Processador de tarefas em background.
    *   **NodeODM:** Nó de processamento de imagens.
    *   **DB:** Banco de dados PostgreSQL.
    *   **Broker:** Redis para fila de mensagens.
*   **Comunicação:** Os containers resolvem uns aos outros pelos nomes de serviço (`db`, `broker`, `webapp`, etc.).
*   **Segurança:** Segredos (como `WO_SECRET_KEY`) são gerados automaticamente e armazenados em `/etc/webodm.env` com permissões restritas.

## 📋 Pré-requisitos

*   **Sistema Operacional:** Linux (Testado no Ubuntu 24.04 LTS).
*   **Podman:** Versão 4.4 ou superior (Recomendado 4.9+).
*   **Make:** Para automação da instalação.
*   **Git:** Para clonar o repositório.
*   **Diretórios de Dados:** O sistema espera que os seguintes diretórios existam para persistência:
    *   `/drone/db` (Banco de Dados)
    *   `/drone/media` (Imagens e Projetos)

## 🚀 Instalação

O projeto inclui um `Makefile` para facilitar a instalação e o gerenciamento dos arquivos Quadlet.

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/sandroklippel/dronegov-odm.git
    cd dronegov-odm
    ```

2.  **Prepare os diretórios de persistência:**
    ```bash
    sudo mkdir -p /drone/db /drone/media
    # Ajuste as permissões conforme necessário para o usuário do container (geralmente root no podman rootful ou usuário mapeado)
    ```

3.  **Instale os serviços:**
    Este comando copia os arquivos `.container` e `.network` para `/etc/containers/systemd/`, gera a chave secreta se não existir e recarrega o systemd.
    ```bash
    sudo make install
    ```

4.  **Inicie o serviço:**
    ```bash
    sudo make start
    ```

Acesse a interface web em: `http://seu-servidor/` (Porta 80).

## 🛠️ Gerenciamento

Utilize o `Makefile` para as operações do dia a dia:

| Comando | Descrição |
| :--- | :--- |
| `sudo make status` | Exibe o status do serviço no systemd e lista os containers ativos no Podman. |
| `sudo make logs` | Exibe os logs de todos os containers simultaneamente (tail -f). |
| `sudo make stop` | Para todos os serviços associados. |
| `sudo make restart` | Reinicia os serviços. Útil após alterações de configuração. |
| `sudo make uninstall` | Para os serviços e remove os arquivos de configuração do systemd. |

## 📂 Estrutura de Arquivos

*   `webodm.network`: Definição da rede isolada.
*   `webodm-*.container`: Definições individuais dos serviços (WebApp, Worker, DB, Broker, NodeODM).
*   `/etc/webodm.env`: Arquivo gerado na instalação contendo variáveis de ambiente sensíveis.
*   `/etc/containers/systemd/`: Local onde os Quadlets são instalados.

## 📝 Notas Importantes

*   **Segurança:** A chave `WO_SECRET_KEY` é gerada aleatoriamente na primeira instalação e salva em `/etc/webodm.env`. Se precisar invalidar sessões, edite este arquivo e reinicie o serviço.
*   **Backup:** Para fazer backup, pare o serviço (`sudo make stop`) e copie o diretório `/drone`.
*   **Logs:** Os logs são gerenciados pelo `journald`. Você pode acessá-los via `make logs` ou usando `journalctl -u webodm-webapp`, etc.
