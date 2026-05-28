#!/bin/bash
# 一鍵部署到 GitHub Pages
# 前置：先 `gh auth login`
set -e
REPO="japan-trip"
cd "$(dirname "$0")"

# 取 gh user
USER=$(gh api user --jq .login)
echo "用 GitHub 帳號：$USER"

# init git 若沒
if [ ! -d .git ]; then
  git init -b main
fi

git add -A
git commit -m "update trip" 2>/dev/null || echo "(無變更可 commit)"

# 建 repo（已存在則略過）
if ! gh repo view "$USER/$REPO" >/dev/null 2>&1; then
  echo "建立 repo $USER/$REPO"
  gh repo create "$USER/$REPO" --public --source=. --push
else
  echo "repo 已存在，push"
  git remote add origin "git@github.com:$USER/$REPO.git" 2>/dev/null || true
  git push -u origin main
fi

# 啟用 Pages（main / root）
echo "啟用 GitHub Pages..."
gh api -X POST "/repos/$USER/$REPO/pages" \
  -f "source[branch]=main" -f "source[path]=/" 2>/dev/null \
  || echo "(Pages 可能已啟用)"

URL="https://$USER.github.io/$REPO/"
echo ""
echo "🎉 完成"
echo "Pages URL：$URL"
echo "（首次部署約 1-2 分鐘生效）"
