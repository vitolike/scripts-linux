#!/bin/bash

# Gere uma senha aleatória de 10 caracteres para o novo usuário do MySQL
mysql_user_password=$(date +%s | sha256sum | base64 | head -c 10)

# Nome do usuário a ser criado
mysql_username="admin"

# Crie o usuário no MySQL
mysql -u root -p -e "CREATE USER '$mysql_username'@'%' IDENTIFIED WITH 'mysql_native_password' BY '$mysql_user_password';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$mysql_username'@'%' WITH GRANT OPTION;"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Atualize as configurações para permitir acesso remoto
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Reinicie o MySQL para aplicar as configurações
systemctl restart mysql

# Exiba um resumo
echo "Usuário MySQL 'admin' criado com a senha: $mysql_user_password"
echo "Acesso remoto ativado."
