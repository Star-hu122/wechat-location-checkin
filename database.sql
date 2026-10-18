-- 微信小程序定位签到系统数据库设计
-- SQL 方言：MySQL 8.0
-- 说明：签到记录采用逻辑删除，避免删除后同一学生或设备再次签到。
-- 签到点及距离阈值按签到活动配置；课程班不保存定位规则。

CREATE TABLE semesters (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    semester_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    total_weeks TINYINT UNSIGNED NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT chk_semesters_status CHECK (status IN ('active', 'ended'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE admins (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    openid VARCHAR(64) NOT NULL,
    name VARCHAR(50) NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'admin',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_admins_openid (openid),
    CONSTRAINT chk_admins_role CHECK (role = 'admin'),
    CONSTRAINT chk_admins_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE students (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_no VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    class_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_students_student_no (student_no),
    CONSTRAINT chk_students_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE courses (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    course_code VARCHAR(30) NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    semester_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_courses_semester_code (semester_id, course_code),
    KEY idx_courses_status (status),
    CONSTRAINT fk_courses_semester
        FOREIGN KEY (semester_id) REFERENCES semesters (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_courses_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE course_sections (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    course_id BIGINT UNSIGNED NOT NULL,
    section_code VARCHAR(30) NOT NULL,
    section_name VARCHAR(100) NOT NULL,
    teacher_name VARCHAR(50) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_course_sections_code (course_id, section_code),
    KEY idx_course_sections_status (status),
    CONSTRAINT fk_course_sections_course
        FOREIGN KEY (course_id) REFERENCES courses (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_course_sections_creator
        FOREIGN KEY (created_by) REFERENCES admins (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_course_sections_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE section_schedules (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    section_id BIGINT UNSIGNED NOT NULL,
    week_no TINYINT UNSIGNED NOT NULL,
    weekday TINYINT UNSIGNED NOT NULL,
    period_start TINYINT UNSIGNED NOT NULL,
    period_end TINYINT UNSIGNED NOT NULL,
    period_label VARCHAR(30) NOT NULL,
    classroom VARCHAR(50) NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_section_schedules_slot
        (section_id, week_no, weekday, period_start, period_end),
    KEY idx_section_schedules_weekday (week_no, weekday),
    CONSTRAINT fk_section_schedules_section
        FOREIGN KEY (section_id) REFERENCES course_sections (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_section_schedules_week_no CHECK (week_no > 0),
    CONSTRAINT chk_section_schedules_weekday CHECK (weekday BETWEEN 1 AND 7),
    CONSTRAINT chk_section_schedules_periods CHECK (period_start > 0 AND period_end >= period_start),
    CONSTRAINT chk_section_schedules_status CHECK (status IN ('active', 'disabled'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE student_section_assignments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NOT NULL,
    assignment_type VARCHAR(20) NOT NULL DEFAULT 'primary',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    valid_from DATE NULL,
    valid_to DATE NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_student_section_assignment (student_id, section_id),
    KEY idx_assignments_student_course (student_id, course_id),
    KEY idx_assignments_section (section_id),
    CONSTRAINT fk_assignments_student
        FOREIGN KEY (student_id) REFERENCES students (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_assignments_course
        FOREIGN KEY (course_id) REFERENCES courses (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_assignments_section
        FOREIGN KEY (section_id) REFERENCES course_sections (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_assignments_creator
        FOREIGN KEY (created_by) REFERENCES admins (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_assignments_type CHECK (assignment_type IN ('primary', 'alternative')),
    CONSTRAINT chk_assignments_status CHECK (status IN ('active', 'disabled')),
    CONSTRAINT chk_assignments_dates CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to >= valid_from)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attendance_sessions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    course_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NOT NULL,
    schedule_id BIGINT UNSIGNED NOT NULL,
    session_name VARCHAR(100) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL COMMENT '本次签到活动的签到点纬度',
    longitude DECIMAL(10,7) NOT NULL COMMENT '本次签到活动的签到点经度',
    distance_limit DECIMAL(10,2) NOT NULL DEFAULT 50.00 COMMENT '本次签到活动的距离阈值，单位米',
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    opened_at DATETIME NULL,
    closed_at DATETIME NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_attendance_sessions_schedule (schedule_id),
    KEY idx_attendance_sessions_section_status (section_id, status),
    CONSTRAINT fk_attendance_sessions_course
        FOREIGN KEY (course_id) REFERENCES courses (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attendance_sessions_section
        FOREIGN KEY (section_id) REFERENCES course_sections (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attendance_sessions_schedule
        FOREIGN KEY (schedule_id) REFERENCES section_schedules (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_attendance_sessions_creator
        FOREIGN KEY (created_by) REFERENCES admins (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_attendance_sessions_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_attendance_sessions_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_attendance_sessions_distance CHECK (distance_limit > 0),
    CONSTRAINT chk_attendance_sessions_status CHECK (status IN ('draft', 'open', 'closed')),
    CONSTRAINT chk_attendance_sessions_dates CHECK (closed_at IS NULL OR opened_at IS NULL OR closed_at >= opened_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE checkins (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    session_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    section_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    student_no_snapshot VARCHAR(20) NOT NULL,
    student_name_snapshot VARCHAR(50) NOT NULL,
    device_token VARCHAR(128) NOT NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(10,7) NOT NULL,
    accuracy DECIMAL(10,2) NULL,
    distance DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'valid',
    checked_in_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_checkins_session_student (session_id, student_id),
    UNIQUE KEY uk_checkins_session_device (session_id, device_token),
    KEY idx_checkins_course_section (course_id, section_id),
    KEY idx_checkins_student (student_id),
    CONSTRAINT fk_checkins_session
        FOREIGN KEY (session_id) REFERENCES attendance_sessions (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_checkins_course
        FOREIGN KEY (course_id) REFERENCES courses (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_checkins_section
        FOREIGN KEY (section_id) REFERENCES course_sections (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_checkins_student
        FOREIGN KEY (student_id) REFERENCES students (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_checkins_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_checkins_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_checkins_accuracy CHECK (accuracy IS NULL OR accuracy >= 0),
    CONSTRAINT chk_checkins_distance CHECK (distance >= 0),
    CONSTRAINT chk_checkins_status CHECK (status IN ('valid', 'deleted'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 业务层还需保证：
-- 1. 同一学生、同一课程只能有一个 active 的默认课程班。
-- 2. student_section_assignments 中的 section_id 必须属于 course_id。
-- 3. 同一课程班同时只能有一个 status = 'open' 的签到活动。
-- 4. 修改签到记录时建议使用 status = 'deleted'，不要物理删除。
-- 5. 每次签到活动仅设置一个签到点，经纬度使用统一坐标系 GCJ-02。
-- 6. 定位规则在未开放时配置和修改；活动首次开启后锁定，保留历史判断依据。
-- 7. checkins.latitude/longitude 为学生实测坐标；distance 按所属活动的签到点计算，且不大于其 distance_limit。
