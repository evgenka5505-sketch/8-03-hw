# Дипломная работа по профессии «Системный администратор»

### Автор: Беляева Евгения

---

## Содержание

- [Задача](#задача)
- [Инфраструктура](#инфраструктура)
- [Сеть](#сеть)
- [Сайт](#сайт)
- [Мониторинг (Zabbix)](#мониторинг-zabbix)
- [Логи (Elasticsearch + Kibana)](#логи-elasticsearch--kibana)
- [Резервное копирование](#резервное-копирование)
- [Terraform-файлы проекта](#terraform-файлы-проекта)

---

## Задача

Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура размещается в Yandex Cloud.

---

## Инфраструктура

Для развёртки инфраструктуры использовались **Terraform** и **Ansible**.

| Инструмент | Версия |
|---|---|
| Yandex Cloud CLI | 1.16.0 |
| Terraform | 1.16.0 |
| Ansible | 2.10.7 |
| ОС рабочей станции | Windows 10 |
| ОС виртуальных машин | Ubuntu 22.04 LTS |

---

## Сеть

Развёрнут один VPC — `diplom-network`.

**Подсети:**

| Имя | Зона | CIDR | Тип |
|---|---|---|---|
| public-a | ru-central1-a | 192.168.10.0/24 | Публичная |
| public-b | ru-central1-b | 192.168.11.0/24 | Публичная |
| private-a | ru-central1-a | 192.168.20.0/24 | Приватная |
| private-b | ru-central1-b | 192.168.21.0/24 | Приватная |

Для исходящего доступа ВМ в приватных подсетях настроен **NAT-шлюз** и таблица маршрутизации.

**Bastion host** — ВМ с публичным IP (51.250.73.102), открыт только порт SSH (22). Используется как jump-host для доступа к ВМ в приватных подсетях. Ansible установлен непосредственно на bastion host.

**Облачные сети:**

![VPC](screenshots/Screenshot_2.png)

**Security Groups** настроены для каждого сервиса, ограничивая входящий трафик только нужными портами:

| Security Group | Входящие порты |
|---|---|
| bastion-sg | 22 (SSH) |
| web-sg | 80 (HTTP), 22 (SSH из публичной подсети), 10050 (Zabbix Agent) |
| zabbix-sg | 80 (Web UI), 10051 (Zabbix Server), 22 (SSH) |
| elastic-sg | 9200 (Elasticsearch), 22, 10050 |
| kibana-sg | 5601 (Kibana), 22, 10050 |
| alb-sg | 80, 443, healthchecks |

![Security Groups](screenshots/Screenshot_3.png)

---

## Виртуальные машины

Все ВМ: 2 ядра (20% Intel Ice Lake), 2–4 ГБ RAM, 10 ГБ HDD, Ubuntu 22.04 LTS, прерываемые.

| Имя | Зона | Подсеть | Публичный IP | Назначение |
|---|---|---|---|---|
| bastion | ru-central1-a | public-a | 51.250.73.102 | SSH jump host |
| web-1 | ru-central1-a | private-a | — | Веб-сервер nginx |
| web-2 | ru-central1-b | private-b | — | Веб-сервер nginx |
| zabbix | ru-central1-a | public-a | 89.169.154.238 | Мониторинг Zabbix |
| elastic | ru-central1-a | private-a | — | Elasticsearch |
| kibana | ru-central1-a | public-a | 51.250.78.121 | Kibana |

![Виртуальные машины](screenshots/Screenshot_1.png)

---

## Сайт

Созданы две ВМ (`web-1`, `web-2`) в разных зонах доступности в приватных подсетях. На обеих установлен **nginx** с помощью Ansible.

### Балансировщик нагрузки (ALB)

- **Target Group** — включены web-1 (192.168.20.16) и web-2 (192.168.21.34)
- **Backend Group** — healthcheck на `/`, порт 80, протокол HTTP
- **HTTP Router** — маршрут `/` → backend group
- **Application Load Balancer** — listener на порт 80, публичный IP: 158.160.216.69

![ALB](screenshots/Screenshot_13.png)

### Проверка работоспособности

```
curl -v http://158.160.216.69:80
```

![curl ALB](screenshots/Screenshot_4.png)

Балансировщик работает, распределяет трафик между web-1 и web-2.

---

## Мониторинг (Zabbix)

На ВМ `zabbix` (89.169.154.238) развёрнут **Zabbix Server 7.0.27** + Frontend (Apache) + PostgreSQL.

Доступ к веб-интерфейсу: http://89.169.154.238/zabbix

### Установка Zabbix

![Zabbix Setup](screenshots/Screenshot_5.png)

### Главный дашборд

![Zabbix Global Dashboard](screenshots/Screenshot_6.png)

### Хосты с Zabbix Agent

На все ВМ установлен **Zabbix Agent** с помощью Ansible. Агенты настроены на отправку метрик на Zabbix Server (192.168.10.25). Все хосты используют шаблон `Linux by Zabbix agent`.

| Хост | IP | Статус |
|---|---|---|
| web-1 | 192.168.20.16 | ZBX ✅ |
| web-2 | 192.168.21.34 | ZBX ✅ |
| elastic | 192.168.20.25 | ZBX ✅ |
| kibana | 192.168.10.19 | ZBX ✅ |
| Zabbix server | 127.0.0.1 | ZBX ✅ |

![Zabbix Hosts](screenshots/Screenshot_7.png)

### Дашборд USE Metrics

Настроен дашборд с отображением метрик по принципу USE для веб-серверов:

- **CPU utilization** (web-1, web-2)
- **Memory utilization** (web-1, web-2)
- **Network traffic** — Bits received/sent (web-1, web-2)
- **Disk space usage** — FS [/] Space Used (web-1, web-2)

![USE Metrics Dashboard](screenshots/Screenshot_8.png)

### Triggers / Thresholds

Триггеры настроены через шаблон `Linux by Zabbix agent` и включают пороговые значения для CPU, RAM, дисков, сети, файловой системы.

![Zabbix Triggers](screenshots/Screenshot_9.png)

---

## Логи (Elasticsearch + Kibana)

### Elasticsearch

На ВМ `elastic` (192.168.20.25, приватная подсеть) развёрнут **Elasticsearch 8.19.18** в режиме single-node.

```json
{
  "name" : "elastic",
  "cluster_name" : "diplom-cluster",
  "version" : { "number" : "8.19.18" }
}
```

### Filebeat

На веб-серверах (`web-1`, `web-2`) установлен **Filebeat 8.19.18**, настроен на отправку:

- `/var/log/nginx/access.log`
- `/var/log/nginx/error.log`

Логи отправляются в Elasticsearch в индекс `filebeat-*`.

### Kibana

На ВМ `kibana` (51.250.78.121) развёрнута **Kibana 8.19.18**, подключена к Elasticsearch (192.168.20.25:9200).

Доступ к веб-интерфейсу: http://51.250.78.121:5601

![Kibana Welcome](screenshots/Screenshot_10.png)

### Kibana Discover — логи nginx

Создан Data View `filebeat-*`. В Discover отображаются логи nginx access и error с обоих веб-серверов (2362 документа).

![Kibana Discover](screenshots/Screenshot_11.png)

---

## Резервное копирование

Настроено ежедневное создание **snapshot** дисков всех 6 ВМ по расписанию:

- **Время**: каждый день в 03:00 UTC
- **Хранение**: последние 7 снимков (неделя)
- **Диски**: bastion, web-1, web-2, zabbix, elastic, kibana

![Snapshot Schedule](screenshots/Screenshot_12.png)

---

## Terraform-файлы проекта

| Файл | Описание |
|---|---|
| main.tf | Провайдер Yandex Cloud |
| network.tf | VPC, подсети, NAT-шлюз, таблица маршрутизации |
| security.tf | Security Groups для всех сервисов |
| vms.tf | Виртуальные машины (6 шт.) |
| alb.tf | Target Group, Backend Group, HTTP Router, ALB |
| snapshots.tf | Расписание снимков дисков |
| outputs.tf | Выходные данные (IP-адреса) |

## Выходные данные Terraform

```
bastion_public_ip   = "51.250.73.102"
zabbix_public_ip    = "89.169.154.238"
kibana_public_ip    = "51.250.78.121"
alb_public_ip       = "158.160.216.69"
web1_internal_ip    = "192.168.20.16"
web2_internal_ip    = "192.168.21.34"
elastic_internal_ip = "192.168.20.25"
```

## Ansible-плейбуки

| Плейбук | Описание |
|---|---|
| nginx.yml | Установка nginx на web-1 и web-2 |
| zabbix.yml | Установка Zabbix Server + Frontend + PostgreSQL |
| zabbix-db.yml | Создание БД и импорт схемы Zabbix |
| zabbix-agents.yml | Установка Zabbix Agent на все ВМ |
| elastic.yml | Установка и настройка Elasticsearch |
| kibana.yml | Установка и настройка Kibana |
| filebeat.yml | Установка Filebeat на веб-серверы |

---

## Доступ к ресурсам

| Ресурс | URL |
|---|---|
| Сайт (ALB) | http://158.160.216.69 |
| Zabbix | http://89.169.154.238/zabbix (Admin / zabbix) |
| Kibana | http://51.250.78.121:5601 |

