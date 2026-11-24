# Game Design Document (GDD) — Project Origin

## 1. High Concept
- **Thể loại:** 2D Pixel Art Action-Platformer / Metroidvania + Action RPG
- **Bối cảnh:** Science Fantasy phiêu lưu tươi sáng, rực rỡ (hành tinh yên bình ấm áp xen lẫn tàn tích công nghệ cổ đại và năng lượng Khí huyền bí).
- **Cảm hứng:** Nhịp độ chiến đấu tốc độ cao, Khí, biến hình và hợp thể lấy cảm hứng từ *Dragon Ball* phần đầu đến trưởng thành, đặt trong cấu trúc khám phá Metroidvania.
- **Quy mô phát triển:** Solo Developer. (Xem chi tiết mỹ thuật tại [ART_SPEC.md](file:///c:/Hoc_Tap/Game-new/ART_SPEC.md)).

## 2. Bối cảnh & Cốt truyện tóm tắt
- **Biến cố:** Quê hương của nhân vật chính — một nền văn minh chiến binh kết hợp công nghệ và Khí — bị hủy diệt bởi một thảm họa bí ẩn. Trước khi sụp đổ, bạn được đưa vào khoang thoát hiểm phóng sang hành tinh khác.
- **Mở đầu:** Bạn rơi xuống một **hành tinh yên bình** và được một người dân địa phương nhận nuôi, sống và tập luyện từ nhỏ.
- **Hành trình:** Sau biến cố/lời kêu gọi của nguồn cội, bạn bước vào cuộc phiêu lưu khám phá các vùng đất bị chia cắt, chiến đấu để tìm hiểu: *Mình là ai? Điều gì đã xảy ra với quê hương?*
- **Phát triển dài hạn:** Nhân vật trưởng thành từ **Nhỏ → Lớn**, thu nhận **Đệ tử** (hỗ trợ chiến đấu) và mở khóa kỹ năng **Hợp thể (Fusion)**.

## 3. Core Gameplay Loop
1. **Chiến đấu (Combat):**
   - **Đánh tay (Võ thuật) + Nhiều loại Vũ khí:** Vũ khí có **độ bền (durability)**. Khi vũ khí hỏng giữa trận, nhân vật tự động chuyển về đánh tay + dùng Khí để xoay xở.
   - **Né đòn & Khí:** Dash có bất tử khung hình (*i-frame*), bắn chưởng Khí tầm xa, và kích hoạt trạng thái **Overdrive (Quá Tải)** để tăng vọt sức mạnh (đi kèm rủi ro tiêu hao Khí/Máu).
2. **Tiến trình RPG & Kinh tế (1 loại tiền tệ duy nhất):**
   - **Tinh Chất (Essence):** Rơi ra từ quái thường và thưởng nhiệm vụ. Dùng để **Thức Tỉnh chỉ số/nội tại**, đồng thời **bảo quản (sửa chữa) và nâng cấp vũ khí**.
3. **Tiến trình Metroidvania & Cốt truyện:**
   - **Mảnh Lõi (Core Shard):** Rơi ra từ Boss hoặc giấu ở tàn tích cổ. Mỗi Mảnh Lõi mở khóa **kỹ năng di chuyển/chiến đấu lớn** (Air-Dash, Chưởng phá tường, Overdrive, Fusion...) và hé lộ ký ức quê hương.
   - **Nhiệm vụ (Quests):** Kết hợp nhiệm vụ cốt truyện và nhiệm vụ phụ từ NPC (đánh quái, hạ Boss, tìm vật phẩm).

## 4. Phạm vi MVP (Bản chơi thử đầu tiên)
Để tránh quá tải cho solo dev, MVP chỉ tập trung vào:
- 1 khu vực mở đầu (*Hành tinh yên bình*: 1 NPC giao nhiệm vụ, trạm nghỉ để Thức Tỉnh & Sửa vũ khí).
- 1 khu vực phiêu lưu (*Tàn tích đầu tiên*: 2 loại quái thường + 1 Boss).
- Player hoàn chỉnh di chuyển cơ bản, đánh tay, 1 vũ khí mẫu có độ bền, và 1 chiêu Khí cơ bản.

## 5. Thông số & Cơ chế Cốt lõi (Gameplay Specs)

### 5.1. Di chuyển & Game Feel (`Player`, Viewport `960×540`)
| Cơ chế | Phím | Thông số hiện tại | Ghi chú |
| :--- | :--- | :--- | :--- |
| Chạy trái/phải | `A` / `D` | Tốc độ gốc `230 px/s`, gia tốc mặt đất `2400` | Kiểm soát trên không `0.65x` |
| Nhảy | `Space` | Lực nhảy `-470`, trọng lực lên `1150`, rơi `1.8x` | `Coyote Time` 6 ticks (~0.10s), `Jump Buffer` 7 ticks (~0.12s), thả sớm cắt vận tốc `0.45x`, `Apex Hang` `0.5x` |
| Dash | `Shift` | Tốc độ `480 px/s`, thời lượng `0.15s`, hồi `0.28s` | Miễn nhiễm sát thương (*i-frame*) + hiệu ứng bóng mờ `DashGhost` |
| Hitstop & Shake | Tự động | Khựng `0.055s` (`time_scale = 0.05`), Trauma `+0.35` | Kích hoạt khi đòn cận chiến trúng mục tiêu |

### 5.2. Chiến đấu, Khí (Ki) & Overdrive
| Cơ chế | Phím | Chi phí / Hồi phục | Hiệu ứng chi tiết |
| :--- | :--- | :--- | :--- |
| Đánh cận chiến | `J` | Hồi `+6 Ki` khi trúng (lúc không Overdrive) | **Combo 3 đòn** có Input Buffer (cửa sổ giữ nhịp `0.45s`, cắt đòn bằng Dash): Nhịp 1 (`0.34s`, `1.0×` dmg), Nhịp 2 (`0.36s`, `1.15×` dmg, `1.12×` tầm), Nhịp 3 kết thúc (`0.44s`, **bước mạnh tới trước `290 px/s`**, `1.45×` dmg, `1.25×` tầm, `1.65×` knockback). Ngoài ra có **Air Attack** (`Jump/Fall + J`, `1.1×` dmg, hãm rơi nhẹ) và **Dash Attack** (`Dash + J`, lướt đâm `330 px/s`, `1.25×` dmg, kèm `DashGhost`) |
| Bắn chưởng Ki | `K` | Tốn `20 Ki` | Sát thương gốc `14` (+ bonus từ *Martial Focus*), bay `380 px/s`, sprite cầu Khí `48×48` (`fly`/`hit`), nhân sát thương & phóng to `1.35×` khi Overdrive/Fusion |
| **Overdrive Ki Beam** (`SpecialSkill`) | `U` | **Chỉ dùng khi đang Overdrive hoặc Fusion**; tốn `30 Ki` | Gồng tung sóng Khí ngang (`OverdriveBeam` `160×80`), xuyên nhiều mục tiêu tầm `156 px` với **`3.0×`** sát thương gốc (theo hệ số dạng biến hình) |
| Hồi Ki tự nhiên | Tự động | `+6 Ki/s` (tắt khi đang Overdrive) | Ki tối đa mặc định `100` |
| **Overdrive** | `L` | **Mở khóa từ giai đoạn `Adult`**; tối thiểu `25 Ki`; tốn `10 Ki/s` + `2 HP/s` | Gồng biến hình `overdrive_in` (`0.45s`), chuyển sang bộ sprite `Adult Overdrive` tóc vàng dựng & mắt xanh ngọc, **tạm khóa gậy để đánh tay không bộ combo riêng** (*Rapid Golden Flurry* → *Spinning Thunder Kick* → *Ki-Burst Double Palm*, kèm *Meteoric Dive Kick* & *Sonic Dash Fist*, không tốn độ bền vũ khí); tăng `1.4x` sát thương (tổng `2.1x` ở Adult) và `1.4x` tốc độ; khi tắt `L` hoặc hết Ki sẽ phát `overdrive_out` (`0.40s`) trước khi hồi dạng thường |

### 5.3. Vũ khí & Độ bền (`WeaponInstance`)
- **Đánh tay mặc định:** Sát thương gốc `10`, tầm đánh `32 px` (tự động kích hoạt khi không có vũ khí hoặc độ bền vũ khí = `0`).
- **Vũ khí mẫu (`Traveler's Staff` - Gậy):** `+15` sát thương, tầm đánh `46 px`, độ bền tối đa `8`, trừ `1` độ bền mỗi đòn đánh trúng.
- **Bảo quản & Nâng cấp (tại Checkpoint):**
  - **Sửa chữa:** Tốn **Tinh Chất** tỷ lệ theo lượng độ bền đã mất (tối đa `20 Tinh Chất` khi hỏng hoàn toàn).
  - **Nâng cấp:** Tối đa `Lv.5`, mỗi cấp `+4` sát thương và hồi đầy độ bền; chi phí `50 × (cấp hiện tại + 1)`.

### 5.4. Thức Tỉnh Sức Mạnh (`Awakening Menu` tại Checkpoint `[E]`)
Khi đứng gần **Checkpoint** và bấm `E`: hồi đầy Máu/Ki, tự động lưu game qua `SaveManager`, và mở bảng nâng cấp:
| Kỹ năng (`SkillData.tres`) | Chi phí | Hiệu ứng vĩnh viễn |
| :--- | :--- | :--- |
| **Vitality Surge** | `50 Tinh Chất` | `+25` Máu tối đa |
| **Ki Reservoir** | `50 Tinh Chất` | `+30` Ki tối đa và `+2 Ki/s` hồi tự nhiên |
| **Martial Focus** | `75 Tinh Chất` | `+4` Sát thương gốc (áp dụng cho cả cận chiến & chưởng Ki) |
| **Swift Step** | `60 Tinh Chất` | `+25 px/s` Tốc độ chạy |

### 5.5. Quái, Boss & Kinh tế MVP
- **Training Dummy (`peaceful_village`):** `60 HP`, rơi `25 Tinh Chất`, tự hồi sinh sau `2s`.
- **Ruins Stalker (`ancient_ruins`):** `55 HP`, tuần tra & đuổi theo Player, đánh cận chiến (`14` sát thương), rơi `35 Tinh Chất`.
- **Ruins Sentinel (Boss đầu tiên):** `220 HP`, có 2 đòn báo hiệu (*Lunge Slash* `22` sát thương và *Energy Wave* `18` sát thương), rơi `100 Tinh Chất` và **Mảnh Lõi Gió (`air_dash_core`)**.

### 5.6. Nhiệm vụ & Kỹ năng Metroidvania (MVP)
- **Trial of Strength (`Foster Elder`):** Hạ `2 Training Dummy` → thưởng `100 Tinh Chất`.
- **Echoes of the Ruins (`Ruins Scout`):** Vào cổng sang `ancient_ruins` và hạ `Ruins Sentinel` → thưởng `250 Tinh Chất`.
- **Air-Dash (`air_dash_core`):** Mở khóa từ Mảnh Lõi của Boss; cho phép bấm `Shift` lướt thêm `1` lần trên không (hồi lại khi chạm đất), dùng để nhảy sang bệ bí mật lấy `Essence Cache` (`120 Tinh Chất`).

### 5.7. Trưởng thành (Nhỏ → Thiếu niên → Trưởng thành), Đệ tử & Hợp thể
- **Sư phụ (`Master Kael`):**
  1. Giao nhiệm vụ **The Captive Warrior** (hạ Boss `Prison Warden` `180 HP` ở phía đông Tàn tích, giải cứu con tin làm **Đệ tử**) → thưởng `200 Tinh Chất` + **Timeskip 3 năm** chuyển lên dạng **Thiếu niên (`teen`: `1.25x` sát thương, `1.1x` tốc độ, vóc dáng cao hơn)**.
  2. Giao nhiệm vụ **Path of Maturity** (hạ `2 Ruins Stalker`) → thưởng `300 Tinh Chất` + **Timeskip 4 năm** chuyển lên dạng **Trưởng thành (`adult`: `1.5x` sát thương, `1.2x` tốc độ)**.
- **Đệ tử (`Disciple`):** Đi theo Player, tự tấn công quái trong tầm `160 px` bằng `player_hitbox` (không gây sát thương lên Player).
- **Hợp thể (`Fusion` — phím `F`):** Yêu cầu đã có Đệ tử, tối thiểu `40 Ki` và hết hồi chiêu; kéo dài **`15s`** (tăng `2.2x` sát thương, `1.35x` tốc độ, hào quang tím-bạch kim riêng, không bị tụt máu), sau đó tách Đệ tử ra và hồi chiêu **`30s`**.
