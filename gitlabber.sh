#!/bin/bash

# Set the target directory for the copied files
TARGET_DIR="../jack_bunny_gitlab"

# Function to copy files excluding specified paths
copy_files() {
    local branch_name=$1
    primary_repo=$(pwd)
    cd "${TARGET_DIR}"
    git checkout "${branch_name}"
    cd "${primary_repo}"
    rsync -av --progress . "${TARGET_DIR}" --exclude=".git" --exclude=".github"
}

# Get all branches
branches=$(git branch -r | grep -v '\->' | sed 's/.*origin\///')

# Iterate through each branch
for branch in $branches; do
  # Checkout the branch
  git checkout "$branch"

  # Copy files to the target directory
  echo "Copying files from branch $branch..."
  copy_files "$branch"

  # Prompt to investigate and commit
  echo "Files from branch '$branch' have been copied to '$TARGET_DIR/$branch'."
  echo "Please investigate the files."
  echo "When you are ready to commit and push to GitLab, navigate to the copied directory and use the following commands:"
  echo "cd $TARGET_DIR/$branch"
  echo "git init"
  echo "git remote add origin <gitlab-repo-url>"
  echo "git checkout -b $branch"
  echo "git add ."
  echo "git commit -m 'Initial commit from $branch branch'"
  echo "git push -u origin $branch"

  # Prompt user to continue to the next branch
  read -p "Press Enter to continue to the next branch..."
done

echo "All branches have been processed."
