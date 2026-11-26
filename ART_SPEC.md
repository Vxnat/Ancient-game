# ART_SPEC.md — Art Direction & Pixel Art Spec (*GARO: Hành Trình Hoàng Kim*)

## 1. Visual Tone & World Palette
- **Phong cách tổng thể:** 2D Pixel Art **Dark Gothic / Cổ phong Huyền bí (*GARO* Action Dark-Fantasy)** — tương phản sắc nét giữa bóng tối Ma Giới, ánh kim rực rỡ của Hoàng Kim Giáp và ngọn lửa Ma Đạo xanh ngọc.
- **Độ tương phản vùng đất:**
  - *Đấu trường Khu Đông / Đô Thị Đêm (Vertical Slice & Hồi 3):* Nền trời đêm xanh than, ánh đèn đường vàng lạnh, kiến trúc đá/gạch Gothic rõ hình khối để nhân vật nổi bật tuyệt đối.
  - *Dinh thự Saejima (Hub):* Gỗ sẫm ấm, tượng Sói đá cổ kính, góc vẽ sáng ấm của Kaoru.
  - *Rừng Ma Giới / Lâu Đài Gương:* Chướng khí tím sẫm, tinh thể/bụi Ma Giới lập lòe (không tối mù).
- **Quy tắc đường viền & đổ bóng:** Pixel Art sắc nét (`default_texture_filter = Nearest`), viền tối có màu, 2–3 bậc đổ bóng rõ nét; nền sheet gốc đồng nhất `#182030` khi nhờ AI vẽ.

## 2. Technical Grid & Proportions (`960×540` Target Viewport)
- **Viewport:** `960 × 540 px` (`stretch/mode = "viewport"`, `default_texture_filter = Nearest`).
- **Khung Sprite chuẩn:**
  - `Human` & `GaroArmor` cơ bản: **`96 × 96 px`** (chân đặt tại `y = 92`).
  - Các đòn chém Đại Kiếm / Lướt rộng: **`112 × 96 px`** hoặc **`128 × 96 px`** (căn giữa, chân tại `y = 92`).
  - Biến hình triệu hồi / giải giáp (`armor_in`, `armor_out`) có vòng tròn ánh sáng trên đầu: **`128 × 128 px`** (chân tại `y = 120`, bù `offset.y = -12`).
- **Hướng mặc định:** Quay mặt sang **phải**, lật ngang qua `VisualPivot.scale.x`.

## 3. Chiến lược Tài nguyên theo 5 Giai đoạn (Asset Optimization)
Áp dụng đúng nguyên tắc tối ưu trong **GDD V3**:
- **Ưu tiên 1 — Vertical Slice (Hồi 3 — Làm trước):**
  - **Kouga Trưởng Thành (`Human`):** Áo choàng chiến đấu trắng/đen đặc trưng Kỵ Sĩ Ma Giới (kiểu Kouga), găng tay tối, kiếm **Garoken** cầm 1 tay sắc bén, kèm bật lửa/lửa Ma Đạo xanh ở tay trái.
  - **Giáp Garo (`GaroArmor`):** Bộ giáp **Hoàng Kim Sói Vàng** toàn thân, mũ sói mắt **xanh lá**, khăn/vạt choàng sau lưng, **Đại Kiếm Garoken Hoàng Kim** to & dài hơn bản thường; trạng thái **Viêm Nhận** phủ lửa xanh ngọc dọc lưỡi kiếm.
  - **Tâm Diệt Thú Thân (`LostSoulBeast`):** Biến thể giáp Garo bị bóng tối nuốt (viền đỏ-tím, dáng thú khom hung tợn hơn, mắt đỏ rực, vệt chém tối-đỏ).
  - **Boss Horror Đầu Tiên (2 Phase):**
    - *Phase 1:* Hình dạng ngụy trang / giáp bóng tối sẫm có màng đen bọc ngoài.
    - *Phase 2:* Lộ bản thể Horror to lớn, quái dị với dấu hiệu báo đòn (*telegraph*) rõ.
- **Ưu tiên 2 — Giai đoạn mở rộng sau Vertical Slice (Out-of-Scope tạm thời):**
  - **Prologue (`Saejima Taiga`):** Tái sử dụng 90% bộ `GaroArmor` của Kouga, chỉ đổi màu mắt giáp từ **xanh lá → đỏ** và chỉnh nhẹ tông khăn/áo choàng.
  - **Kouga 8 tuổi (`Hồi 1`):** Bộ động tác tối giản (Chạy, Né, Parry, 1 nhát chém kiếm gỗ ngắn), không cần chuỗi combo dài.
  - **Kouga 16 tuổi (`Hồi 2`):** Giữ gần phom/áo choàng quá khổ của cha để giảm công vẽ, tư thế cầm Garoken 2 tay nặng nề (2 đòn + khung trễ rõ).

## 4. Bộ Animation Yêu Cầu cho Vertical Slice (Hồi 3)
| Dạng / Nhân vật | Animation cần có | Ghi chú kỹ thuật |
| :--- | :--- | :--- |
| **`Human` (Kouga Hồi 3)** | `idle`, `run`, `jump`, `fall`, `dash` (né i-frames), `parry` (đỡ kiếm), `attack_1..4` (combo 4 đòn Garoken 1 tay), `lighter_flame` (hất Ma Đạo Hỏa `K`), `hurt`, `exhausted` (kiệt sức 1 HP) | Kiếm Garoken là vũ khí chính; có biến thể cháy lửa xanh hoặc VFX gắn kiếm khi dùng Ma Đạo Hỏa. |
| **`GaroArmor` (Giáp Sói Vàng)** | `armor_in` (vung kiếm rạch vòng tròn ánh sáng, `128×128`), `armor_out` (giải giáp), `idle`, `run`, `jump`, `fall`, `dash`, `attack_1..3` (đại kiếm nặng/rộng), `flame_blade_fx` (Viêm Nhận), `hurt` | Có *Super Armor* khi trúng đòn nhẹ; ăn đòn nặng chớp đỏ & trừ 5s. |
| **`LostSoulBeast` (Tâm Diệt)** | `beast_transform`, `beast_idle`, `beast_run`, `beast_slash_1..3`, `beast_qte_recover` | Hoặc dùng shader/overlay tối + sprite đầu sói quỷ biến dị phủ lên khung `GaroArmor` để làm nhanh bản mẫu rồi nâng cấp sau. |
| **`VFX & UI`** | Vòng tròn triệu hồi ánh sáng vàng, Lửa xanh Ma Đạo Zaruba (`48×48` / `96×96`), tia kiếm khí, hiệu ứng **Parry Spark**, đồng hồ **`99.9`**, viền nhiễu đỏ Tâm Diệt & QTE Prompt | Giữ filter `Nearest`, nền alpha = 0 sạch không halo tối. |

## 5. Quy tắc Pipeline & Chuyển giao Tài nguyên Cũ
- Các bộ sprite Dragon Ball cũ (`assets/sprites/player/child/`, `teen/`, `adult/`, `adult_overdrive/`) **vẫn được giữ nguyên tạm thời** để game hiện tại không bị gãy khi kiểm thử, chỉ xóa/archive sau khi các bộ sprite GARO thay thế xong hoàn toàn.
- Mọi sprite GARO mới lưu tách gọn theo thư mục riêng (VD: `assets/sprites/garo/kouga_human/`, `assets/sprites/garo/garo_armor/`, `assets/sprites/garo/horrors/`).
