provider "vault" {
    address = "http://127.0.0.1:8200"
    token = "s.pAdCs2Dhzj9V7ETgIFgNXt5z"
  
}
resource "vault_pki_secret_backend" "pki" {
  path = "pki_int"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds = 86400
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on = [ vault_pki_secret_backend.pki ]

  backend = vault_pki_secret_backend.pki.path
  format = "pem_bundle"
  type = "internal"
  common_name = "app.my.domain"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "root" {
  depends_on = [ vault_pki_secret_backend_intermediate_cert_request.intermediate ]

  backend = "pki"

  csr = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  format = "pem_bundle"
  common_name = "Intermediate CA"
  exclude_cn_from_sans = true
  ou = "My OU"
  organization = "My organization"
}

data "vault_generic_secret" "root_ca_chain" {
  path = "pki_int/cert/ca_chain" 
}

output "ca_chain_test" {
  value = data.vault_generic_secret.root_ca_chain.data.certificate
}