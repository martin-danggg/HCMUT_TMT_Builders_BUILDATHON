# Bàn giao: Builders Buildathon 2026 – Problem 4 (RWX Blast Radius)

## Prompt để dán vào chat mới

```
Đọc file p4_RWX/prompt_summary/p4_prompt_summary.md trong thư mục HCMUT_TMT_Builders_BUILDATHON tôi đã kết nối (repo D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON) rồi tiếp tục giúp tôi làm Problem 4 (RWX Blast Radius) của Builders Buildathon 2026. Repo nộp: p4_RWX/submission/hcmut-tmt-p4-blast-radius (đã có v2.5 push, v3 sẵn trong Dockerfile.v3). Hạn chót 23:00 CN 22/11/2026 (GMT+7), tôi làm một mình. Trả lời tiếng Việt. Đề và forum Q&A là nguồn chính, số liệu phải khớp code, số chạy thử ghi rõ "chạy thử". Báo trước khi sửa file nào. Commit thì đưa lệnh cho tôi tự chạy và push, không ghi tên Claude trong commit. Bắt đầu bằng việc nói ngắn gọn tình trạng hiện tại và việc nên làm tiếp theo.
```

## Bối cảnh hackathon
- Builders Buildathon 2026, đội **HCMUT TMT**, làm **một mình** (Đặng Minh Triết).
- **Hạn chót: 23:00 Chủ nhật 22/11/2026 (GMT+7)** cho cả 4 track: P1 Builders Mech Royale, P2 Databricks Shopping Sessions, P3 Machina CAD De-ID, **P4 RWX Blast Radius**.
- Repo chính: `D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON` (GitHub `martin-danggg/HCMUT_TMT_Builders_BUILDATHON`, **public**). Commit `93efebb` (22/11) đã đưa báo cáo, `prompt_summary`, starter và `tools/setup_submissions.sh` lên. `.gitignore` chặn `p1_Builders/submission/`, `p2_Databricks/submission/`, `p4_RWX/submission/` (repo nộp riêng) và `p3_Machina/submission/` (dữ liệu P3, không được công bố).
- File P4 có sẵn: `p4_RWX/starter_files/blast-radius-sample.tar.gz` và bản giải nén `p4_RWX/starter_files/blast-radius-sample/` (`selector.py`, `score.py`, `Makefile`, `Dockerfile`, `requirements.lock`, `README.md`, `SCORING.md`, `sample/` với 30 commit mẫu, `tests.json`, `answers.json`). Báo cáo tổng quan: `p4_RWX/reports/p4_overview.pdf` (tiếng Việt), `p4_overview_en.pdf` (tiếng Anh).
- Quy ước của người dùng: trả lời tiếng Việt; **báo trước khi sửa file nào**; đề và forum Q&A là nguồn chính, mọi con số phải khớp với code; số liệu chạy thử phải ghi rõ "chạy thử"; không công khai mã mời đội. Được commit trong repo nộp riêng (báo trước), nhưng **người dùng tự push** (Claude không dùng được SSH key `github-personal`). **Không thêm dòng Co-Authored-By/ghi tên Claude vào commit.** Git trong máy ảo của Claude không xóa được file nên đừng chạy `git commit`/`git add` ở đó (để lại `.git/index.lock`); đưa lệnh cho người dùng chạy trong Git Bash.
- **Repo nộp riêng (đã tạo):** `https://github.com/martin-danggg/hcmut-tmt-p4-blast-radius`, trên máy ở `p4_RWX/submission/hcmut-tmt-p4-blast-radius/` (git repo độc lập, repo chính bỏ qua qua `.gitignore`). Nội dung: toàn bộ kit; commit "Setup: add requirements" (`2a682dc`), push bằng `bash tools/setup_submissions.sh`. Sau đó: v1 (`6cd7add`), v2.5 (`265d7c0`) – xem mục Cách làm.

## Đề P4
- Mỗi commit là một patch (unified diff) vào **sqlglot tại commit `eb11aec4be8cb2122afe713a4816662c3f0fb2fa`**. Chương trình đọc `/data/commits/<id>.patch` và `/data/tests.json`, in **mỗi commit một dòng JSON** `{"commit": "...", "workers": [[số test, ...], ...]}` ra stdout: chọn test cần chạy và chia cho **tối đa 8 worker**. Tập rỗng `[]` là đáp án đúng nếu thay đổi không làm hỏng gì.
- **Chi phí:** mỗi commit = tải lớn nhất của một worker (tổng giây ghi sẵn) + **2 s × số worker**; mỗi commit bỏ sót test fail: **+300 s**; cộng toàn bộ CPU của container. Chạy image 3 lần, lấy trung vị. Càng thấp càng tốt. Chấm tự động; code của các đội đứng đầu được người đọc để kiểm tra luật.
- **Luật quan trọng:** cấm bảng tra "patch / loại thay đổi → test"; được dùng **map dựng từ commit ghim** (coverage, imports, fixtures). Repo tối đa 20 MB. Build: có mạng, 4 core, 8 GB, 10 phút (chỉ tải từ PyPI/npm/Docker Hub/GitHub release có tag cố định/sqlglot tại commit ghim). Chạy: không mạng, 2 core, 4 GB, **3 phút cho cả batch** (final 4,5 phút), user `nobody`, `/tmp` 64 MB, stdout tối đa 2 MB. Ban đầu nộp **1 lần/giờ**.
- Final: commit được chọn chấm trên commit chưa công bố, **có loại thay đổi không có trong practice**; top 5 chạy lại 5 lần; điểm cách điểm tốt nhất không quá 1 s coi là hòa, bài nộp sớm hơn thắng.

