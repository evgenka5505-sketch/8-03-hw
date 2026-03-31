# Домашнее задание: «Кеширование Redis/Memcached»
**Беляева Евгения**

---

## Задание 1. Кеширование

**Кейс:**  
Необходимо ускорить отклик системы, уменьшить нагрузку на базу данных и решить проблемы задержек при повторных запросах.

**Ответ:**  
Кеширование решает следующие проблемы:

- Перегрузка основной БД при большом количестве повторяющихся запросов.
- Медленные вычисления или операции агрегации.
- Высокие задержки при частом получении одинаковых данных.
- Повышенная нагрузка на сторонние API.
- Необходимость ускорить работу микросервисов.
- Снижение времени генерации динамических страниц.
- Снижение сетевой нагрузки между сервисами.

---


## Задание 2. Memcached

### Установка и запуск Memcached

**Решение:**
Команда установки на Debian 10:

```bash
sudo apt install memcached libmemcached-tools -y
sudo systemctl enable memcached
sudo systemctl start memcached
systemctl status memcached
```
![Статус memcached](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/redis-2.png)
---

## Задание 3. Удаление по TTL в Memcached

### Запишите в memcached несколько ключей с любыми именами и значениями, для которых выставлен TTL 5.

### Приведите скриншот, на котором видно, что спустя 5 секунд ключи удалились из базы.

**Решение**
***Запись ключей через telnet:***
```bash
telnet localhost 11211
Trying ::1...
Connected to localhost.
Escape character is '^]'.
set key1 0 5 5
hello
STORED
get key1
VALUE key1 0 5
hello
END


***Проверка что ключи удалены после 5 секунд***
get key1
END
```
![Удаление по TTL](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/redis-3.png)

---

## Задание 4. Запись данных в Redis

### Запишите в Redis несколько ключей с любыми именами и значениями.

### Через redis-cli достаньте все записанные ключи и значения из базы, приведите скриншот этой операции.

**Решение**
Команды redis:

```bash
redis-cli
127.0.0.1:6379>
127.0.0.1:6379> SET key1 "hello"
OK
127.0.0.1:6379> SET name "Alex"
OK
127.0.0.1:6379> SET age "25"
OK
127.0.0.1:6379> SET city "London"
```
![Redis keys](https://github.com/evgenka5505-sketch/8-03-hw/blob/main/img/redis-4.png)

---

![Redis incrby](https://raw.githubusercontent.com/irbis36/FOPS-35-gitlab-hw/main/screenshots/task5-incrby.png)
---
