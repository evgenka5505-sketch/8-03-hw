# VPC
resource "yandex_vpc_network" "diplom" {
  name = "diplom-network"
}

# Публичная подсеть - зона A
resource "yandex_vpc_subnet" "public-a" {
  name           = "public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Публичная подсеть - зона B
resource "yandex_vpc_subnet" "public-b" {
  name           = "public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

# NAT-шлюз для приватных подсетей
resource "yandex_vpc_gateway" "nat-gw" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

# Таблица маршрутизации через NAT
resource "yandex_vpc_route_table" "nat-route" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.diplom.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gw.id
  }
}

# Приватная подсеть - зона A
resource "yandex_vpc_subnet" "private-a" {
  name           = "private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.nat-route.id
}

# Приватная подсеть - зона B
resource "yandex_vpc_subnet" "private-b" {
  name           = "private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["192.168.21.0/24"]
  route_table_id = yandex_vpc_route_table.nat-route.id
}