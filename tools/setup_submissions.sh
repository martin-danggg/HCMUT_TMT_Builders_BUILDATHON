#!/usr/bin/env bash
# Tạo 3 repo nộp bài (P1, P2, P4) trong pX_.../submission/<tên-repo>/ từ starter của BTC,
# commit "Setup: add requirements" và push lên nhánh main.
# Chạy trong Git Bash hoặc WSL, từ bất kỳ đâu:  bash tools/setup_submissions.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OWNER="martin-danggg"
HOST="github-personal"          # alias SSH trong ~/.ssh/config
MSG="Setup: add requirements"
REMOTE_BASE="${REMOTE_BASE:-git@$HOST:$OWNER}"   # chỉ đổi khi chạy thử

clone_repo() {                  # $1 = thư mục problem, $2 = tên repo
  local dir="$ROOT/$1/submission/$2"
  mkdir -p "$ROOT/$1/submission"
  if [ -d "$dir/.git" ]; then
    echo ">> $2: đã có $dir, bỏ qua clone"
  else
    git clone "$REMOTE_BASE/$2.git" "$dir"
  fi
  # Repo rỗng: đảm bảo nhánh hiện tại là main
  git -C "$dir" symbolic-ref HEAD refs/heads/main
}

is_set_up() {                   # repo đã có commit -> không chép đè starter
  git -C "$ROOT/$1/submission/$2" rev-parse -q --verify HEAD >/dev/null 2>&1
}

commit_push() {                 # $1 = thư mục problem, $2 = tên repo
  local dir="$ROOT/$1/submission/$2"
  git -C "$dir" add -A
  if git -C "$dir" diff --cached --quiet; then
    echo ">> $1: không có gì mới để commit"
  else
    git -C "$dir" commit -m "$MSG"
  fi
  git -C "$dir" push -u origin main
  echo ">> $1: $(git -C "$dir" rev-parse HEAD)"
}

# ---------------------------------------------------------------- P1
P=p1_Builders; R=hcmut-tmt-p1-mech-royale
clone_repo "$P" "$R"
if is_set_up "$P" "$R"; then echo ">> $R: đã có commit, không chép lại starter"; else
K="$ROOT/$P/starter_files/mechfight-kit"
[ -d "$K/python" ] || K="$K/mechfight-kit"          # hỗ trợ cả bố cục cũ
D="$ROOT/$P/submission/$R"
mkdir -p "$D/check" "$D/arena/v2" "$D/docs"
cp "$K/python/mechfight.py" "$D/mechfight.py"
sed 's/name = "example-py"/name = "hcmut-tmt"/' "$K/python/example_bot.py" > "$D/bot.py"
cp "$K/check/check.py" "$K/check/stream.jsonl.gz" "$D/check/"
cp "$K/arena/v2/world.json" "$K/arena/v2/terrain.i16" "$D/arena/v2/"
cp "$K/protocol.md" "$D/docs/"
cp "$K/mechfight.schema.json" "$D/mechfight.schema.json"   # check.py đọc file này ở gốc
cat > "$D/Dockerfile" <<'EOF'
# Built by the organisers on linux/amd64. At run time: no network, read-only root
# (writable /tmp, 64 MB), 1 CPU, 512 MB, uid 65534, map mounted read-only at /arena.
FROM python:3.13-slim
WORKDIR /bot
COPY . .
ENTRYPOINT ["python3", "-u", "/bot/bot.py"]
EOF
cat > "$D/.dockerignore" <<'EOF'
.git
check/
arena/
docs/
mechfight.schema.json
**/__pycache__
EOF
cat > "$D/.gitignore" <<'EOF'
__pycache__/
*.pyc
.venv/
EOF
cat > "$D/README.md" <<'EOF'
# HCMUT TMT – Mech Royale bot

Builders Buildathon 2026, track **Builders – Mech Royale**. Team HCMUT TMT.

- `bot.py` – the bot (entry point), `mechfight.py` – protocol wrapper from the kit.
- `check/` – the kit's conformance check, `arena/v2/` – the map (the scorer mounts its own copy at `/arena`).
- `docs/protocol.md` and `mechfight.schema.json` – the protocol spec and schema from the kit.

## Local check

```bash
python3 check/check.py -- python3 -u bot.py
docker build -t hcmut-tmt-mech .
python3 check/check.py --map-dir /arena -- docker run --rm -i --network none --cpus 1 \
  --memory 512m --read-only --tmpfs /tmp:size=64m -v "$PWD/arena:/arena:ro" hcmut-tmt-mech
```
EOF
commit_push "$P" "$R"
fi

# ---------------------------------------------------------------- P2
P=p2_Databricks; R=hcmut-tmt-p2-shopping-sessions
clone_repo "$P" "$R"
if is_set_up "$P" "$R"; then echo ">> $R: đã có commit, không chép lại starter"; else
S="$ROOT/$P/starter_files/starter-duckdb"
[ -d "$S" ] || S="$ROOT/$P/starter-duckdb/starter-duckdb"   # bố cục cũ
D="$ROOT/$P/submission/$R"
cp -r "$S"/. "$D"/
cat > "$D/TEAM.md" <<'EOF'
# Team

Name: HCMUT TMT
Members: Dang Minh Triet
Engine: DuckDB
EOF
cat > "$D/.gitignore" <<'EOF'
# Data never goes in the repo (the dataset is mounted at run time)
dev/
dev-answer/
out/
*.parquet
__pycache__/
*.pyc
.venv/
EOF
commit_push "$P" "$R"
fi

# ---------------------------------------------------------------- P4
P=p4_RWX; R=hcmut-tmt-p4-blast-radius
clone_repo "$P" "$R"
if is_set_up "$P" "$R"; then echo ">> $R: đã có commit, không chép lại starter"; else
S="$ROOT/$P/starter_files/blast-radius-sample"
D="$ROOT/$P/submission/$R"
cp -r "$S"/. "$D"/
cat > "$D/.gitignore" <<'EOF'
output.jsonl
__pycache__/
*.pyc
.venv/
EOF
commit_push "$P" "$R"
fi

echo
echo "Xong. Link nộp:"
echo "  P1: https://github.com/$OWNER/hcmut-tmt-p1-mech-royale"
echo "  P2: https://github.com/$OWNER/hcmut-tmt-p2-shopping-sessions"
echo "  P4: https://github.com/$OWNER/hcmut-tmt-p4-blast-radius"
