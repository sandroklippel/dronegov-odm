# Makefile para gerenciamento dos Quadlets do WebODM

SYSTEMD_DIR = /etc/containers/systemd
SECRET_FILE = /etc/webodm.env

# Lista de arquivos Quadlet
QUADLET_FILES = webodm.network \
                webodm-db.container \
                webodm-broker.container \
                webodm-webapp.container \
                webodm-worker.container \
                webodm-nodeodm.container

.PHONY: all install generate-secret start stop restart status uninstall logs

all: install start

generate-secret:
	@if [ ! -f $(SECRET_FILE) ]; then \
		echo "Gerando nova chave secreta em $(SECRET_FILE)..."; \
		echo "WO_SECRET_KEY=$$(tr -dc 'A-Za-z0-9!@#%^&*()_+=' < /dev/urandom | head -c 50)" > $(SECRET_FILE); \
		chmod 600 $(SECRET_FILE); \
	else \
		echo "Arquivo de segredo já existe em $(SECRET_FILE). Mantendo o atual."; \
	fi

install: generate-secret
	@echo "Instalando arquivos Quadlet em $(SYSTEMD_DIR)..."
	install -m 644 $(QUADLET_FILES) $(SYSTEMD_DIR)/
	systemctl daemon-reload
	@echo "Arquivos instalados. Execute 'make start' para iniciar o pod."

start:
	@echo "Iniciando os serviços do WebODM..."
	systemctl start webodm-db webodm-broker webodm-worker webodm-webapp webodm-nodeodm

stop:
	@echo "Parando os serviços do WebODM..."
	systemctl stop webodm-webapp webodm-worker webodm-nodeodm webodm-db webodm-broker

restart:
	@echo "Reiniciando o WebODM..."
	systemctl restart webodm-webapp

status:
	@echo "--- Status do Systemd ---"
	systemctl status webodm-webapp --no-pager || true
	@echo ""
	@echo "--- Status dos Containers (Podman) ---"
	podman ps --filter network=webodm-net

logs:
	journalctl -f -u webodm-webapp -u webodm-worker -u webodm-nodeodm -u webodm-db -u webodm-broker

uninstall: stop
	@echo "Removendo arquivos Quadlet..."
	cd $(SYSTEMD_DIR) && rm -f $(QUADLET_FILES)
	systemctl daemon-reload
	@echo "Desinstalação completa."