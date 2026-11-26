# Game Design Document (GDD – V3 FINAL) — *GARO: Hành Trình Hoàng Kim*

**Tên dự án (tạm gọi):** *GARO: Hành Trình Hoàng Kim* (Saejima Kouga)  
**Engine & Kỹ thuật:** Godot `4.3-stable`, 2D Pixel Art (`960×540` viewport, `default_texture_filter = Nearest`)  
**Thể loại:** Hành động – Nhập vai (Action RPG), Chặt chém chiến thuật (Tactical Hack & Slash)  
**Cấu trúc vận hành:** Tuyến tính theo Hồi kết hợp **Hub & Mission** ở giai đoạn chính

---

## 1. Tầm nhìn & Trụ cột Thiết kế (Core Pillars)
- **Đồng điệu Tự sự – Cơ chế (Ludonarrative Harmony):** Sự trưởng thành của Saejima Kouga từ năm 8 tuổi đến khi trở thành Hoàng Kim Kỵ Sĩ được cảm nhận trực tiếp qua tay cầm và **thanh kiếm Garoken** (từ kiếm gỗ yếu ớt → cầm 2 tay nặng nề có độ trễ → xoay kiếm 1 tay sắc lẹm), không chỉ qua chỉ số hay cắt cảnh.
- **Áp lực Sinh tử 99.9 giây (Active Time Risk & Reward):** Bộ giáp Garo mang lại sức mạnh áp đảo nhưng vận hành như một quả bom hẹn giờ thực thụ. Thời gian không đứng yên để người chơi xả sát thương thoải mái mà bị bào mòn trực tiếp bởi sát thương nhận vào và kỹ năng cường hóa.
- **Phân hóa Vai trò Chiến đấu:** Tách bạch rõ giá trị của **Dạng Người** (tốc độ, dò điểm yếu, phản đòn) và **Dạng Giáp** (áp đảo, phá giai đoạn Boss), kết hợp hệ thống **Tà Khí (Inga)** và tuyến nhân vật phụ (**Kaoru**, **Zaruba**) trực tiếp vào vòng lặp chuẩn bị trước trận đánh.
- **Chiến lược Phát triển Solo Dev:** Dựng hoàn chỉnh **Vertical Slice Hồi 3** (với lõi `Human → Garo 99.9s → Tâm Diệt → Exhausted` + 1 Boss Horror) trước, sau đó mới mở rộng dần Hub & từng Hồi cốt truyện để tránh ngợp phạm vi.

---

## 2. Cấu trúc Cốt truyện & Nhịp độ 5 Giai đoạn (Lộ trình Dài hạn)
Tổng thời lượng game dồn **70%** trọng tâm vào giai đoạn trưởng thành (Hồi 3–4) để tránh khởi đầu chậm, trong khi vẫn giữ trọn sức nặng cảm xúc ở quá khứ của Kouga:

| Giai đoạn | Tỷ lệ & Thời lượng | Nhân vật & Cảm giác điều khiển | Nội dung cốt truyện chính | Cơ chế trọng tâm |
| :--- | :--- | :--- | :--- | :--- |
| **Prologue** *(Mở màn)* | **5%** *(5–10 phút)* | **Saejima Taiga** *(Mặc sẵn giáp Garo mắt đỏ)* | Đi săn Horror và chạm trán bước đầu với Barago. Tạo cú sốc tương phản trước khi chuyển sang Kouga 8 tuổi. | Combo mượt, né đòn và kết liễu; ẩn toàn bộ UI phức tạp (Tà Khí, đồng hồ, bật lửa). |
| **Hồi 1** *(Tuổi thơ)* | **10%** *(15–20 phút)* | **Kouga 8 tuổi** *(Kiếm gỗ ngắn, lực đánh yếu)* | Luyện tập khắc nghiệt cùng cha tại dinh thự. Đêm bi kịch: Taiga bị Barago (Kiba) sát hại trước mắt Kouga. | Di chuyển, né tránh, căn nhịp **Parry** qua bẫy Gonza; kết hồi bằng *scripted loss* với Barago. |
| **Hồi 2** *(Thiếu niên)* | **15%** *(30–45 phút)* | **Kouga 16 tuổi** *(Garoken cầm 2 tay, vung chậm, giật lùi khi đỡ)* | Rèn luyện trong cô độc, vượt thử thách Sở Phiên Khuyển và đối mặt Tâm Ma (ảo ảnh của cha). | Mở **Bật lửa Ma Đạo Hỏa**; lần đầu gọi giáp (`99.9s` trôi `2.0x` và trừ `5–10s` khi trúng đòn/vung chém nặng). |
| **Hồi 3** *(Trưởng thành)* | **50%** *(Trọng tâm)* | **Kouga 20+ tuổi** *(Garoken 1 tay điêu luyện + Full Giáp)* | Bảo vệ Khu Đông; gặp **Mitsuki Kaoru**, đối đầu **Suzumura Rei (Zero)** và đồng hành cùng pháp sư **Jabi**. | Vòng lặp **Hub & Mission**: Điều tra → Phá vỏ dạng người → Garo `99.9s` → Thanh tẩy kiếm → Buff Kaoru. |
| **Hồi 4** *(Cao trào)* | **20%** *(Đỉnh điểm)* | **Garo Hoàn thiện** *(Làm chủ Tâm Diệt + Dực Nhân Nha Lang)* | Âm mưu Tam Thần Quan nổ ra. Giải cứu Jabi, hạ thủy tổ **Messiah** tại Ma Giới và quyết đấu Barago. | Boss tốc độ cao (Kiba/Barago); màn cưỡi chiến mã **Gōten** & bay **Tsubasabito** dạng *Set-piece*. |

