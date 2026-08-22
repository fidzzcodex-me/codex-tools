#!/bin/bash

setup_git_repo() {
  [ "$USER_UPLOAD" = "true" ] && return 0
  [ -z "$GIT_ADDRESS" ] && return 0

  local repo_url="$GIT_ADDRESS"
  if [ -n "$USERNAME" ] && [ -n "$ACCESS_TOKEN" ]; then
    repo_url=$(echo "$GIT_ADDRESS" | sed "s#https://#https://${USERNAME}:${ACCESS_TOKEN}@#")
  fi

  if [ ! -d ".git" ]; then
    echo -e "${C_SKY}[git] Cloning repository...${C_RESET}"
    local branch_flag=""
    [ -n "$BRANCH" ] && branch_flag="-b $BRANCH"
    git clone $branch_flag "$repo_url" temp_clone 2>&1 | grep -v "$ACCESS_TOKEN"
    local clone_status="${PIPESTATUS[0]}"
    if [ "$clone_status" -ne 0 ] || [ ! -d "temp_clone" ]; then
      ui_err "[git] Clone gagal (exit ${clone_status}). Cek GIT_ADDRESS/USERNAME/ACCESS_TOKEN/BRANCH di panel -- container tetap kosong."
      rm -rf temp_clone
      return 1
    fi
    shopt -s dotglob
    mv temp_clone/* . 2>/dev/null
    rm -rf temp_clone
    shopt -u dotglob
    ui_ok "[git] Clone selesai"
  elif [ "$AUTO_UPDATE" = "true" ]; then
    echo -e "${C_SKY}[git] Pulling latest changes...${C_RESET}"
    git pull 2>&1 | grep -v "$ACCESS_TOKEN"
    local pull_status="${PIPESTATUS[0]}"
    [ "$pull_status" -ne 0 ] && ui_err "[git] Pull gagal (exit ${pull_status})"
  fi
}
