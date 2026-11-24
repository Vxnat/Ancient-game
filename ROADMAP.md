# Development Roadmap

Các cột mốc được chia theo hướng **Playable Milestones** (mỗi giai đoạn xong đều chơi thử được ngay).

## Phase 1: Nền tảng & Cảm giác điều khiển (Core Movement & Combat)
- [x] Khởi tạo cấu trúc dự án Godot 4.3-stable, Autoloads, Components, Data Resources.
- [x] Tạo `Player` scene với `StateMachine` (`Idle`, `Move`, `Jump`, `Fall`, `Dash`, `Attack`).
- [x] Tinh chỉnh **Game Feel**: thêm `Coyote Time`, `Jump Buffer` và `Hitstop` (khựng khung hình nhẹ khi chém trúng).
- [x] Gắn `HealthComponent`, `HitboxComponent`, `HurtboxComponent`, `WeaponComponent`.
- [x] Tạo 1 vũ khí mẫu (`WeaponData.tres`) có cơ chế trừ độ bền và tự chuyển về đánh tay khi độ bền = 0.
- [x] Tạo 1 quái thử nghiệm (`Training Dummy` / quái cơ bản) để test chém, nhận sát thương và rớt Tinh Chất.

## Phase 2: Hệ thống Khí, Tinh Chất & Thức Tỉnh (RPG Loop)
- [x] Kích hoạt `KiComponent` và trạng thái `Overdrive` + chiêu bắn chưởng (`combat/projectiles/`).
- [x] Xây dựng `HUD` cơ bản: Thanh Máu, thanh Khí, độ bền vũ khí, số lượng Tinh Chất.
- [x] Tạo trạm nghỉ (Checkpoint) + `Awakening Menu`: dùng Tinh Chất để Thức Tỉnh chỉ số (`SkillData.tres`) và sửa/nâng cấp vũ khí.
- [x] Kết nối `SaveManager` (dùng JSON Dictionary cấu trúc mở có `merge()` giữ field mặc định) để lưu/tải tiến trình mà không lỗi khi thêm Quest/Map ở Phase 3.

## Phase 3: Thế giới, Nhiệm vụ & MVP Metroidvania
- [x] Hoàn thiện map mở đầu `peaceful_village.tscn` với 1–2 NPC + `DialogueBox`.
- [x] Kết nối `QuestManager` với 1 nhiệm vụ đánh quái và 1 nhiệm vụ hạ Boss.
- [x] Tạo cổng chuyển cảnh (`SceneManager`) sang khu vực `ruins/` đầu tiên.
- [x] Tạo Boss đầu tiên rớt **Mảnh Lõi** mở khóa kỹ năng mới (VD: `Air-Dash`).

## Phase 4: Mở rộng Cốt truyện & Tính năng Đặc thù
- [x] Hệ thống `FormData.tres`: Chuyển đổi nhân vật qua 3 giai đoạn **Nhỏ → Thiếu niên → Trưởng thành** kèm sự kiện **Timeskip** từ Sư phụ (`MasterNPC`).
- [x] Nhiệm vụ giải cứu con tin (`PrisonWarden` + `CaptiveAlly`) để thu nhận **Đệ tử (`entities/allies/disciple.tscn`)** hỗ trợ đánh quái.
- [x] Cơ chế **Hợp thể (Fusion)** giữa Player và Đệ tử (`15s` hiệu lực, `30s` hồi chiêu, hào quang riêng).
- [x] Polish VFX (`combat/vfx/hit_spark.tscn`), Audio (`AudioManager`), và UI Menus (`Main Menu`, `Pause Menu`).
