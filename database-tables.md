# 数据库表结构

## 说明

本项目数据库设计采用 **MySQL 8.0 SQL 类型**表示。实际项目使用微信云开发时，可以将这些表映射为云数据库集合。

字段表中的“键类型”含义如下：

- `PK`：主键（Primary Key）
- `FK`：外键（Foreign Key）
- `UK`：唯一键（Unique Key）
- `UK(C)`：联合唯一约束中的字段

## 1. `semesters`：学期表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 学期 ID |
| `semester_name` | VARCHAR(100) | 100 字符 | — | 是 | — | 学期名称 |
| `start_date` | DATE | YYYY-MM-DD | — | 是 | — | 学期开始日期 |
| `total_weeks` | TINYINT UNSIGNED | 0-255 | — | 否 | NULL | 学期总周数 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `active` | `active` 或 `ended` |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 2. `admins`：管理员表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 管理员 ID |
| `openid` | VARCHAR(64) | 64 字符 | UK | 是 | — | 微信用户身份标识 |
| `name` | VARCHAR(50) | 50 字符 | — | 否 | NULL | 管理员姓名或备注 |
| `role` | VARCHAR(20) | 20 字符 | — | 是 | `admin` | 管理员角色 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `active` | 启用或禁用 |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 3. `students`：学生表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 学生 ID |
| `student_no` | VARCHAR(20) | 20 字符 | UK | 是 | — | 学号 |
| `name` | VARCHAR(50) | 50 字符 | — | 是 | — | 学生姓名 |
| `class_name` | VARCHAR(100) | 100 字符 | — | 是 | — | 行政班级 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `active` | 正常或停用 |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 4. `courses`：课程表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 课程 ID |
| `course_code` | VARCHAR(30) | 30 字符 | UK(C) | 是 | — | 课程编号；与 `semester_id` 联合唯一 |
| `course_name` | VARCHAR(100) | 100 字符 | — | 是 | — | 课程名称 |
| `semester_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK(C) | 是 | — | 所属学期 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `active` | 启用或停用 |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 5. `course_sections`：课程班表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 课程班 ID |
| `course_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK(C) | 是 | — | 所属课程；与 `section_code` 联合唯一 |
| `section_code` | VARCHAR(30) | 30 字符 | UK(C) | 是 | — | 课程班编号 |
| `section_name` | VARCHAR(100) | 100 字符 | — | 是 | — | 课程班名称 |
| `teacher_name` | VARCHAR(50) | 50 字符 | — | 否 | NULL | 任课教师 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `active` | 启用或停用 |
| `created_by` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 创建管理员 |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 6. `section_schedules`：课程班上课安排表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 上课安排 ID |
| `section_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK(C) | 是 | — | 所属课程班；参与时间联合唯一 |
| `week_no` | TINYINT UNSIGNED | 大于 0 | UK(C) | 是 | — | 第几周 |
| `weekday` | TINYINT UNSIGNED | 1-7 | UK(C) | 是 | — | 星期几 |
| `period_start` | TINYINT UNSIGNED | 大于 0 | UK(C) | 是 | — | 开始节次 |
| `period_end` | TINYINT UNSIGNED | 不小于开始节次 | UK(C) | 是 | — | 结束节次 |
| `period_label` | VARCHAR(30) | 30 字符 | — | 是 | — | 例如“第 1-2 节” |
| `classroom` | VARCHAR(50) | 50 字符 | — | 否 | NULL | 教室 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `active` | 有效或停用 |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 7. `student_section_assignments`：学生课程班授权表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 关系记录 ID |
| `student_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK(C) | 是 | — | 学生 ID；与 `section_id` 联合唯一 |
| `course_id` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 课程 ID |
| `section_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK(C) | 是 | — | 课程班 ID |
| `assignment_type` | VARCHAR(20) | 20 字符 | — | 是 | `primary` | `primary` 默认班或 `alternative` 备用班 |
| `is_default` | BOOLEAN | 0 或 1 | — | 是 | FALSE | 是否默认课程班 |
| `valid_from` | DATE | YYYY-MM-DD | — | 否 | NULL | 授权开始日期 |
| `valid_to` | DATE | YYYY-MM-DD | — | 否 | NULL | 授权结束日期 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `active` | 有效或停用 |
| `created_by` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 授权管理员 |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 8. `attendance_sessions`：签到活动表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 签到活动 ID |
| `course_id` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 课程 ID |
| `section_id` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 课程班 ID |
| `schedule_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK | 是 | — | 对应上课安排，一个安排最多一个签到活动 |
| `session_name` | VARCHAR(100) | 100 字符 | — | 是 | — | 签到活动名称 |
| `latitude` | DECIMAL(10,7) | 总精度 10 位，小数 7 位；-90 至 90 | — | 是 | — | 本次活动的签到点纬度，GCJ-02 坐标 |
| `longitude` | DECIMAL(10,7) | 总精度 10 位，小数 7 位；-180 至 180 | — | 是 | — | 本次活动的签到点经度，GCJ-02 坐标 |
| `distance_limit` | DECIMAL(10,2) | 总精度 10 位，小数 2 位；大于 0 | — | 是 | 50.00 | 本次活动的距离阈值，单位米 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `draft` | `draft/open/closed` |
| `created_by` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 创建管理员 |
| `created_at` | DATETIME | — | — | 是 | 当前时间 | 创建时间 |
| `opened_at` | DATETIME | — | — | 否 | NULL | 开启时间 |
| `closed_at` | DATETIME | — | — | 否 | NULL | 关闭时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 9. `checkins`：签到记录表

