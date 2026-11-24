# ART_SPEC.md — Art Direction & Pixel Art Technical Specification

## 1. Visual Tone & World Palette
- **Phong cách tổng thể:** 2D Pixel Art **Phiêu lưu Tươi sáng & Rực rỡ (Vibrant Science-Fantasy Adventure)** — lấy cảm hứng từ *Dragon Ball* phần đầu kết hợp kiến trúc/tàn tích công nghệ cổ đại.
- **Độ tương phản vùng đất:**
  - *Hành tinh yên bình (Peaceful Planet):* Bầu trời xanh sáng, cỏ xanh ngọc, đất nâu ấm, ánh nắng rực rỡ.
  - *Tàn tích cổ đại (Ancient Ruins):* Tông lam-tím cổ kính với tinh thể phát sáng rực rỡ (không bị tối mù hay kinh dị).
- **Quy tắc đường viền & đổ bóng:** Pixel Art sắc nét (`default_texture_filter = Nearest`), sử dụng viền tối có màu (*colored dark outline*, tránh dùng đen `#000000` thuần trừ chi tiết nhỏ), 2–3 bậc đổ bóng (*cel/pixel shading*).

## 2. Technical Grid & Proportions (`960x540` Target Viewport)
- **Độ phân giải mục tiêu (Viewport):** **`960 × 540 px`** (tỷ lệ 16:9, `default_texture_filter = Nearest`, `stretch/mode = "viewport"` — sẽ cập nhật vào `project.godot` ở bước tích hợp code).
- **Kích thước ô Sprite chuẩn (`Frame Size`):** **`96 × 96 px`** cho tất cả animation của Player (đủ rộng cho đường kiếm và chưởng Ki mà không làm nhỏ nhân vật).
- **Điểm neo (Origin / Pivot):** Căn giữa theo chiều ngang (`x = 48`), bàn chân chạm đáy cố định (`y = 92` trong ô `96×96`, chừa `4 px` đệm dưới) để khi chuyển animation nhân vật không bị giật lên xuống.
- **Hướng mặc định:** Quay mặt sang **phải** (`facing_direction = 1`), lật ngang khi quay trái.
- **Chiều cao nhân vật theo 3 giai đoạn trưởng thành:**
  - **Nhỏ (`Child`):** `~54–56 px` (rõ mắt, lông mày, biểu cảm, băng tay và nếp gấp võ phục).
  - **Thiếu niên (`Teen`):** `~62–64 px`.
  - **Trưởng thành (`Adult`):** `~70–72 px`.

## 3. Main Character Design (Approved Reference Spec)
- **Mẫu đã duyệt:** Nền tảng **Concept #1** ([hero_concept_ref.jpg](file:///c:/Hoc_Tap/Game-new/assets/_raw_inbox/hero_concept_ref.jpg)) + **dải đai lưng bay** từ **Concept #2** ([hero_concept_ref_option2.jpg](file:///c:/Hoc_Tap/Game-new/assets/_raw_inbox/hero_concept_ref_option2.jpg)).
- **Trang phục gốc:** Võ phục du hành gọn nhẹ — áo võ không tay vạt chéo màu xanh ngọc đậm, **đai lưng vàng-kem có dải lụa bay** (phất nhẹ khi đứng yên, bay ngược về sau khi chạy/nhảy/rơi/dash), quần võ tối màu, bốt cổ viền vàng trầm, và **băng quấn cổ tay trắng-kem** (giúp đánh tay không và cầm vũ khí đều tự nhiên).
- **Tóc & Tiến hóa ngoại hình (`Nhỏ → Thiếu niên → Trưởng thành`):**
  - **Nhỏ (`Child`):** Tóc đen ánh xanh ngắn, hơi rối và chĩa nhẹ.
  - **Thiếu niên (`Teen`):** Tóc dài hơn, dựng và dày hơn thành bờm chiến binh trẻ.
  - **Trưởng thành (`Adult`):** Tóc dài buộc cao thành đuôi ngựa / bờm chiến binh uy nghiêm.
- **Bảng màu biến hình (Palette Swaps):**
  - **Base:** Tóc đen ánh xanh (`#1a1f2e` / `#2c3752`), võ phục xanh ngọc đậm (`#1f6f8b`), đai vàng ấm (`#f2b749`), Khí xanh lam sáng (`#5eead4` / `#38bdf8`).
  - **Overdrive:** Tóc & hào quang ánh **vàng cam rực (`#fbbf24` / `#f97316`)**, mắt sáng rực.
  - **Fusion:** Tóc & hào quang **tím - bạch kim (`#c084fc` / `#f3e8ff`)**, đai & viền giáp ánh kim.

