resource "google_compute_instance" "bla" {
  name         = "${var.instance_name}-bla-vm"
  machine_type = "e2-standard-2"
  zone         = "${var.region}-${var.zone}"
  project      = var.project
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }
  metadata = {
    gce-container-declaration = "spec:\n  containers:\n    - name: bla-instance-container\n      image: europe-west3-docker.pkg.dev/bla-bla-bla/images/container:latest\n      stdin: false\n      tty: false\n  restartPolicy: Always\n\n# This container declaration format is not public API and may change without notice. Please\n# use gcloud command-line tool or Google Cloud Console to run Containers on Google Compute Engine."
    google-logging-enabled    = "true"
  }

  network_interface {
    subnetwork         = var.subnet
    subnetwork_project = var.host-project
    network_ip         = google_compute_address.bla.address
  }

  service_account {
    email  = google_service_account.bla.email
    scopes = ["cloud-platform"]
  }
}

 