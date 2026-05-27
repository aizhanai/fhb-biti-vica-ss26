# Ruft die Template-ID für das aktuelle Ubuntu 22.04 LTS Image ab
data "exoscale_compute_template" "ubuntu" {
  zone = var.zone
  name = "Linux Ubuntu 22.04 LTS 64-bit"
}

# Erstellt die Firewall-Sicherheitsgruppe für die VM
resource "exoscale_security_group" "web_sg" {
  name        = "vica-web-sg"
  description = "Erlaubt eingehenden Traffic für SSH und HTTP"
}

# Firewall-Regel: Erlaubt Web-Traffic auf Port 80 (HTTP)
resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

# Firewall-Regel: Erlaubt SSH-Zugriff auf Port 22 für Administration
resource "exoscale_security_group_rule" "ssh" {
  security_group_id = exoscale_security_group.web_sg.id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 22
  end_port          = 22
}

# Instanziiert die eigentliche virtuelle Maschine bei Exoscale
resource "exoscale_compute_instance" "web_vm" {
  zone               = var.zone
  name               = "aizhan-vica-vm"
  template_id        = data.exoscale_compute_template.ubuntu.id
  type               = "standard.medium"
  security_group_ids = [exoscale_security_group.web_sg.id]

  # Cloud-Init Konfiguration wird hier direkt als Datei mitgegeben
  user_data = file("${path.module}/cloud-init.yaml")
}

# Gibt die IP-Adresse nach dem automatischen Setup im GitHub Log aus
output "vm_public_ip" {
  value       = exoscale_compute_instance.web_vm.public_ip_address
  description = "Die öffentliche IP-Adresse der erstellten Exoscale VM"
}
