resource "gitlab_project" "migrated_projects" {
  namespace_id         = var.gitlab_group_id
  visibility_level     = "private"
  initialize_with_readme = true
}

resource "null_resource" "migrate_repos" {
  provisioner "local-exec" {
    command = <<EOT
GITHUB_ORG="${var.github_org}"
GITLAB_GROUP_ID="${var.gitlab_group_id}"
GITHUB_TOKEN="${var.github_token}"
GITLAB_TOKEN="${var.gitlab_token}"
REPOSITORIES=$(echo '${jsonencode(var.repositories)}' | jq -r '.[]')
RELEASE_TAG="${var.release_tag}"

# Function to migrate a single repository
migrate_repo() {
  REPO=$(echo $1 | xargs)  # Trim spaces
  echo "Migrating repository $REPO..."

  echo https://github.com/$GITHUB_ORG/$REPO/archive/refs/tags/$RELEASE_TAG.zip

  # Check if the directory already exists and remove it if it does
  if [ -d "$REPO.git" ]; then
    rm -rf $REPO.git
  fi

  # Clone the GitHub repository as a bare repository (without working directory)
  #git clone --bare "https://$GITHUB_TOKEN@github.com/$GITHUB_ORG/$REPO.git"

  # Download the specified release as a zip file from GitHub
  curl -L -H "Authorization: token GITHUB_TOKEN" -o $REPO.zip https://github.com/$GITHUB_ORG/$REPOSITORIES/archive/refs/tags/v$RELEASE_TAG.zip
  #curl -L -o $REPO.zip https://github.com/$GITHUB_ORG/$REPO/archive/refs/tags/v$RELEASE_TAG.zip

# Unzip the downloaded file
  unzip $REPO.zip

  # Extracted folder name (assumes it's the same as the repo name followed by the release tag)
  EXTRACTED_FOLDER="$REPO-$RELEASE_TAG"

  # Navigate into the extracted folder
  cd $EXTRACTED_FOLDER

  # Initialize a new Git repository
  git init
  git remote add origin https://oauth2:$GITLAB_TOKEN@gitlab.com/$GITLAB_GROUP_ID/$REPO.git

  # Add and commit the files
  git add .
  git commit -m "Initial commit from GitHub release $RELEASE_TAG"

  # Push the code to GitLab
  git push -u origin master

  # Return to the previous directory
  cd ..

  # Clean up
  rm -rf $EXTRACTED_FOLDER $REPO.zip

  # Create a new repository in GitLab using the correct namespace ID
  #curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" -X POST "https://gitlab.com/api/v4/projects?name=$REPO&namespace_id=$GITLAB_GROUP_ID"

  echo "Repository $REPO migrated successfully!"
}

# Iterate over each repository in the list and migrate it
for REPO in $REPOSITORIES; do
  migrate_repo $REPO
done
EOT
    interpreter = ["bash", "-c"]
  }

  depends_on = [gitlab_project.migrated_projects]
}
