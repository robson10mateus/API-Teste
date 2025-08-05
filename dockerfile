FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Instala Wine
RUN dpkg --add-architecture i386 && \
    apt update && \
    apt install -y wine64 wine32 curl unzip

# Cria pasta do app
WORKDIR /app

# Copia a API Delphi para o container
COPY server.exe /app/server.exe
COPY start.sh /app/start.sh

# Permissão de execução
RUN chmod +x /app/start.sh

# Expõe a porta 8080 (ou a porta que sua API usar)
EXPOSE 9000

# Comando de inicialização
CMD ["/app/start.sh"]
