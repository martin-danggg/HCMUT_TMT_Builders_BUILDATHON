# Bàn giao: Builders Buildathon 2026 – Problem 3 (Machina CAD De-ID)

## Prompt để dán vào chat mới

```
Đọc file p3_Machina/prompt_summary/p3_prompt_summary.md trong thư mục HCMUT_TMT_Builders_BUILDATHON tôi đã kết nối (repo D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON) rồi tiếp tục giúp tôi làm Problem 3 (Machina CAD De-ID) của Builders Buildathon 2026. Tôi không thuê được VM, ổ D: còn khoảng 113 GB, nên làm theo lô bằng --prefix trong WSL2 tại D:\machina (đã bật phân biệt hoa thường). Hạn chót 23:00 CN 22/11/2026 (GMT+7), tôi làm một mình. Trả lời tiếng Việt. Đề và forum Q&A là nguồn chính, số liệu phải khớp code, số chạy thử ghi rõ "chạy thử". Báo trước khi sửa file nào. Commit thì đưa lệnh cho tôi tự chạy và push, không ghi tên Claude trong commit. Bắt đầu bằng việc nói ngắn gọn tình trạng hiện tại và việc nên làm tiếp theo.
```

## Bối cảnh hackathon
- Builders Buildathon 2026, đội **HCMUT TMT**, làm **một mình** (Đặng Minh Triết, triet.dangminh@hcmut.edu.vn).
- **Hạn chót: 23:00 Chủ nhật 22/11/2026 (GMT+7)** cho cả 4 track. Bảng lúc đóng là kết quả cuối.
- 4 track: P1 Builders Mech Royale (AI cho mech), P2 Databricks Shopping Sessions (pipeline CSV → Parquet), **P3 Machina CAD De-ID**, P4 RWX Blast Radius (chọn test cho sqlglot). Thứ tự ưu tiên giữa các track chưa chốt (xem Tình trạng hiện tại).
- Repo chính: `D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON` (GitHub `martin-danggg/HCMUT_TMT_Builders_BUILDATHON`, **public**). Commit `93efebb` (22/11) đã đưa báo cáo, `prompt_summary`, starter và `tools/setup_submissions.sh` lên. `.gitignore` chặn `p1_Builders/submission/`, `p2_Databricks/submission/`, `p4_RWX/submission/` (repo nộp riêng) và `p3_Machina/submission/` (dữ liệu P3, không được công bố).
- File P3 có sẵn: `p3_Machina/starter_files/challenge.pdf`, `upload.py`. Báo cáo tổng quan: `p3_Machina/reports/p3_overview.pdf` (tiếng Việt) và `p3_overview_en.pdf` (tiếng Anh).
- Quy ước của người dùng: trả lời tiếng Việt; **báo trước khi sửa file nào**; đề và forum Q&A là nguồn chính, mọi con số phải khớp với code; số liệu chạy thử phải ghi rõ "chạy thử"; không công khai mã mời đội. Được commit trong repo nộp riêng (báo trước), nhưng **người dùng tự push** (Claude không dùng được SSH key `github-personal`). **Không thêm dòng Co-Authored-By/ghi tên Claude vào commit.** Git trong máy ảo của Claude không xóa được file nên đừng chạy `git commit`/`git add` ở đó (để lại `.git/index.lock`); đưa lệnh cho người dùng chạy trong Git Bash.

## Đề P3
- Corpus: **188.722 file, 139,7 GB** (PDF, bản vẽ, SolidWorks, Inventor, STEP/IGES/DXF/STL, ảnh, file nén). Thay mọi thông tin định danh (tên công ty/người, tài khoản, liên lạc, tên miền, địa chỉ, logo, tên/số hiệu dự án và chi tiết) bằng **bút danh có nghĩa, nhất quán** trên toàn corpus. Danh tính khác nhau giữ khác nhau; không xóa trắng.
- Phải bao phủ: chữ hiển thị và ảnh, tên file và thư mục, metadata và file đính kèm PDF, thuộc tính native của CAD, ảnh xem trước, nội dung file nén (không để bản gốc trong file nén).
- **Giữ file dùng được:** hình học, kích thước, dung sai, đơn vị, vật liệu, cấu hình, BOM, quan hệ bản vẽ–model–assembly. Đổi tên file thì phải sửa cả tham chiếu tới nó. Giữ phần mở rộng và các phần đường dẫn không định danh.
- Lấy dữ liệu: `https://machina-input.joinbuilders.org` → `get-input.sh` (có `--limit`, `--prefix`, `--jobs`, chạy lại để tải tiếp được), `manifest.tsv`. Cần **hệ thống file phân biệt hoa thường**. Giữ dữ liệu thô riêng tư.
- Nộp: thư mục `attempt-N/` gồm `corpus/`, `code/` (mã nguồn + lockfile), `README.txt` (lệnh chạy, giới hạn, ngoại lệ, lỗi sẵn có của nguồn). Upload bằng `upload.py` (token 1 giờ lấy ở trang nộp) vào `gs://builders-machina-submissions-1120/teams/<team-id>/attempt-N/`, rồi dán địa chỉ vào form. `upload.py` chỉ bỏ qua file đã có **trong cùng thư mục đích** (nên upload dần từng lô vào cùng `attempt-1/` được, nhưng attempt mới phải upload lại toàn bộ).
- Chấm: 1000 check riêng tư, chấm tự động; phản hồi chỉ có tổng điểm và số check qua theo category. **20 attempt tổng**, 2/giờ, mỗi lúc một bài, chấm thường dưới 20 phút (tối đa 3 giờ). Giới hạn: tối đa 400.000 object; file trên 2 GB bị bỏ qua; scorer dừng nếu cần quá 12 GB tải hoặc quá 1 giờ đọc. Hòa thì attempt sớm hơn xếp trên. BTC có thể chấm lại bằng bộ chấm nghiêm hơn.
- Trang đề ghi đè `challenge.pdf` (PDF nói 3 attempt và nộp qua S3): áp dụng **20 attempt, nộp qua form**.

