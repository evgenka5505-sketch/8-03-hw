variable "image_id" {
  default = "fd8pbob4usfj6c497ape"
}

# Bastion Host
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("id_ed25519.pub")}"
  }
}

# Web-1 (зона A, приватная)
resource "yandex_compute_instance" "web-1" {
  name        = "web-1"
  hostname    = "web-1"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-a.id
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("id_ed25519.pub")}"
  }
}

# Web-2 (зона B, приватная)
resource "yandex_compute_instance" "web-2" {
  name        = "web-2"
  hostname    = "web-2"
  zone        = "ru-central1-b"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-b.id
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("id_ed25519.pub")}"
  }
}

# Zabbix (публичная)
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.zabbix-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("id_ed25519.pub")}"
  }
}

# Elasticsearch (приватная)
resource "yandex_compute_instance" "elastic" {
  name        = "elastic"
  hostname    = "elastic"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-a.id
    security_group_ids = [yandex_vpc_security_group.elastic-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("id_ed25519.pub")}"
  }
}

# Kibana (публичная)
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kibana-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("id_ed25519.pub")}"
  }
}
