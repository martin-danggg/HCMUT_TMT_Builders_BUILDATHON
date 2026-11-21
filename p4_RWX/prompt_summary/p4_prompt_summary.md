# Bàn giao: Builders Buildathon 2026 – Problem 4 (RWX Blast Radius)

## Prompt để dán vào chat mới

```
Đọc file p4_RWX/prompt_summary/p4_prompt_summary.md trong repo D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON rồi tiếp tục giúp tôi làm Problem 4 (RWX Blast Radius) của Builders Buildathon. Hạn chót 23:00 CN 22/11/2026 (GMT+7). Tôi làm một mình. Trả lời tiếng Việt, không commit, không clone, báo trước khi sửa file nào.
```

## Bối cảnh hackathon
- Builders Buildathon 2026, đội **HCMUT TMT**, làm **một mình** (Đặng Minh Triết).
- **Hạn chót: 23:00 Chủ nhật 22/11/2026 (GMT+7)** cho cả 4 track: P1 Builders Mech Royale, P2 Databricks Shopping Sessions, P3 Machina CAD De-ID, **P4 RWX Blast Radius**.
- Repo: `D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON` (GitHub `martin-danggg/HCMUT_TMT_Builders_BUILDATHON`, chỉ 1 commit `55687de`, p1–p4 chưa được git theo dõi).
- File P4 có sẵn: `p4_RWX/starter_files/blast-radius-sample.tar.gz` và bản giải nén `blast-radius-sample/` (`selector.py`, `score.py`, `Makefile`, `Dockerfile`, `requirements.lock`, `README.md`, `SCORING.md`, `sample/` với 30 commit mẫu, `tests.json`, `answers.json`). Báo cáo tổng quan: `p4_RWX/reports/p4_overview.pdf` (tiếng Việt), `p4_overview_en.pdf` (tiếng Anh).
- Quy ước của người dùng: trả lời tiếng Việt; **không commit, không clone; báo trước khi sửa file nào**; số liệu chạy thử phải ghi rõ "chạy thử".
- **Repo nộp riêng (đã tạo):** `https://github.com/martin-danggg/hcmut-tmt-p4-blast-radius`, trên máy ở `p4_RWX/submission/hcmut-tmt-p4-blast-radius/` (git repo độc lập, repo chính bỏ qua qua `.gitignore`). Nội dung: toàn bộ kit; commit "Setup: add requirements" (`2a682dc`), push bằng `bash tools/setup_submissions.sh`. Selector vẫn là bản starter (chạy hết test, 3 worker).

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

## Hướng làm đề xuất (đã chọn: map tĩnh từ commit ghim)
1. **4.1 Môi trường:** repo public riêng (đã có); môi trường offline cùng image digest `python:3.13-slim@sha256:e48f59...`, `pip install -r requirements.lock`, sqlglot checkout tại commit ghim; `SKIP_INTEGRATION=0 pytest --collect-only -q` phải ra đúng 1620 id + 1 skip.
2. **4.2 Map:** chạy pytest với coverage theo từng test (`--cov-context=test`) → map dòng → test; map fixture (ghi file mỗi test mở qua `sys.addaudithook`); map import; phạm vi hàm/lớp bằng `ast`. Nén và commit vào repo (không dựng trong Dockerfile).
3. **4.3 Chọn test:** dòng cũ bị đổi → test phủ **cả hàm chứa dòng đó**; dòng mức lớp/module xử lý riêng; áp patch vào bản sao trong `/tmp` rồi `compile()` để bắt lỗi cú pháp (lỗi thì chọn tất cả); fixture → test đã mở file đó; comment không mặc định vô hại (docstring/doctest, file `.sql`).
4. **4.4 Chia worker:** LPT cho k = 1..8, chọn k nhỏ nhất theo makespan + 2000k (ms).
5. **4.5 An toàn:** chọn tất cả khi xác suất sót > khoảng 12% (36,8 / 300). Mọi luật phải suy ra từ mã nguồn hoặc map, **không** từ `answers.json`.
6. **4.6 Nộp:** `make sample` không được có miss; nộp sớm bản an toàn rồi thu hẹp dần; ghi log phiên bản.

## Tình trạng hiện tại (CN 22/11, khoảng 01:50)
- Chưa làm phần nào; người dùng đang ưu tiên P3. Lịch đề xuất ban đầu cho P4: khoảng 5,5 giờ.
