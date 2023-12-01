#!/bin/bash

# Verifique se o script está sendo executado como superusuário
if [ "$EUID" -ne 0 ]; then
  echo "Este script deve ser executado como superusuário (root)!"
  exit 1
fi

# Solicite ao usuário informações sobre o novo site
read -p "Digite o nome do site: " site_name
read -p "Digite o caminho absoluto do diretório raiz do site: " site_directory
read -p "Digite o domínio (URL) do site: " site_domain
read -p "Digite o seu endereço de e-mail para o Let's Encrypt: " email

# Verifique se o diretório raiz do site existe
if [ ! -d "$site_directory" ]; then
  echo "O diretório raiz do site não existe. Certifique-se de que o caminho seja válido."
  exit 1
fi

# Crie um arquivo de host virtual para o novo site
cat <<EOF > "/etc/apache2/sites-available/$site_name.conf"
<VirtualHost *:80>
    ServerAdmin webmaster@$site_domain
    ServerName $site_domain
    DocumentRoot $site_directory

    <Directory $site_directory>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

<VirtualHost *:443>
    ServerAdmin webmaster@$site_domain
    ServerName $site_domain
    DocumentRoot $site_directory

    <Directory $site_directory>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$site_domain/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$site_domain/privkey.pem

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Ative o novo site
a2ensite "$site_name"

# Solicite e instale o certificado Let's Encrypt
certbot --apache -d $site_domain --email $email

# Recarregue o Apache para aplicar as configurações
systemctl reload apache2

# Exiba uma mensagem de conclusão
echo "O site '$site_name' foi adicionado com sucesso ao Apache com suporte a SSL através do Let's Encrypt. Acesse em: https://$site_domain/"
