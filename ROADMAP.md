# Development Roadmap — *GARO: Hành Trình Hoàng Kim*

Dự án chuyển từ nguyên mẫu nền tảng ban đầu (Phase 1–4 trước đây) sang lộ trình **GARO V3 Final**: kiểm chứng bằng **Vertical Slice Hồi 3** trước, rồi mới mở rộng Hub và các Hồi cốt truyện.

## Nền tảng Engine đã hoàn thiện (Giữ & Tái sử dụng ~80%)
- [x] Khởi tạo dự án Godot `4.3-stable`, Autoloads (`EventBus`, `GameManager`, `SceneManager`, `QuestManager`, `SaveManager`, `AudioManager`), Components (`HealthComponent`, `StatsComponent`, `WeaponComponent`, `HitboxComponent`, `HurtboxComponent`) và `StateMachine`.
- [x] Hệ thống Game Feel cơ bản: `Coyote Time`, `Jump Buffer`, `Hitstop`, Camera `Trauma` shake, `Dash` có `i-frames`.
- [x] Khung UI (`MainMenu`, `PauseMenu`, `DialogueBox`, `HUD`) và pipeline test headless (`tests/test_phase1..4.tscn`).

---

## Giai đoạn A — Vertical Slice Hồi 3 (Ưu tiên làm từng bước ngay)
> Mục tiêu: Chỉ tập trung vào **1 đấu trường phẳng khép kín + Saejima Kouga Hồi 3 + 1 Boss Horror 2 Phase**.

- [ ] **Mốc 1 — Lõi Điều khiển & Máy Trạng thái (Greybox):**
  - Hoàn thiện State Machine 4 pha cho `Player`: `Human → GaroArmor (99.9s Active Time Drain) → LostSoulBeast (Tâm Diệt + QTE) → Exhausted (1 HP, khóa giáp 45s, -7s mỗi Perfect Parry)`.
  - Hoàn thiện hành động `Human`: Chạy, Né (`i-frames`), **Parry** (`Perfect Parry`), combo 4 đòn, **Bật lửa Ma Đạo Hỏa (`K`)**, tích thanh **Ý Chí (`0–100`)**.
  - Hoàn thiện kỹ năng `GaroArmor`: *Super Armor*, **Viêm Nhận** (`2.2× → 3.0×` dmg, đồng hồ trôi `1.8×`), trừ `5.0s` khi ăn đòn trực diện.
  - HUD tối giản phục vụ Vertical Slice: HP, thanh Ý Chí, đồng hồ **`99.9s`**, thông báo trạng thái *Tâm Diệt* / QTE / thời gian khóa giáp.
- [ ] **Mốc 2 — Lõi Boss Horror 2 Phase & Game Feel:**
  - Tạo Đấu trường Khu Đông khép kín + Boss Horror đầu tiên (**Phase 1:** vỏ bóng tối giảm 70% sát thương vật lý, cần Ma Đạo Hỏa đốt mở điểm yếu 5s; **Phase 2:** 4–5 chiêu diện rộng có *telegraph*).
  - Hoàn thiện VFX & Audio: *Hitstop*, rung màn hình, lửa xanh Zaruba, tia chém Linh Kim, viền tối/nhiễu đỏ khi *Tâm Diệt*.
  - Tích hợp dần bộ sprite **Kouga Hồi 3**, **Giáp Sói Vàng**, và **Boss Horror**.
- [ ] **Mốc 3 — Kiểm thử & Cân bằng (Playtest):**
  - Test tự động & chơi thử liên tục đạt chuẩn vàng: `1` trận Boss cần gọi giáp `~2 lần`, và ít nhất `1` lần đồng hồ tụt dưới `15s`.

---

## Giai đoạn B — Hệ thống Hub, Tà Khí & Kaoru (Mở rộng Hồi 3)
- [ ] Mở khóa **Dinh thự Saejima (Hub)**: nhận mệnh lệnh Sở Phiên Khuyển, **Tượng Sói Thanh Tẩy** xả thanh **Tà Khí (`Inga 0–100%`)**, và **Góc vẽ Kaoru** (buff *Tĩnh Tâm* làm chậm `Inga` + nới cửa sổ QTE).
- [ ] Thêm các màn vụ án Khu Đông (Bảo tàng, Ga tàu, Cao ốc) với nhịp điều tra bằng Ma Đạo Hỏa → kết giới chiến đấu.
- [ ] Thêm **Rừng Ma Giới & Đền Thờ** (câu đố ánh sáng lửa xanh Zaruba, môi trường chướng khí tăng `Inga`), **Suzumura Rei (Zero)** & **Jabi**.

---

## Giai đoạn C — Nội dung Cốt truyện Đầu & Cuối Game (Làm theo từng Hồi)
- [ ] **Prologue (Saejima Taiga):** Tái sử dụng giáp Garo đổi mắt đỏ + chạm trán Barago, ẩn UI phức tạp.
- [ ] **Hồi 1 (Kouga 8 tuổi):** Dinh thự phóng đại, kiếm gỗ 1 nhát + né + Parry bẫy Gonza, *scripted loss* trước Barago.
- [ ] **Hồi 2 (Kouga 16 tuổi):** Kiếm cầm 2 tay có độ trễ, Tâm Cảnh đấu ảo ảnh cha, gọi giáp bản thử nghiệm (trôi `x2`).
- [ ] **Hồi 4 (Cao trào):** Màn *Set-piece* cưỡi chiến mã **Gōten** & bay **Dực Nhân Nha Lang (Tsubasabito)**, quyết đấu Messiah & Barago/Kiba.
- [ ] **Dọn dẹp cuối kỳ:** Xóa/archive toàn bộ tài nguyên Dragon Ball cũ sau khi mọi sprite GARO đã hoàn tất.