## Bảng điểm practice (ảnh chụp 21/11, 116 đội)
Hạng 1 SophiaOmri **153,7 s**, hạng 2 156,8 s; baseline starter (chạy hết test, 3 worker) **1614,1 s**. Suy luận: practice có khoảng 40 commit (1614,1 / 40,35 s mỗi commit); các đội đầu chọn test gần như chính xác tuyệt đối.

## Số liệu từ bộ mẫu (chạy thử bằng `score.py`, chưa cộng CPU)
- 1620 test có số + 1 test bị skip; tổng 103,047 s. Test chậm nhất: `test_max_nodes` 28,817 s, `test_execute_tpcds` 21,454 s, `test_generator_memory` 6,686 s.
- 30 commit mẫu: 16 code, 8 fixture, 3 multi, 3 comment; 12 commit không làm hỏng test nào.
- Starter (tất cả, 3 worker): 1210,470 s. Tất cả, 8 worker: 1344,510 s. Không chạy gì: 5400 s (18 miss). Oracle: 135,138 s.
- Chạy hết test: tối ưu ở **4 worker = 36,817 s/commit** (3 worker 40,349 s). Bỏ 3 test chậm nhất: 5 worker = 19,218 s.

## Cách làm (đã triển khai, repo nộp)
- **Map từ commit ghim** (`map/map.pkl.xz`, ~240 KB, dựng bằng `tools/map_build/run_map.sh`): mỗi file test chạy một tiến trình pytest, mỗi test chạy trong một tiến trình **fork** riêng (để cache khởi tạo lười gắn đúng vào mọi test cần nó); tiến trình spawn của optimizer/executor được ghi vết qua `sitecustomize.py`. Ghi cho từng test: dòng chạy lúc runtime, dòng chạy lúc import, file đã mở, lớp đã khởi tạo (kèm MRO).
- **Chọn tĩnh** (`blast/candidates.py`): áp patch vào nguồn ghim, so AST (comment/định dạng → 0 test); dòng trong hàm → test đã chạy câu lệnh đó; sửa trong `lambda` → test gọi lambda; thân lớp/module → (test đã nạp module) ∩ (test đọc tên đó, bỏ qua dòng chỉ định nghĩa) ∩ (test đã khởi tạo lớp/lớp bao/lớp con); fixture → test đã mở file; `TYPE_CHECKING`, hàm mới không ai dùng → 0; xoá `.py` → test đã nạp; lỗi cú pháp/file lạ/lỗi bất kỳ → chọn tất cả.
- **Kiểm tra import** (`blast/runner.py`): thay đổi chạy lúc import → import module đã vá từ overlay symlink trong `/tmp`; hỏng → chọn mọi test đã nạp module.
- **v3 – bỏ test nặng** (chỉ khi `BR_HEAVY_SKIP=1`, đặt trong `Dockerfile.v3`): nếu ứng viên có test ≥ 3 s và lợi ích kỳ vọng ≥ 1 s (P_pass = 0,4; CPU ≈ 1,6 × giây ghi sẵn + 2,5 s), chạy test nhẹ trong container với `--maxfail=1`; tất cả qua → bỏ hết (in `[]`), có fail → giữ toàn bộ tập tĩnh.
- Chia worker: LPT, chọn k = 1..8 nhỏ nhất theo makespan + 2 s × k.

## Kết quả (chạy thử, 30 commit mẫu, `score.py`)
- Starter 1210,470 s → v1 211,804 s → **v2.5 169,197 s** (CPU ~1,2 s) → **v3 144,410 s** (CPU ~4–6 s). 0 miss ở mọi bản.
- Oracle theo cách chia của mình: 94,4 s. Còn lệch chủ yếu ở `4d63` (thuộc tính tokenizer snowflake, 358 test) và các commit vô hại có ứng viên nhỏ (~2 s mỗi cái vì phí worker).
- Docker trên máy người dùng (bản v1) cho `output.jsonl` trùng từng dòng với bản chạy cục bộ. v3 đã giả lập container (user `nobody`, nguồn chỉ đọc, `/tmp` dùng 116 KB) và chạy ổn; **chưa build Docker thật cho v3**.

## Kiểm định (chạy thử, môi trường Python 3.13.18 + requirements.lock)
- Chạy cả suite trên 6 commit mẫu: tập fail **trùng khít** `answers.json` (môi trường tái hiện đúng).
- 40 đột biến tự sinh (đổi `and/or`, so sánh, hằng số, `True/False`) chạy cả suite: **0 miss**; chi phí tĩnh 4,99 s/commit so với oracle 1,84 (chạy hết: 36,8).
- Hiệu chỉnh luật bỏ test nặng: 100 đột biến trên dòng mà test nặng phủ; 23 ca mọi test nhẹ qua → **0 ca test nặng fail**.
- 14 patch tổng hợp (đổi tên/tạo/xoá file, docstring, `TYPE_CHECKING`, thêm/xoá hàm, đổi mode, không có newline cuối): selector không vỡ.

## Tình trạng hiện tại (CN 22/11, khoảng 05:30)
- Repo nộp: `6cd7add` v1, `265d7c0` v2.5 (đã push). Trên máy đã có (chưa commit): `selector.py` mới (luật v3, mặc định tắt) + `Dockerfile.v3` + README.
- Việc tiếp theo: (1) build và chạy thử v3 bằng Docker (`cp Dockerfile.v3 Dockerfile`, kỳ vọng 144.410 s, 0 miss); (2) commit + push + nộp v3, so điểm practice với v2.5; (3) chọn bản cho final (v2.5 an toàn hơn về build, v3 điểm tốt hơn).
- Công cụ kiểm định nằm trong workspace của Claude (không ở repo): `genmut.py`, `groundtruth.sh`, `checkgt.py`, `genheavy2.py`, `runcal.py`.
