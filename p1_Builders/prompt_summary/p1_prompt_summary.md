# Bàn giao: Builders Buildathon 2026 – Problem 1 (Builders Mech Royale)

## Prompt để dán vào chat mới

```
Đọc file p1_Builders/prompt_summary/p1_prompt_summary.md trong repo D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON rồi tiếp tục giúp tôi làm Problem 1 (Builders Mech Royale) của Builders Buildathon. Hạn chót 23:00 CN 22/11/2026 (GMT+7). Tôi làm một mình. Trả lời tiếng Việt, không commit, không clone, báo trước khi sửa file nào.
```

## Bối cảnh hackathon
- Builders Buildathon 2026, đội **HCMUT TMT**, làm **một mình** (Đặng Minh Triết).
- **Hạn chót: 23:00 Chủ nhật 22/11/2026 (GMT+7)** cho cả 4 track: **P1 Builders Mech Royale**, P2 Databricks Shopping Sessions, P3 Machina CAD De-ID, P4 RWX Blast Radius.
- Repo: `D:\Hackathon\Builders_Buildathon\HCMUT_TMT_Builders_BUILDATHON` (GitHub `martin-danggg/HCMUT_TMT_Builders_BUILDATHON`, chỉ 1 commit `55687de`, p1–p4 chưa được git theo dõi).
- File P1 có sẵn: `p1_Builders/starter_files/mechfight-kit.tar.gz` và bản giải nén `mechfight-kit/mechfight-kit/` (`protocol.md` – đặc tả đầy đủ; `python/` với `mechfight.py`, `example_bot.py`, `Dockerfile`; `ts/`; `check/check.py` + `stream.jsonl.gz`; `arena/v2/world.json`, `terrain.i16`). Báo cáo tổng quan: `p1_Builders/reports/p1_overview.pdf` (tiếng Việt), `p1_overview_en.pdf` (tiếng Anh).
- Quy ước của người dùng: trả lời tiếng Việt; **không commit, không clone; báo trước khi sửa file nào**; số liệu chạy thử phải ghi rõ "chạy thử".
- **Repo nộp riêng (đã tạo):** `https://github.com/martin-danggg/hcmut-tmt-p1-mech-royale`, trên máy ở `p1_Builders/submission/hcmut-tmt-p1-mech-royale/` (git repo độc lập, repo chính bỏ qua qua `.gitignore`). Khung từ starter (`Dockerfile` ở gốc chạy `bot.py`, `mechfight.py`, `check/`, `arena/v2/`, `docs/`, README) được commit "Setup: add requirements" (`f4e1861`) và push bằng `bash tools/setup_submissions.sh`. Repo tối đa 20 MB. Chưa có code bot thật (bot.py là bot mẫu đổi tên `hcmut-tmt`).

## Đề P1
- Viết chương trình lái một mech trong trận tự do **16 mech** trên khuôn viên Ohio State. Mỗi 0,1 s nhận quan sát JSON qua stdin (thấy gì, nghe gì), trả action qua stdout (di chuyển, ngắm, bắn) trong **50 ms**; `ready` trong 20 s. Protocol `mechfight/1`, JSON từng dòng. Phải qua `check/check.py` dưới giới hạn sandbox.
- Chạy: 1 CPU, 512 MB RAM, không mạng, uid 65534, đĩa chỉ đọc trừ `/tmp` 64 MB, bản đồ tại `/arena`. Mọi log ra stderr.
- **Chấm (tự động):** điểm một trận = 16 − hạng (thắng 15, chết đầu tiên 0; hết giờ xếp theo HP). Mỗi lần nộp = trung bình 48 trận practice với **15 bot nhà**. **4 lần nộp/giờ.** Vòng loại: top 32 đấu nhau 16 trận; chung kết: top 16 đấu 64 trận. Hòa thì bài nộp sớm hơn thắng. Repo phải public và giữ commit đến khi công bố.
- **Luật practice then chốt:** 15 bot nhà là **một đội** (chia sẻ tầm nhìn, không đánh nhau, săn bạn "một con lúc đầu, thêm dần, tất cả vào cuối"). Bạn chỉ lên hạng khi bot nhà chết: do bạn giết, hoặc do vùng bo cuối trận (ai nhiều HP sống lâu hơn). Vòng loại/chung kết thì đấu tự do với bot đội khác.
- **Kit không có simulator:** chỉ thử được bằng lượt nộp practice hoặc chơi trên `play.joinbuilders.org`.

## Số luật chơi chính (từ `hello.config` trong `stream.jsonl.gz`; đọc lại lúc chạy vì có thể đổi)
- 20 tick/s, quyết định mỗi 2 tick, trận tối đa 480 s. Mech 1400 HP, đi 11,7 m/s, chạy nhanh 19,5 m/s, năng lượng 100, quay thân 4 rad/s, hồi 45 HP/s sau 5 s không giao tranh, trúng từ sau ×1,5.
- Súng 45 sát thương, 0,24 s/phát, 252 m/s, tầm 230 m, băng 12, nạp 2,4 s. Cối 200 + lan 160. Laser tối đa 315 (nạp 0,75 s), tầm 280 m. Sét 60, tầm 45 m.
- Vùng bo 560 → 380 → 240 → 140 → 70 → 25 → 0 m, đóng hẳn khoảng 415 s; sát thương ngoài bo 20 → 260 HP/s. Supply drop gọi lúc 70/140/210 s.
- Cube: +4% HP và sát thương mỗi cube (tối đa 10); 22 nâng cấp. Bản đồ: 259 khối (223 tòa nhà), 1560 cây, lưới địa hình 1070 × 724.

## Bảng điểm practice (ảnh chụp 21/11, 123 đội)
Hạng 1 AT **5,48**, hạng 2 5,35; baseline (bot mẫu Python) **1,15**.

## Số liệu chạy thử
- Bot mẫu Python qua `check.py` (không Docker): PASS, 300/300 quan sát đúng hạn, p50 0,3 ms, p99 0,6 ms.

## Hướng làm đề xuất (đã chọn: bot luật bằng Python + numpy)
1. **1.1** Repo public, Dockerfile, bọc `try/except`, giới hạn thời gian; nộp bot v1 sớm.
2. **1.2** Lưới độ cao/đi được tính sẵn offline (`.npy`), hàm `los()` duyệt tia trên lưới, trí nhớ địch.
3. **1.3** Theo vùng bo (đến vòng kế trước khi co), A* lưới 2 m, đứng gần chỗ che, lùi để hồi máu, cuối trận giữ HP cao ở giữa vòng.
4. **1.4** Ngắm đón (giải phương trình bậc hai), chỉ bắn khi `los` thông và sai số góc nhỏ, quay mặt về phía bị bắn, né laser; súng + laser.
5. **1.5** Nhặt vũ khí phụ, cube khi an toàn; nâng cấp ưu tiên plating > armor > nanites > sát thương.
6. **1.6** Mỗi lần nộp đổi một ý, ghi log; đừng tối ưu quá theo bot nhà.

## Tình trạng hiện tại (CN 22/11, khoảng 01:50)
- Chưa làm phần nào; người dùng đang ưu tiên P3. Lịch đề xuất ban đầu cho P1: khoảng 6,5 giờ.
