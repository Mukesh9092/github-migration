terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "3.13.0"
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
}