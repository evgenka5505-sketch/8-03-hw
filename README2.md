# Домашнее задание к занятию «Система мониторинга Zabbix»

**Беляева Евгения Олеговна**

---

## Задание 1


Установите Zabbix Server с веб-интерфейсом.

### Результат выполнения

![Скриншот авторизации в админке zabbix](z1.png)
![Вход в админку zabbix](z2.png)

---
### Текст использованных команд

#### 1. Установите репозиторий Zabbix

```bash
wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb
dpkg -i zabbix-release_latest_7.4+debian13_all.deb
apt update

#### 2. Установка zabbix сервера, веб-интерфейса и агента

```bash
apt install zabbix-server-pgsql zabbix-frontend-php php8.4-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent

#### 3. Создаем базу данных
##### 3.1 Устанавливаем и запускаем PostgreSQL

```bash 
apt install postgresql postgresql-contrib
systemctl enable postgresql
systemctl start postgresql

##### 3.2 Создаем пользователя и базу данных

```bash
su - postgres -c "psql --command \"CREATE USER zabbix WITH PASSWORD '123456789';\""
su - postgres -c "psql --command \"CREATE DATABASE zabbix OWNER zabbix;\""

##### 3.3 Ипортируем начальную схему и данные на хосте Zabbix сервера

```bash
zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

#### 4. Настраиваем базу данных для Zabbix сервера

Отредактируем конфигурационных файл:

```bash
sed -i 's/# DBPassword=/DBPassword=123456789/' /etc/zabbix/zabbix_server.conf

#### 5. Запускаем процессы Zabbix сервера и агента

```bash
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
systemctl status zabbix-server.service

---


## Задание 2

Установите Zabbix Agent на два хоста.

### Результат выполнения