## Bảng điểm (ảnh chụp 21/11, 12 đội)
67: 660 · Team-Xero: 417 · Hidden Test Cases: 398 · sirPeasALot: 374 · Monsters: 293 · **Baseline (chép nguyên đầu vào): 292** · putabuilderon, yoookay: 292 · We Asked ChatGPT: 271 · whyMiso: 158 · AT: 51 · Lone Gradient: 39 · prompt-gods: 1.
→ Chép nguyên đã được 292 (khoảng 29% check là loại "file còn dùng được"). **Không bao giờ làm hỏng file.** Khoảng 400 điểm là vào top 3; top 3 được Machina giới thiệu phỏng vấn Engineering Researcher.

## Tình trạng hiện tại (CN 22/11, khoảng 03:40)
- **Không thuê được VM** (bỏ phương án Google Cloud). Ổ D: còn khoảng **113 GB trống**, không đủ chứa toàn bộ cùng lúc.
- Từ môi trường của Claude (cả cloud lẫn máy ảo trên máy người dùng), `machina-input.joinbuilders.org` bị proxy chặn (403). **Người dùng phải tự tải trên Windows/WSL.**
- Kế hoạch: xử lý **theo lô bằng `--prefix`** (mỗi lô khoảng 30–35 GB, đỉnh khoảng 80 GB đĩa): tải → xử lý → upload vào `attempt-1/` → xóa → lô tiếp. Làm trong WSL2, thư mục làm việc **ngoài repo** `D:\machina`, bật phân biệt hoa thường bằng `fsutil.exe file setCaseSensitiveInfo D:\machina enable`. Kết nối `D:\machina` vào chat để Claude đọc được. (Trong repo, `p3_Machina/submission/` cũng bị `.gitignore` chặn nếu cần để file tạm.)
- **Đang chờ:** kết quả `time bash get-input.sh --limit 100` và `du -sh input` để đo tốc độ mạng. Nếu khoảng 100 Mbps trở lên (3–4 giờ mỗi chiều cho 140 GB) thì làm P3; nếu chậm hơn thì cân nhắc bỏ P3, dồn sức cho P4/P2/P1.
- Chưa quyết định thứ tự ưu tiên giữa 4 track; sẽ chốt sau khi có tốc độ tải P3 và điểm nền P1/P4.
## Hướng làm đề xuất
1. Từ `manifest.tsv`: thống kê theo phần mở rộng, thư mục, dung lượng; chia lô theo prefix.
2. Danh tính: lấy từ metadata (PDF Info/XMP, OLE, docProps, EXIF, header STEP `FILE_NAME`), regex (email, URL, tên miền, điện thoại), tên thư mục cấp cao, mẫu số hiệu chi tiết. Bút danh tất định (HMAC), **cùng độ dài byte** (an toàn cho file nhị phân và tham chiếu tên file), giữ khuôn dạng số hiệu, tên miền dạng `example.com`, không trùng nhau. Bảng ánh xạ lưu riêng tư, dùng chung giữa các lô.
3. Ưu tiên theo lợi ích/rủi ro: văn bản và CAD trung tính → metadata PDF/Office/ảnh → tên file → file nén → chữ hiển thị trong PDF → Inventor (olefile) → SolidWorks/DWG (rủi ro cao, nén). Mỗi bộ xử lý tự mở lại file đầu ra; lỗi thì **trả về bản gốc**.
4. **Attempt 1 (an toàn):** văn bản, CAD trung tính, metadata, tên file/thư mục; file nhị phân khó giữ nguyên byte. Quét rò rỉ (ASCII, UTF-16LE, không phân biệt hoa thường, cả bên trong file nén), kiểm tra mở file, README, upload. Nộp attempt cuối trước khoảng 20:30 CN.
