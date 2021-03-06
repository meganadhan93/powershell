// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("Mega's cloud-81ed9b038d76.json")}"
 project     = "balmy-gearing-234015"
 region      = "us-west1"
}


// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default"  {
 name         = "mega${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "us-west1-a"


 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
}
}