---

## 3. Hệ thống Bản đồ & Thiết kế Màn chơi (Dài hạn)
Thay thế thế giới mở bằng cấu trúc **1 Hub Trung Tâm + Các Map Nhiệm Vụ khép kín**:
1. **Dinh thự Saejima (Hub):** Sân tập (Hồi 1–2 phóng đại tỷ lệ cho Kouga 8t) → Căn cứ tác chiến trung tâm (Hồi 3–4): **Tượng Sói Thanh Tẩy** (rút Tà Khí `Inga`), **Góc vẽ của Kaoru** (nhận buff), **Sân tập & Thư viện**.
2. **Đô Thị Đêm — Khu Đông (Map Mission):** Bảo tàng nghệ thuật, Ga tàu điện ngầm, Cao ốc bỏ hoang (dùng Ma Đạo Hỏa quét vật chủ Horror → kéo vào kết giới chiến đấu).
3. **Rừng Ma Giới & Đền Thờ:** Giải đố ánh sáng lửa xanh Zaruba; môi trường chướng khí làm **Tà Khí (Inga)** tăng nhanh hơn.
4. **Tâm Cảnh (Đấu trường nội tâm):** Đấu ảo ảnh cha (Hồi 2) và chế độ luyện tập / **Boss Rush** (Hồi 3–4).
5. **Sở Phiên Khuyển, Lâu Đài Gương & Ma Giới:** Các màn tuyến tính cao trào cuối game (*Set-piece* Messiah & quyết đấu Barago).

---

## 4. Hệ thống Chiến đấu & Máy Trạng thái (Core Combat Specs — Hồi 3)

### 4.1. Máy Trạng thái 4 Pha của Saejima Kouga
| Trạng thái (`State`) | Vai trò chiến thuật | Thông số & Cơ chế vận hành | Điều kiện chuyển đổi |
| :--- | :--- | :--- | :--- |
| **1. `Human`** *(Dạng người)* | Thăm dò, phá ngụy trang, tích tài nguyên | Tốc độ `1.0×` (`~230 px/s`), khung **Parry** rộng. **Bật lửa Ma Đạo Hỏa (`K`):** đốt lớp vỏ bóng tối / lộ điểm yếu chí mạng Horror trong `5.0s`. Đánh trúng / Parry thành công tích thanh **Ý Chí (`0–100`)**. | Thanh Ý Chí đạt `100` + kích hoạt Triệu hồi (`L`) → **`GaroArmor`**. |
| **2. `GaroArmor`** *(Hoàng Kim Giáp)* | Bùng nổ sát thương, ép góc, phá Phase Boss | Đồng hồ đếm ngược **`99.9s`** (*Active Time Drain*): mặc định trôi `1.0×`. Bật **Viêm Nhận** (Zaruba thổi lửa xanh ngọc vào kiếm): sát thương tăng từ `2.2×` lên `3.0×`, đồng hồ trôi `1.8×`. Có *Super Armor*, ăn đòn trực diện bị **trừ thẳng `5.0s`**. | • Chủ động giải giáp (`L`) trước `00.0` → **`Human`** *(Ý Chí về `0`)*.<br>• Chạm `00.0` → **`LostSoulBeast`**. |
| **3. `LostSoulBeast`** *(Tâm Diệt Thú Thân)* | Sinh tử `10–12s`, sát thương cực đại, cấm lạm dụng | Sát thương **`3.5×`**, tốc độ đánh tăng vọt. Máu tự rút **`8% / giây`**, màn hình tối viền & nhiễu đỏ. Từ giây thứ `5`, **Zaruba** kích hoạt chuỗi **QTE** cứu mạng. | • Hạ Boss trước khi cạn máu → **Thắng**.<br>• Chuẩn QTE → **`Exhausted`**.<br>• Cạn HP / trượt QTE → **Game Over**. |
| **4. `Exhausted`** *(Kiệt sức)* | Án phạt chống lạm dụng Tâm Diệt, tạo sinh tồn | Trở về **`Human`**, máu tụt thẳng về **`1 HP`**. Thanh Ý Chí bị **khóa cứng `45s`**. **Thưởng kỹ năng:** mỗi cú **Perfect Parry** giảm ngay **`7s`** thời gian khóa giáp. | Hết thời gian khóa → **`Human`** *(mở lại tích Ý Chí)*. |

