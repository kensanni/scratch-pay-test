resource "google_service_account" "app_cluster" {
  account_id = "application-cluster-service"
  display_name = "Application Cluster "
  project = data.google_project.app_cluster.project_id
}

resource "google_project_iam_member" "service-account" {
  for_each = toset(var.service_account_iam_roles)

  project  = data.google_project.app_cluster.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.app_cluster.email}"
}

resource "google_project_iam_member" "service-account-custom" {
  for_each = toset(var.service_account_custom_iam_roles)

  project  = data.google_project.app_cluster.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.app_cluster.email}"
}