# Домашнее задание RabbitMQ

**Беляева Евгения Олеговна**

---

## Задание 1. Установка RabbitMQ

**Решение**  
Установлен RabbitMQ, включён management plugin, выполнен вход в веб‑интерфейс.

**Скриншот веб‑интерфейса (вставьте сюда):**
![RabbitMQ](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/rabbit-1.png)

---

## Задание 2. Отправка и получение сообщений

**Решение**  
Настроены скрипты *producer.py* и *consumer.py*, IP заменён на нужный.  
Сообщение отправлено и получено успешно.

скрипт producer.py:
```
import pika

# Укажите IP вашего RabbitMQ-сервера
rabbitmq_host = '192.168.10.126'
queue_name = 'hello'

# Устанавливаем соединение с RabbitMQ, используя нового пользователя
connection = pika.BlockingConnection(pika.ConnectionParameters(
    host=rabbitmq_host,
    credentials=pika.PlainCredentials('admin', 'admin')  # используем нового пользователя
))
channel = connection.channel()

# Создаём очередь, если её ещё нет
channel.queue_declare(queue=queue_name)

# Отправляем сообщение в очередь
message = 'Hello, RabbitMQ!'  # сообщение для отправки
channel.basic_publish(exchange='',
                      routing_key=queue_name,
                      body=message)

print(f" [x] Sent '{message}'")

# Закрываем соединение
connection.close()
```

**Скрин очереди hello:**  
![hello](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/rabbit-2.1.png)

скрипт consumer.py:

```
import pika

# Укажите IP вашего RabbitMQ-сервера
rabbitmq_host = '192.168.10.126'
queue_name = 'hello'

# Устанавливаем соединение с RabbitMQ, используя нового пользователя
connection = pika.BlockingConnection(pika.ConnectionParameters(
    host=rabbitmq_host,
    credentials=pika.PlainCredentials('admin', 'admin')  # используем нового пользователя
))
channel = connection.channel()

# Создаём очередь, если её ещё нет
channel.queue_declare(queue=queue_name)

# Определяем функцию обработки полученного сообщения
def callback(ch, method, properties, body):
    print(f" [x] Received {body}")

# Подписываемся на очередь и начинаем ожидать сообщений
channel.basic_consume(queue=queue_name, on_message_callback=callback, auto_ack=True)

print(' [*] Waiting for messages. To exit press Ctrl+C')
channel.start_consuming()
```

**Скрин результата consumer.py:**  
![consymer.py](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/rabbit-2.2.png)

---

## Задание 3. Подготовка HA кластера

Машины:

- rmq01 — 192.168.10.126  
- rmq02 — 192.168.10.127

**Решение**  
- Обе ноды установлены.  
- /etc/hosts настроен.  
- Кластер объединён.  
- Политика ha-all создана.


**Скрин политики ha-all:**  
![ha-all](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/rabbit-3.1.png)

---

### Вывод cluster_status (вставить для каждой ноды)

```bash
belyaeva@rmq01:~$ sudo rabbitmqctl cluster_status
Cluster status of node rabbit@rmq01 ...
Basics

Cluster name: rabbit@rmq01

Disk Nodes

rabbit@rmq01
rabbit@rmq02

Running Nodes

rabbit@rmq01

Versions

rabbit@rmq01: RabbitMQ 3.8.2 on Erlang 22.2.7

Alarms

(none)

Network Partitions

(none)

Listeners

Node: rabbit@rmq01, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Node: rabbit@rmq01, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
Node: rabbit@rmq01, interface: [::], port: 15672, protocol: http, purpose: HTTP API

Feature flags

Flag: drop_unroutable_metric, state: enabled
Flag: empty_basic_get_metric, state: enabled
Flag: implicit_default_bindings, state: enabled
Flag: quorum_queue, state: enabled
Flag: virtual_host_metadata, state: enabled
```

```bash
belyaeva@rmq02:~$ sudo rabbitmqctl cluster_status
Cluster status of node rabbit@rmq02 ...
Basics

Cluster name: rabbit@rmq01

Disk Nodes

rabbit@rmq01
rabbit@rmq02

Running Nodes

rabbit@rmq01
rabbit@rmq02

Versions

rabbit@rmq01: RabbitMQ 3.8.2 on Erlang 22.2.7
rabbit@rmq02: RabbitMQ 3.8.2 on Erlang 22.2.7

Alarms

(none)

Network Partitions

(none)

Listeners

Node: rabbit@rmq01, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Node: rabbit@rmq01, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
Node: rabbit@rmq01, interface: [::], port: 15672, protocol: http, purpose: HTTP API
Node: rabbit@rmq02, interface: [::], port: 25672, protocol: clustering, purpose: inter-node and CLI tool communication
Node: rabbit@rmq02, interface: [::], port: 5672, protocol: amqp, purpose: AMQP 0-9-1 and AMQP 1.0
Node: rabbit@rmq02, interface: [::], port: 15672, protocol: http, purpose: HTTP API

Feature flags

Flag: drop_unroutable_metric, state: enabled
Flag: empty_basic_get_metric, state: enabled
Flag: implicit_default_bindings, state: enabled
Flag: quorum_queue, state: enabled
Flag: virtual_host_metadata, state: enabled

```


---

### Проверка очереди командой rabbitmqadmin get queue='hello'

**Скрин с rmq01:**  
![rmq](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/rabbit-3.png)

---