| 字段 | SQL 类型 | 长度/范围 | 键类型 | 必填 | 默认值 | 说明 |
|---|---|---|---|---:|---|---|
| `id` | BIGINT UNSIGNED | 最大约 20 位 | PK | 是 | 自增 | 签到记录 ID |
| `session_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK(C) | 是 | — | 签到活动；与学生、设备形成联合唯一 |
| `course_id` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 课程 ID |
| `section_id` | BIGINT UNSIGNED | 最大约 20 位 | FK | 是 | — | 课程班 ID |
| `student_id` | BIGINT UNSIGNED | 最大约 20 位 | FK、UK(C) | 是 | — | 学生 ID；与签到活动形成联合唯一 |
| `student_no_snapshot` | VARCHAR(20) | 20 字符 | — | 是 | — | 签到时的学号快照 |
| `student_name_snapshot` | VARCHAR(50) | 50 字符 | — | 是 | — | 签到时的姓名快照 |
| `device_token` | VARCHAR(128) | 128 字符 | UK(C) | 是 | — | 设备标识；与签到活动形成联合唯一 |
| `latitude` | DECIMAL(10,7) | -90 至 90 | — | 是 | — | 学生签到纬度 |
| `longitude` | DECIMAL(10,7) | -180 至 180 | — | 是 | — | 学生签到经度 |
| `accuracy` | DECIMAL(10,2) | 大于等于 0 | — | 否 | NULL | 定位精度，单位米 |
| `distance` | DECIMAL(10,2) | 大于等于 0 | — | 是 | — | 与签到点距离，单位米 |
| `status` | VARCHAR(20) | 20 字符 | — | 是 | `valid` | `valid` 有效或 `deleted` 已删除 |
| `checked_in_at` | DATETIME | — | — | 是 | 当前时间 | 签到时间 |
| `updated_at` | DATETIME | — | — | 是 | 自动更新 | 修改时间 |

## 联合约束说明

| 表 | 联合约束 | 作用 |
|---|---|---|
| `courses` | `UNIQUE (semester_id, course_code)` | 同一学期内课程编号不能重复 |
| `course_sections` | `UNIQUE (course_id, section_code)` | 同一课程下课程班编号不能重复 |
| `section_schedules` | `UNIQUE (section_id, week_no, weekday, period_start, period_end)` | 同一课程班的同一时间安排不能重复 |
| `student_section_assignments` | `UNIQUE (student_id, section_id)` | 同一学生不能重复分配到同一课程班 |
| `attendance_sessions` | `UNIQUE (schedule_id)` | 一个上课安排最多对应一个签到活动 |
| `checkins` | `UNIQUE (session_id, student_id)` | 同一学生一次签到活动只能签到一次 |
| `checkins` | `UNIQUE (session_id, device_token)` | 同一设备一次签到活动只能签到一次 |

## 业务层约束

- 同一学生、同一课程只能有一个有效的默认课程班；该规则由业务代码检查。
- `student_section_assignments.section_id` 必须属于对应的 `course_id`。
- `attendance_sessions.course_id`、`section_id`、`schedule_id` 必须保持对应关系。
- 定位规则由教师在“签到活动管理”中设置，课程班表不保存签到点和距离阈值。
- 每个签到活动仅有一个签到点；不同签到活动可以设置不同的地点和阈值。
- 创建活动时填写签到点，距离阈值默认 50 米；未开放时可以修改，首次开启后锁定定位规则。
- 学生定位使用 GCJ-02，与活动签到点保持相同坐标系；`checkins.latitude/longitude` 保存学生实测位置。
- `checkins.distance` 按所属活动的签到点计算；通过签到校验的距离不得大于该活动的 `distance_limit`。
- 签到记录建议使用 `status = 'deleted'` 进行逻辑删除，不建议物理删除。
