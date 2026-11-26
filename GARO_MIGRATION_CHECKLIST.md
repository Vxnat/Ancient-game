# GARO Migration Checklist — *GARO: Hành Trình Hoàng Kim* (Theo GDD V3 Final)

Checklist này bám sát **GDD V3 Final** và chiến lược **làm từng bước nhỏ — xong chắc Vertical Slice Hồi 3 trước rồi mới mở rộng sang Hub & các Hồi khác**, nên bạn không cần phải nhớ toàn bộ cốt truyện dài ngay một lúc.

---

## Phần 0: Chốt Thiết Kế Cốt Lõi
- [x] Chốt lộ trình cốt truyện 5 phần (`Prologue → Hồi 1 (8t) → Hồi 2 (16t) → Hồi 3 (20+t) → Hồi 4`), nhưng **bắt đầu dựng bản mẫu từ Vertical Slice Hồi 3 trước**.
- [x] Chốt 4 trạng thái cốt lõi: **`Human` → `GaroArmor` (99.9s Active Drain) → `LostSoulBeast` (Tâm Diệt 10–12s + QTE Zaruba) → `Exhausted` (1 HP, khóa giáp 45s, -7s/Perfect Parry)**.
- [x] Chốt cơ chế **Dạng Người vs Dạng Giáp**:
  - `Human`: tốc độ `1.0×`, **Parry**, **Ma Đạo Hỏa (`K`)** đốt lớp vỏ bóng tối lộ điểm yếu `5s`, tích **Ý Chí (`0–100`)**.
  - `GaroArmor`: **Giáp Sói Vàng**, *Super Armor*, **Viêm Nhận** (Zaruba thổi lửa xanh nâng `2.2× → 3.0×` dmg nhưng đồng hồ trôi `1.8×`), trúng đòn trực diện trừ thẳng `5.0s`.
- [x] Chốt vai trò đồng hành: **Bỏ `Disciple` chiến đấu & `Fusion`**; dùng **Ma Đạo Luân Zaruba** (lửa xanh Viêm Nhận, QTE cứu khỏi Tâm Diệt, cảnh báo/thoại). Các yếu tố Hub (*Tà Khí Inga*, *Tượng Sói Thanh Tẩy*, *Kaoru*) đưa vào Giai đoạn B sau Vertical Slice.
- [x] Chính sách tài nguyên: Giữ sprite Dragon Ball cũ làm nền tạm không làm hỏng build; chỉ dọn sau khi sprite GARO thay thế xong.

---