## 4. Required Player Animation Set (`SpriteFrames`)
| State / Action | Animation Name | Target Frames | FPS | Loop | Notes |
| :--- | :--- | :---: | :---: | :---: | :--- |
| Idle | `idle` | 4 | 6 | Yes | Thở nhẹ, tay thủ võ trống |
| Move | `run` | 6 | 10 | Yes | Chạy nghiêng người năng động |
| Jump | `jump` | 2 | 8 | No | Bật nhảy lên |
| Fall | `fall` | 2 | 8 | Yes | Rơi xuống, áo/tóc bay ngược |
| Dash / Air-Dash | `dash` | 2 | 12 | No | Lướt ngang tốc độ cao |
| Attack (Bare-hand Combo 1–3) | `attack_bare_1` / `_2` / `_3` | 3×3 | 7–9 | No | Combo 3 đòn võ thuật: Đấm thẳng → Đá ngang → Móc kết thúc |
| Attack (Weapon Combo 1–3) | `attack_weapon_1` / `_2` / `_3` | 3×3 | 7–9 | No | Combo 3 đòn gậy Bo Staff: Chém chéo → Quét/Đâm ngang → Đập bổ bước mạnh tới trước |
| Air Attack (Weapon) | `air_attack_weapon` | 3 | 9 | No | Nhảy co chân chém vòng trên không (Tay không dùng lại `attack_bare_2`) |
| Dash Attack (Weapon) | `dash_attack_weapon` | 3 | 9 | No | Lao thấp đâm thẳng đầu gậy kèm vệt gió (Tay không dùng lại `attack_bare_1` + `DashGhost`) |
| Ki Blast | `ki_blast` | 3 | 12 | No | Đẩy tay phóng chưởng Khí |
| Hurt | `hurt` | 2 | 10 | No | Giật lùi trúng đòn |
| Transform In / Out (Adult) | `overdrive_in` / `overdrive_out` | 4 / 4 | 10 | No | Khung `128×128 px` (bàn chân ở `y=120`, bù `offset.y = -12`) thể hiện gồng bùng hào quang lửa vàng và xả biến hình |
| Overdrive Unarmed Air / Dash / Beam (Adult Overdrive) | `air_attack_bare`, `dash_attack_bare`, `beam_cast` | 3 / 3 / 4 | 10.5 / 11 / 10 | No | Bộ chiêu tay không riêng (`112×96 px` cho *Meteoric Dive Kick* & *Sonic Dash Fist*) và tư thế bắn `Overdrive Ki Beam` (`U`) |

## 5. VFX & Transformation Pipeline
- **Dash Afterimage (`combat/vfx/dash_ghost`):** Sinh bóng mờ `Sprite2D` sao chép frame hiện tại mỗi `0.03s` trong lúc `Dash`, làm mờ bằng `Tween` (`0.18s`).
- **Ki Blast (`combat/projectiles/ki_blast`):** `AnimatedSprite2D` `48×48 px` gồm `fly` (4 frame cầu Khí xanh kéo đuôi) và `hit` (4 frame nổ vỡ Khí khi trúng mục tiêu/tường).
- **Overdrive Ki Beam (`combat/projectiles/overdrive_beam`):** `AnimatedSprite2D` `160×80 px` gồm `beam` (4 frame tia sóng Khí vàng-lam xuyên mục tiêu).
- **Adult Overdrive Dedicated Sprites (`assets/sprites/player/adult_overdrive/`):** Bộ `adult_overdrive_sprite_frames.tres` vẽ trực tiếp tóc vàng dựng & mắt xanh ngọc + combo quyền cước lửa vàng (không dùng Shader đổi màu), đi kèm `overdrive_in`/`overdrive_out`.
- **Ki Aura (`combat/vfx/ki_aura`) & Palette Swap Shader:** Vẫn dùng cho `Fusion` trong pha gồng (`PowerUp`) và nhuộm sắc tím-bạch kim cho tới khi hoàn tất bộ sprite `Adult Fusion`.

## 6. Asset Pipeline Rules
- Thư mục nháp/tham khảo đặt ở `assets/_raw_inbox/` (không commit asset thô thừa vào scene).
- Sprite đã cắt/chuẩn hóa cho Godot lưu theo cấu trúc: `assets/sprites/player/<stage>/` (`child/`, `teen/`, `adult/`, `adult_overdrive/`).
- Mọi ảnh `.png` trong `assets/sprites/` phải dùng Filter `Nearest`, nền trong suốt sạch (alpha = 0), không anti-aliasing ở viền pixel.