*(Lưu ý kỹ thuật Godot 2D: Điều khiển di chuyển cơ bản giữ nguyên nền `960×540` mượt mà: chạy `A/D`, nhảy `Space` có Coyote Time `6 ticks` + Jump Buffer `7 ticks`, lướt né `Shift` có `i-frames`, cận chiến `J` có Hitstop + Camera Shake.)*

### 4.2. Hệ thống Đồng hành & Chuẩn bị (Giai đoạn mở rộng Hub)
- **Ma Đạo Luân Zaruba:** Đồng hành cốt truyện & kỹ năng (*thoại hướng dẫn/cảnh báo Horror, kích lửa xanh **Viêm Nhận**, gọi **QTE** thoát Tâm Diệt*), không có Đệ tử chiến đấu hay `Fusion`.
- **Thanh Tà Khí (`Inga`, `0–100%`):** Tích tụ khi diệt Horror và tăng vọt nếu rơi vào *Tâm Diệt*. Tà Khí cao tăng nhẹ sát thương Garoken nhưng đẩy nhanh tốc độ tụt `99.9s` và tăng xác suất phục kích; có thể xả về `0%` tại **Tượng Sói Thanh Tẩy** ở Dinh thự.
- **Buff "Tĩnh Tâm" (Kaoru):** Trò chuyện / xem tranh tại Dinh thự cho buff 1 nhiệm vụ kế tiếp: làm chậm tốc độ tích `Inga` và **nới rộng cửa sổ QTE** khi thoát *Tâm Diệt* (vẫn giữ nguyên án phạt `1 HP` & khóa `45s`).

---

## 5. Đặc tả Bản mẫu Vertical Slice – Hồi 3 (Ưu tiên Thực thi Ngay)
Dự án **bắt buộc dựng bản mẫu từ Hồi 3 trước** để kiểm chứng lõi chiến đấu trước khi làm nội dung Hồi 1–2, Hub và Hồi 4:

| Trong phạm vi Vertical Slice (In-Scope) | Để sang Giai đoạn sau (Out-of-Scope) |
| :--- | :--- |
| 1 đấu trường phẳng khép kín + 1 Boss Horror hoàn chỉnh 2 Phase. | Hub Dinh thự Saejima, thư Sở Phiên Khuyển và Kaoru. |
| Đủ hành động Dạng Người: Chạy, Né (`i-frames`), **Parry**, combo 4 đòn, Bật lửa **Ma Đạo Hỏa (`K`)**. | Nhân vật Saejima Taiga, Kouga 8 tuổi và Kouga 16 tuổi. |
| Máy trạng thái 4 pha: `Human → GaroArmor (99.9s Active Drain) → LostSoulBeast (Tâm Diệt + QTE) → Exhausted (1 HP / khóa 45s / -7s Perfect Parry)`. | Thanh Tà Khí (`Inga`), Tượng Sói Thanh Tẩy và cây kỹ năng. |
| Hoàn thiện Game Feel: *hitstop*, rung màn hình, âm thanh va chạm Linh Kim, VFX lửa xanh Zaruba. | Màn *Set-piece* Gōten, Dực Nhân Nha Lang và cắt cảnh cốt truyện. |

- **Thiết kế Boss Horror đầu tiên (Vertical Slice):**
  - *Phase 1 (100% → 60% HP):* Lớp vỏ bóng tối giảm **70% sát thương vật lý**. Buộc dùng **Dạng Người** né/parry, hắt **Ma Đạo Hỏa** đốt vỏ (lộ điểm yếu `5s`) và tích đầy **Ý Chí (`100`)**.
  - *Phase 2 (60% → 0% HP):* Lộ bản thể quái vật với 4–5 chiêu diện rộng có báo hiệu (*telegraph*). Gọi **Giáp Garo**, tận dụng *Super Armor* + **Viêm Nhận** ép sát thương, chủ động giải giáp kịp trước khi Boss đánh tụt cạn `99.9s`.
- **Tiêu chuẩn cân bằng Mốc 3:** `1` trận Boss chuẩn cần gọi giáp **`~2 lần`**, và ít nhất **`1 lần` đồng hồ tụt xuống dưới `15s`** để chạm ranh giới *Tâm Diệt Thú Thân*.
