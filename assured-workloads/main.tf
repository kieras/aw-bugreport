/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  default_suffix             = random_string.suffix.result
  aw_folder_name             = "${var.aw_name}-${local.default_suffix}"
  encryption_keys_project_id = "${var.aw_base_id}-kms-${local.default_suffix}"
  keyring_id                 = "${var.aw_base_id}-keyring-${local.default_suffix}"

  aw_consumer_folder_id = one(
    [for resource in google_assured_workloads_workload.primary.resources : resource.resource_id
    if resource.resource_type == "CONSUMER_FOLDER"]
  )
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "google_assured_workloads_workload" "primary" {
  provider = google-beta

  compliance_regime = var.aw_compliance_regime
  display_name      = local.aw_folder_name
  location          = var.aw_location
  organization      = var.org_id
  billing_account   = "billingAccounts/${var.billing_account}"

  provisioned_resources_parent = "folders/${var.folder_id}"

  resource_settings {
    resource_type = "CONSUMER_FOLDER"
    display_name  = local.aw_folder_name
  }

  resource_settings {
    resource_type = "ENCRYPTION_KEYS_PROJECT"
    resource_id   = local.encryption_keys_project_id
  }


  resource_settings {
    resource_type = "KEYRING"
    resource_id   = local.keyring_id
  }
}
