# Bàn giao: Builders Buildathon 2026 – Problem 2 (Databricks Shopping Sessions)

## Prompt để dán vào chat mới

```
Đọc file p2_Databricks/prompt_summary/p2_prompt_summary.md trong repo D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON rồi tiếp tục giúp tôi làm Problem 2 (Databricks Shopping Sessions) của Builders Buildathon. Hạn chót 23:00 CN 22/11/2026 (GMT+7). Tôi làm một mình. Trả lời tiếng Việt, không commit, không clone, báo trước khi sửa file nào.
```

## Bối cảnh hackathon
- Builders Buildathon 2026, đội **HCMUT TMT**, làm **một mình** (Đặng Minh Triết).
- **Hạn chót: 23:00 Chủ nhật 22/11/2026 (GMT+7)** cho cả 4 track: P1 Builders Mech Royale, **P2 Databricks Shopping Sessions**, P3 Machina CAD De-ID, P4 RWX Blast Radius.
- Repo: `D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON` (GitHub `martin-danggg/HCMUT_TMT_Builders_BUILDATHON`, chỉ 1 commit `55687de`, p1–p4 chưa được git theo dõi).
- File P2 có sẵn trong `p2_Databricks/`: `rules.md` (đặc tả đầy đủ, **thắng starter khi mâu thuẫn**), 3 starter (`starter-duckdb`, `starter-polars`, `starter-pyspark`, có .zip và bản giải nén; pipeline rỗng, 36 fixture giống nhau), `generator/` (Rust), `dev-answer/` (`user_daily.csv` 117.038 dòng, `campaign_daily.csv` 27.400 dòng). Báo cáo tổng quan: `p2_Databricks/reports/p2_overview.pdf` (tiếng Việt), `p2_overview_en.pdf` (tiếng Anh).
- Quy ước của người dùng: trả lời tiếng Việt; **không commit, không clone; báo trước khi sửa file nào**; số liệu chạy thử phải ghi rõ "chạy thử".
- **Repo nộp riêng (đã tạo):** `https://github.com/martin-danggg/hcmut-tmt-p2-shopping-sessions`, trên máy ở `p2_Databricks/submission/hcmut-tmt-p2-shopping-sessions/` (git repo độc lập, repo chính bỏ qua qua `.gitignore`). Nội dung: toàn bộ `starter-duckdb` + `TEAM.md` đã điền + `.gitignore` chặn dữ liệu; commit "Setup: add requirements" (`21cd7e4`), rồi `93d927b` "Fix: keep CRLF in fixtures" (thêm `.gitattributes` `* -text` để Git trên Windows không đổi dòng CRLF cố ý của fixture E20), push bằng `bash tools/setup_submissions.sh`. Repo tối đa 50 MB, không chứa dữ liệu. Pipeline vẫn là bản rỗng của starter.

## Đề P2
- Làm sạch log CSV (events, clicks, links) của shop online → 2 bảng Parquet theo ngày: `/output/user_daily/` và `/output/campaign_daily/`. Luật chính xác, chỉ có một đáp án đúng; **sai một chút là 0 điểm**.
- Các bước chính theo `rules.md`: đọc CSV đúng dialect (chỉ `\n` kết thúc dòng, ngoặc kép bọc cả trường, `""` = null, dòng lỗi bỏ; chỉ dòng đầu mỗi file là header) → 3 dạng timestamp (F1 `Z`, F2 có offset, F3 epoch ms) với kiểm tra lịch chặt và cửa sổ → gộp ID qua `links` (union-find, tên = ID nhỏ nhất theo byte) → event: dedup theo `event_id` (giữ `ingest_ts` nhỏ nhất) **trước** khi kiểm tra, bỏ event trễ quá 24 giờ, chia phiên với khoảng nghỉ > 30 phút (cùng `ts` chung phiên), ngày = ngày UTC lúc bắt đầu → click: gán phiên cho click muộn nhất trong 7 ngày trước (hòa thì `click_id` nhỏ nhất), chiến dịch hỗ trợ trong `[start − 7 ngày, start]` → ghi Parquet (`day` kiểu `DATE`).
- **Chấm (tự động):** mỗi lần nộp chạy trước trên bộ dev 1 triệu event (sai thì dừng), rồi chạy trên practice ẩn khoảng 20 triệu event; điểm = thời gian thực từ lúc container khởi động đến khi thoát. Final: khoảng 60 triệu event, chạy 3 lần, **mỗi lần tối đa 3 phút** (quá là mất điểm final) → đề khuyên practice dưới khoảng 60 s. **2 lần nộp/giờ.**
- Máy chạy: 8 vCPU, 24 GB RAM, không mạng, `/data` chỉ đọc, `/output` + `/scratch` tối đa 50 GB, uid 1000.

## Bảng điểm practice (ảnh chụp 21/11, 116 đội)
Hạng 1 Mahalas **0,68 s**; hạng 10 khoảng 0,99 s; khoảng hạng 50 là 1,6 s; hạng 100 là 8,00 s; baseline PySpark **172,00 s**.

## Số liệu chạy thử
- Bộ dev (`generate --seed 1 --events 1000000 --clicks 250000`): 92 MB, 30 file events, 40 file clicks, 14 file links; 1.072.086 dòng event, 255.240 click, 44.874 link (không tính header).
- DuckDB đọc nguyên dòng 1,07 triệu event: 0,10 s; tách 7 trường: 0,11 s (máy 2 vCPU).

## Hướng làm đề xuất (đã chọn: DuckDB cho bản đúng đầu tiên)
1. Repo public từ `starter-duckdb`; build `generator`, tạo `dev/`; lặp nhanh bằng `python3 scripts/run_fixtures.py fixtures -- python3 pipeline/pipeline.py`.
2. Đọc CSV: `read_csv(..., columns={'line':'VARCHAR'}, delim=chr(1), quote='', escape='', header=true, auto_detect=false)` rồi tự tách bằng `string_split`, tự xử lý ngoặc và null (đừng để DuckDB hiểu dialect).
3. Timestamp bằng regex chặt `[0-9]` + số học ngày (không dùng `strptime`); F3 quá 18 chữ số là sai.
4. Union-find bằng Python/scipy (không dùng CTE đệ quy).
5. Chia phiên trên `DISTINCT (person, ts)` với `lag`; gán phiên bằng `ASOF JOIN`; hỗ trợ bằng range join.
6. Kiểm thử: **36/36 fixture** + `make check-dev` ra MATCH trước mọi lần nộp. Sau đó mới tối ưu tốc độ (bộ 20 triệu tự tạo); viết lại bằng Rust chỉ khi còn dư nhiều thời gian.

## Tình trạng hiện tại (CN 22/11, khoảng 01:50)
- Chưa làm phần nào; người dùng đang ưu tiên P3. Lịch đề xuất ban đầu cho P2: khoảng 6,5 giờ.