## Phần 1: Tài Liệu Định Hướng (`Docs`)
- [x] Đồng bộ toàn bộ GDD V3 Final vào [GDD.md](file:///c:/Hoc_Tap/Game-new/GDD.md).
- [x] Cập nhật định hướng mỹ thuật, tỷ lệ & chiến lược tối ưu tài nguyên vào [ART_SPEC.md](file:///c:/Hoc_Tap/Game-new/ART_SPEC.md).
- [x] Sắp xếp lộ trình chia pha nhỏ theo từng mốc thực thi vào [ROADMAP.md](file:///c:/Hoc_Tap/Game-new/ROADMAP.md).

---

## Phần 2: Mốc 1 — Lõi Điều Khiển & Máy Trạng Thái 4 Pha (Greybox Vertical Slice)
> Làm gọn với hình khối/sprite tạm trước để kiểm chứng cảm giác điều khiển 100%, không cần vẽ đẹp ngay.

- [ ] **Tái cấu trúc biến trạng thái trong [player.gd](file:///c:/Hoc_Tap/Game-new/entities/player/player.gd) & [event_bus.gd](file:///c:/Hoc_Tap/Game-new/autoloads/event_bus.gd):**
  - Chuyển đổi `Ki` → **Thanh Ý Chí (`0–100`, `Willpower`)** (tích từ đánh trúng & Parry thành công; về `0` khi giải giáp).
  - Thêm bộ đếm **`99.9s` Active Time Drain** (`armor_timer`, tốc độ trôi `1.0×` thường / `1.8×` khi bật Viêm Nhận; trừ thẳng `5.0s` khi bị đánh trúng trực diện lúc đang mặc giáp).
  - Thêm bộ đếm **`45.0s` Khóa Giáp** cho trạng thái `Exhausted` + giảm ngay `7.0s` mỗi cú `Perfect Parry`.
  - Bỏ logic `Fusion` & `is_weapon_suppressed()` cũ (khi mặc Giáp Garo giữ/nâng cấp Đại Kiếm Garoken, không chuyển về tay không).
- [ ] **Thêm / Cập nhật các State trong `entities/player/states/` & [player.tscn](file:///c:/Hoc_Tap/Game-new/entities/player/player.tscn):**
  - Thêm **`Parry` State** (đỡ kiếm + cửa sổ `Perfect Parry` cho `Human`, giảm `7s` khóa giáp nếu đang `Exhausted`).
  - Mở rộng [player_attack.gd](file:///c:/Hoc_Tap/Game-new/entities/player/states/player_attack.gd) lên **Combo 4 đòn** cho `Human` (và bộ đòn Đại Kiếm uy lực cho `GaroArmor`).
  - Chỉnh [player_ki_blast.gd](file:///c:/Hoc_Tap/Game-new/entities/player/states/player_ki_blast.gd) (`K`): ở `Human` thành **Bật lửa Ma Đạo Hỏa** (bắn tia/ngọn lửa xanh ngắn đốt vỏ bóng tối Horror trong `5s`); ở `GaroArmor` thành bật/chém **Viêm Nhận** (hoặc tách toggle Viêm Nhận rõ ràng).
  - Cập nhật [player_power_up.gd](file:///c:/Hoc_Tap/Game-new/entities/player/states/player_power_up.gd) (`Human → GaroArmor` khi Ý Chí = `100`) & [player_power_down.gd](file:///c:/Hoc_Tap/Game-new/entities/player/states/player_power_down.gd) (chủ động giải giáp trước `00.0`).
  - Tạo **`LostSoulBeast` State** (*Tâm Diệt Thú Thân*): kéo dài `10–12s`, `3.5×` dmg, tốc độ cao, rút `8% Max HP/s`, kích hoạt **chuỗi QTE Zaruba** từ giây thứ `5` (bấm chuẩn → `Exhausted`, trượt/cạn HP → Game Over).
  - Tạo **`Exhausted` State** (hoặc cờ trạng thái trên `Human`): hạ HP về `1`, khóa thanh Ý Chí `45s`, vẫn cho chạy/né/Parry sinh tồn.
- [ ] **Gỡ `Disciple` khỏi vòng chiến đấu:** Ẩn/tách [disciple.tscn](file:///c:/Hoc_Tap/Game-new/entities/allies/disciple.tscn) khỏi cảnh chiến đấu Vertical Slice để nhường chỗ cho hệ thống **Zaruba** (thoại/cảnh báo/QTE).
- [ ] **HUD Vertical Slice ([game_hud.gd](file:///c:/Hoc_Tap/Game-new/ui/hud/game_hud.gd), [game_hud.tscn](file:///c:/Hoc_Tap/Game-new/ui/hud/game_hud.tscn)):**
  - Hiển thị: **Thanh HP**, **Thanh Ý Chí (`0–100`)**, **Đồng hồ `99.9s`** (nháy cảnh báo khi `< 15s`), **Trạng thái Viêm Nhận**, **Thời gian Khóa Giáp `45s`** (khi `Exhausted`), và **QTE Zaruba UI** + **viền nhiễu đỏ** khi rơi vào *Tâm Diệt*.

---

## Phần 3: Mốc 2 — Đấu Trường, Boss Horror 2 Phase & Game Feel
- [ ] **Dựng scene Đấu trường Vertical Slice (Khu Đông phẳng khép kín)** (có thể tạo scene mới gọn `world/vertical_slice/east_sector_arena.tscn` để không làm rối scene cũ trong lúc dựng mẫu).
- [ ] **Tạo Boss Horror đầu tiên (2 Phase):**
  - *Phase 1 (`100% → 60% HP`):* Có lớp vỏ bóng tối giảm **70% sát thương vật lý**; trúng **Ma Đạo Hỏa (`K`)** sẽ cháy lộ điểm yếu `5s` (nhận `100%` hoặc tăng sát thương + tích Ý Chí nhanh). Bộ chiêu cận chiến để người chơi luyện né/Parry.
  - *Phase 2 (`60% → 0% HP`):* Lột xác bản thể quái vật, 4–5 đòn diện rộng có cảnh báo rõ (*telegraph*), đủ nặng để trừ `5.0s` trên đồng hồ Garo khi ăn đòn trực diện.
- [ ] **Game Feel & VFX Zaruba:**
  - Tinh chỉnh *hitstop*, rung màn hình, âm thanh va chạm kim loại nặng, hiệu ứng lửa xanh Zaruba bọc lưỡi kiếm (**Viêm Nhận**) và tia chém.

---

## Phần 4: Mốc 3 — Playtest, Cân Bằng & Test Tự Động Vertical Slice
- [ ] Chơi test liên tục căn chỉnh HP Boss + lượng Ý Chí mỗi đòn Parry/chém đạt đúng chuẩn: **1 trận Boss gọi giáp ~2 lần** và **ít nhất 1 lần đồng hồ ép xuống dưới `15s`**.
- [ ] Cập nhật/viết test headless cho máy trạng thái 4 pha (`Human`, `GaroArmor` 99.9s active drain, `LostSoulBeast` + QTE, `Exhausted` 1 HP & `-7s` Perfect Parry) và Boss 2 Phase.

---

## Phần 5: Mỹ Thuật & Sprite Sheets (Thực hiện cuốn chiếu cho Vertical Slice trước)
- [ ] **Bộ 1 — Kouga Hồi 3 (`Human`):** Concept + sprite sheet áo choàng trắng/đen chuẩn GARO cầm Garoken 1 tay (`idle`, `run`, `jump`, `fall`, `dash`, `parry`, `attack_1..4`, `lighter_flame`, `hurt`, `exhausted`).
- [ ] **Bộ 2 — Giáp Sói Vàng (`GaroArmor`):** `armor_in` (`128×128`), `armor_out`, di chuyển, combo Đại Kiếm 1–3, hiệu ứng **Viêm Nhận** lửa xanh ngọc.
- [ ] **Bộ 3 — Tâm Diệt Thú Thân (`LostSoulBeast`) & Boss Horror 2 Phase:** Sprite Boss Phase 1/2 + hiệu ứng biến dị Tâm Diệt.

---

## Phần 6: Giai Đoạn Mở Rộng Sau Khi Vertical Slice Đã Ngon (*Chưa cần làm ngay*)
- [ ] **Hub Dinh thự Saejima & Kinh tế Săn Horror:** Thanh **Tà Khí (`Inga 0–100%`)**, **Tượng Sói Thanh Tẩy**, **Góc vẽ Kaoru** (buff *Tĩnh Tâm* làm chậm Inga + nới QTE), hệ thống thư Sở Phiên Khuyển.
- [ ] **Các Map Hồi 3 khác:** Đô thị Đêm (Bảo tàng, Ga tàu, Cao ốc), Rừng Ma Giới (đố lửa xanh Zaruba + chướng khí), Tâm Cảnh (`Boss Rush`).
- [ ] **Prologue & Hồi 1–2:** Saejima Taiga (giáp Garo đổi mắt đỏ), Kouga 8 tuổi (kiếm gỗ + né/Parry bẫy Gonza + đấu Barago), Kouga 16 tuổi (kiếm 2 tay trễ + Tâm Ma + giáp 99.9s trôi `2x`).
- [ ] **Hồi 4 (Cao trào):** Màn *Set-piece* cưỡi chiến mã **Gōten** & bay **Tsubasabito**, Boss Messiah & Barago/Kiba.
- [ ] **Dọn sạch tài nguyên Dragon Ball cũ** khi tất cả nội dung GARO đã ổn định.
