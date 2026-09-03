-- 项目运维管理系统 SQL 建表脚本
-- 数据库编码: UTF-8
-- 创建日期: 2024

-- =====================================================
-- 1. 用户账号体系
-- =====================================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户唯一标识',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希值',
    phone VARCHAR(20) UNIQUE COMMENT '电话号码',
    real_name VARCHAR(50) COMMENT '真实姓名',
    department VARCHAR(100) COMMENT '部门',
    position VARCHAR(50) COMMENT '职位',
    avatar_url VARCHAR(255) COMMENT '头像URL',
    status TINYINT DEFAULT 1 COMMENT '账户状态(0禁用,1正常)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    KEY idx_username (username),
    KEY idx_email (email),
    KEY idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 用户会话表
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id VARCHAR(255) PRIMARY KEY COMMENT '会话ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    token VARCHAR(500) NOT NULL UNIQUE COMMENT 'JWT令牌',
    login_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    expiry_time DATETIME NOT NULL COMMENT '过期时间',
    ip_address VARCHAR(50) COMMENT '登录IP',
    user_agent VARCHAR(255) COMMENT '用户代理信息',
    status TINYINT DEFAULT 1 COMMENT '会话状态(0已过期,1活跃)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    KEY idx_user_id (user_id),
    KEY idx_login_time (login_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户会话表';

-- =====================================================
-- 2. 项目安装管理模块
-- =====================================================

-- 安装项目表
CREATE TABLE IF NOT EXISTS installation_projects (
    project_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '项目唯一标识',
    project_name VARCHAR(200) NOT NULL COMMENT '项目名称',
    project_code VARCHAR(50) NOT NULL UNIQUE COMMENT '项目编码',
    customer_name VARCHAR(100) NOT NULL COMMENT '客户名称',
    customer_contact VARCHAR(20) COMMENT '客户联系电话',
    customer_address VARCHAR(255) COMMENT '客户地址',
    project_type VARCHAR(50) COMMENT '项目类型(新装/升级)',
    total_amount DECIMAL(12,2) COMMENT '合同总额',
    install_user_id BIGINT COMMENT '安装负责人',
    install_status VARCHAR(20) DEFAULT '规划' COMMENT '安装状态(规划/进行中/已完成)',
    schedule_start_date DATE COMMENT '计划开始日期',
    schedule_end_date DATE COMMENT '计划结束日期',
    actual_start_date DATE COMMENT '实际开始日期',
    actual_end_date DATE COMMENT '实际结束日期',
    description TEXT COMMENT '项目描述',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    FOREIGN KEY (install_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_project_code (project_code),
    KEY idx_install_user_id (install_user_id),
    KEY idx_install_status (install_status),
    KEY idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='安装项目表';

-- 安装工单表
CREATE TABLE IF NOT EXISTS installation_orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '工单唯一标识',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    order_no VARCHAR(50) NOT NULL UNIQUE COMMENT '工单编号',
    order_type VARCHAR(30) NOT NULL COMMENT '工单类型(安装/调试/测试)',
    assign_user_id BIGINT COMMENT '分配给用户',
    priority TINYINT DEFAULT 3 COMMENT '优先级(1-5)',
    status VARCHAR(20) DEFAULT '待处理' COMMENT '状态(待处理/进行中/已完成)',
    description TEXT COMMENT '工单描述',
    expected_hours DECIMAL(5,2) COMMENT '预计工时',
    actual_hours DECIMAL(5,2) COMMENT '实际工时',
    start_time DATETIME COMMENT '开始时间',
    end_time DATETIME COMMENT '完成时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (assign_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_order_no (order_no),
    KEY idx_project_id (project_id),
    KEY idx_assign_user_id (assign_user_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='安装工单表';

-- 实施记录表
CREATE TABLE IF NOT EXISTS installation_records (
    record_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录唯一标识',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    order_id BIGINT COMMENT '工单ID',
    record_type VARCHAR(30) NOT NULL COMMENT '记录类型(日志/进度/问题)',
    content TEXT NOT NULL COMMENT '实施内容',
    work_date DATE NOT NULL COMMENT '工作日期',
    worker_id BIGINT COMMENT '执行人',
    attachments VARCHAR(500) COMMENT '附件路径(JSON数组)',
    status VARCHAR(20) DEFAULT '已提交' COMMENT '状态(草稿/已提交)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES installation_orders(order_id) ON DELETE SET NULL,
    FOREIGN KEY (worker_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_project_id (project_id),
    KEY idx_order_id (order_id),
    KEY idx_worker_id (worker_id),
    KEY idx_work_date (work_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='实施记录表';

-- 进度跟踪表
CREATE TABLE IF NOT EXISTS installation_progress (
    progress_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '进度唯一标识',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    milestone_name VARCHAR(100) NOT NULL COMMENT '里程碑名称',
    planned_date DATE NOT NULL COMMENT '计划完成日期',
    actual_date DATE COMMENT '实际完成日期',
    completion_rate TINYINT DEFAULT 0 COMMENT '完成度(%)(0-100)',
    status VARCHAR(20) DEFAULT '未开始' COMMENT '状态(未开始/进行中/已完成)',
    description TEXT COMMENT '描述说明',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    KEY idx_project_id (project_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='进度跟踪表';

-- 资料归档表
CREATE TABLE IF NOT EXISTS installation_documents (
    doc_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '资料唯一标识',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    doc_name VARCHAR(200) NOT NULL COMMENT '文档名称',
    doc_type VARCHAR(50) NOT NULL COMMENT '文档类型(合同/需求/设计/验收)',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小(字节)',
    upload_user_id BIGINT COMMENT '上传人',
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传日期',
    archive_status VARCHAR(20) DEFAULT '临时' COMMENT '归档状态(临时/已归档)',
    remark TEXT COMMENT '备注',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (upload_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_project_id (project_id),
    KEY idx_doc_type (doc_type),
    KEY idx_archive_status (archive_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='资料归档表';

-- =====================================================
-- 3. 售后维护管理模块
-- =====================================================

-- 售后工单表
CREATE TABLE IF NOT EXISTS maintenance_orders (
    maintenance_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '工单唯一标识',
    order_no VARCHAR(50) NOT NULL UNIQUE COMMENT '工单编号',
    project_id BIGINT COMMENT '关联项目ID',
    fault_type VARCHAR(50) NOT NULL COMMENT '故障类型(硬件/软件/网络)',
    fault_level TINYINT DEFAULT 3 COMMENT '故障等级(1-5)',
    fault_description TEXT NOT NULL COMMENT '故障描述',
    report_user_id BIGINT COMMENT '报障人',
    report_time DATETIME NOT NULL COMMENT '报障时间',
    assign_user_id BIGINT COMMENT '分配给(维修人)',
    acceptance_time DATETIME COMMENT '受理时间',
    completion_time DATETIME COMMENT '完成时间',
    status VARCHAR(20) DEFAULT '待分配' COMMENT '状态(待分配/进行中/已完成/已关闭)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE SET NULL,
    FOREIGN KEY (report_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (assign_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_order_no (order_no),
    KEY idx_project_id (project_id),
    KEY idx_status (status),
    KEY idx_assign_user_id (assign_user_id),
    KEY idx_report_time (report_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='售后工单表';

-- 故障记录表
CREATE TABLE IF NOT EXISTS fault_records (
    fault_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '故障记录ID',
    maintenance_id BIGINT NOT NULL COMMENT '售后工单ID',
    fault_phenomenon TEXT NOT NULL COMMENT '故障现象',
    fault_reason TEXT COMMENT '故障原因',
    fault_impact TEXT COMMENT '故障影响范围',
    discovery_time DATETIME COMMENT '发现时间',
    diagnosis_time DATETIME COMMENT '诊断完成时间',
    diagnosis_user_id BIGINT COMMENT '诊断人',
    attachments VARCHAR(500) COMMENT '附件(截图/日志等)',
    status VARCHAR(20) DEFAULT '待诊断' COMMENT '状态(待诊断/诊断中/已诊断)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (maintenance_id) REFERENCES maintenance_orders(maintenance_id) ON DELETE CASCADE,
    FOREIGN KEY (diagnosis_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_maintenance_id (maintenance_id),
    KEY idx_diagnosis_user_id (diagnosis_user_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='故障记录表';

-- 维修处理表
CREATE TABLE IF NOT EXISTS repair_records (
    repair_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '维修记录ID',
    maintenance_id BIGINT NOT NULL COMMENT '售后工单ID',
    repair_solution TEXT NOT NULL COMMENT '修复方案',
    parts_replaced VARCHAR(500) COMMENT '更换配件(JSON数组)',
    repair_hours DECIMAL(5,2) COMMENT '维修工时',
    repair_start_time DATETIME COMMENT '维修开始时间',
    repair_end_time DATETIME COMMENT '维修完成时间',
    repair_user_id BIGINT COMMENT '维修人员',
    test_result VARCHAR(20) COMMENT '测试结果(通过/失败)',
    remark TEXT COMMENT '备注说明',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (maintenance_id) REFERENCES maintenance_orders(maintenance_id) ON DELETE CASCADE,
    FOREIGN KEY (repair_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_maintenance_id (maintenance_id),
    KEY idx_repair_user_id (repair_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维修处理表';

-- 回访记录表
CREATE TABLE IF NOT EXISTS maintenance_followup (
    followup_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '回访记录ID',
    maintenance_id BIGINT NOT NULL COMMENT '售后工单ID',
    followup_date DATE NOT NULL COMMENT '回访日期',
    followup_user_id BIGINT COMMENT '回访人',
    customer_feedback TEXT COMMENT '客户反馈',
    satisfaction_score TINYINT COMMENT '满意度(1-5)',
    system_status VARCHAR(20) COMMENT '系统状态(正常/异常)',
    next_followup_date DATE COMMENT '下次回访日期',
    remark TEXT COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (maintenance_id) REFERENCES maintenance_orders(maintenance_id) ON DELETE CASCADE,
    FOREIGN KEY (followup_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_maintenance_id (maintenance_id),
    KEY idx_followup_user_id (followup_user_id),
    KEY idx_followup_date (followup_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='回访记录表';

-- 维护台账表
CREATE TABLE IF NOT EXISTS maintenance_ledger (
    ledger_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '台账记录ID',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    maintenance_id BIGINT COMMENT '售后工单ID',
    service_date DATE NOT NULL COMMENT '服务日期',
    service_type VARCHAR(50) NOT NULL COMMENT '服务类型(巡检/维护/升级)',
    service_user_id BIGINT COMMENT '服务人员',
    service_content TEXT COMMENT '服务内容',
    service_hours DECIMAL(5,2) COMMENT '服务工时',
    materials_used VARCHAR(500) COMMENT '使用物料(JSON数组)',
    next_service_date DATE COMMENT '下次服务日期',
    remark TEXT COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (maintenance_id) REFERENCES maintenance_orders(maintenance_id) ON DELETE SET NULL,
    FOREIGN KEY (service_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_project_id (project_id),
    KEY idx_service_date (service_date),
    KEY idx_service_type (service_type),
    KEY idx_service_user_id (service_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='维护台账表';

-- =====================================================
-- 4. 沟通协调管理模块
-- =====================================================

-- 工作沟通记录表
CREATE TABLE IF NOT EXISTS communication_records (
    comm_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '沟通记录ID',
    comm_no VARCHAR(50) NOT NULL UNIQUE COMMENT '沟通编号',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    comm_type VARCHAR(30) NOT NULL COMMENT '沟通类型(电话/邮件/会议/现场)',
    participants VARCHAR(500) NOT NULL COMMENT '参与人(JSON数组)',
    comm_date DATETIME NOT NULL COMMENT '沟通日期',
    initiator_id BIGINT COMMENT '发起人',
    topic VARCHAR(200) NOT NULL COMMENT '沟通主题',
    content TEXT NOT NULL COMMENT '沟通内容',
    attachments VARCHAR(500) COMMENT '附件路径(JSON数组)',
    status VARCHAR(20) DEFAULT '已记录' COMMENT '状态(已记录/已归档)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (initiator_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_comm_no (comm_no),
    KEY idx_project_id (project_id),
    KEY idx_comm_type (comm_type),
    KEY idx_initiator_id (initiator_id),
    KEY idx_comm_date (comm_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工作沟通记录表';

-- 对接事项表
CREATE TABLE IF NOT EXISTS docking_matters (
    matter_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '事项唯一标识',
    matter_no VARCHAR(50) NOT NULL UNIQUE COMMENT '事项编号',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    title VARCHAR(200) NOT NULL COMMENT '事项标题',
    description TEXT COMMENT '事项描述',
    priority TINYINT DEFAULT 3 COMMENT '优先级(1-5)',
    owner_id BIGINT COMMENT '负责人',
    related_user_ids VARCHAR(500) COMMENT '关联人员(JSON数组)',
    due_date DATE NOT NULL COMMENT '截止日期',
    status VARCHAR(20) DEFAULT '待进行' COMMENT '状态(待进行/进行中/已完成/已延期)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_matter_no (matter_no),
    KEY idx_project_id (project_id),
    KEY idx_owner_id (owner_id),
    KEY idx_status (status),
    KEY idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='对接事项表';

-- 待办跟进表
CREATE TABLE IF NOT EXISTS todo_items (
    todo_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '待办唯一标识',
    user_id BIGINT NOT NULL COMMENT '待办人员',
    related_id BIGINT COMMENT '关联ID(工单/项目等)',
    related_type VARCHAR(30) COMMENT '关联类型',
    title VARCHAR(200) NOT NULL COMMENT '待办标题',
    description TEXT COMMENT '待办描述',
    priority TINYINT DEFAULT 3 COMMENT '优先级(1-5)',
    due_date DATE NOT NULL COMMENT '截止日期',
    status VARCHAR(20) DEFAULT '待完成' COMMENT '状态(待完成/进行中/已完成/已取消)',
    progress TINYINT DEFAULT 0 COMMENT '进度(%)(0-100)',
    attachments VARCHAR(500) COMMENT '附件(JSON数组)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    created_by BIGINT COMMENT '创建人',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_user_id (user_id),
    KEY idx_status (status),
    KEY idx_due_date (due_date),
    KEY idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='待办跟进表';

-- 往来纪要存档表
CREATE TABLE IF NOT EXISTS meeting_minutes (
    minute_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '纪要唯一标识',
    minute_no VARCHAR(50) NOT NULL UNIQUE COMMENT '纪要编号',
    project_id BIGINT NOT NULL COMMENT '项目ID',
    meeting_date DATETIME NOT NULL COMMENT '会议日期',
    meeting_title VARCHAR(200) NOT NULL COMMENT '会议主题',
    attendees VARCHAR(500) NOT NULL COMMENT '参会人员(JSON数组)',
    host_id BIGINT COMMENT '主持人',
    content TEXT NOT NULL COMMENT '会议内容',
    decisions TEXT COMMENT '会议决议',
    action_items TEXT COMMENT '行动项(JSON)',
    next_meeting_date DATE COMMENT '下次会议日期',
    archive_status VARCHAR(20) DEFAULT '草稿' COMMENT '归档状态(草稿/已发布/已归档)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (project_id) REFERENCES installation_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (host_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_minute_no (minute_no),
    KEY idx_project_id (project_id),
    KEY idx_meeting_date (meeting_date),
    KEY idx_archive_status (archive_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='往来纪要存档表';

-- =====================================================
-- 5. AI文档生成模块
-- =====================================================

-- 日报表（用户隔离）
CREATE TABLE IF NOT EXISTS daily_reports (
    report_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日报唯一标识',
    user_id BIGINT NOT NULL COMMENT '报告人',
    report_date DATE NOT NULL COMMENT '报告日期',
    work_content TEXT COMMENT '工作内容(AI生成)',
    work_summary TEXT COMMENT '工作总结(AI生成)',
    workload_hours DECIMAL(5,2) COMMENT '工作工时统计(AI生成)',
    achievements TEXT COMMENT '工作成果(AI生成)',
    problems TEXT COMMENT '存在问题(AI生成)',
    next_plan TEXT COMMENT '下一步计划(AI生成)',
    manual_edit TEXT COMMENT '手工编辑内容',
    generation_status VARCHAR(20) DEFAULT '待生成' COMMENT '生成状态(待生成/已生成/已审核)',
    approval_user_id BIGINT COMMENT '审批人',
    approval_date DATETIME COMMENT '审批时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (approval_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE KEY uk_user_date (user_id, report_date),
    KEY idx_report_date (report_date),
    KEY idx_generation_status (generation_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='日报表';

-- 月报表（用户隔离）
CREATE TABLE IF NOT EXISTS monthly_reports (
    report_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '月报唯一标识',
    user_id BIGINT NOT NULL COMMENT '报告人',
    report_year SMALLINT NOT NULL COMMENT '报告年份',
    report_month TINYINT NOT NULL COMMENT '报告月份(1-12)',
    work_content TEXT COMMENT '工作内容(AI生成)',
    work_summary TEXT COMMENT '工作总结(AI生成)',
    total_workload DECIMAL(6,2) COMMENT '累计工时(AI统计)',
    major_achievements TEXT COMMENT '主要成果(AI生成)',
    key_projects TEXT COMMENT '重点项目(AI提取)',
    problem_analysis TEXT COMMENT '问题分析(AI生成)',
    improvement_plan TEXT COMMENT '改进计划(AI生成)',
    manual_edit TEXT COMMENT '手工编辑内容',
    generation_status VARCHAR(20) DEFAULT '待生成' COMMENT '生成状态(待生成/已生成/已审核)',
    approval_user_id BIGINT COMMENT '审批人',
    approval_date DATETIME COMMENT '审批时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (approval_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE KEY uk_user_month (user_id, report_year, report_month),
    KEY idx_report_year (report_year),
    KEY idx_report_month (report_month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='月报表';

-- 年报表（用户隔离）
CREATE TABLE IF NOT EXISTS annual_reports (
    report_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '年报唯一标识',
    user_id BIGINT NOT NULL COMMENT '报告人',
    report_year SMALLINT NOT NULL COMMENT '报告年份',
    executive_summary TEXT COMMENT '执行摘要(AI生成)',
    annual_overview TEXT COMMENT '年度概览(AI生成)',
    major_achievements TEXT COMMENT '重大成就(AI提取)',
    projects_completed TEXT COMMENT '已完成项目(AI统计)',
    total_workload DECIMAL(8,2) COMMENT '年度工时统计(AI计算)',
    innovation_points TEXT COMMENT '创新亮点(AI总结)',
    problem_summary TEXT COMMENT '问题总结(AI分析)',
    department_comparison TEXT COMMENT '部门对标(AI对比)',
    next_year_plan TEXT COMMENT '下年计划(AI建议)',
    ppt_file_path VARCHAR(500) COMMENT 'PPT文件路径',
    manual_edit TEXT COMMENT '手工编辑内容',
    generation_status VARCHAR(20) DEFAULT '待生成' COMMENT '生成状态(待生成/已生成/已审核)',
    approval_user_id BIGINT COMMENT '审批人',
    approval_date DATETIME COMMENT '审批时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (approval_user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE KEY uk_user_year (user_id, report_year),
    KEY idx_report_year (report_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='年报表';

-- 故障心得表
CREATE TABLE IF NOT EXISTS fault_summaries (
    summary_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '心得唯一标识',
    fault_id BIGINT NOT NULL COMMENT '对应故障ID',
    author_id BIGINT COMMENT '作者',
    fault_title VARCHAR(200) COMMENT '故障标题(AI提取)',
    fault_phenomenon TEXT COMMENT '故障现象(AI复盘)',
    root_cause TEXT COMMENT '根本原因(AI分析)',
    solution_summary TEXT COMMENT '解决方案(AI总结)',
    prevention_measures TEXT COMMENT '预防措施(AI建议)',
    experience_points TEXT COMMENT '经验要点(AI提炼)',
    similar_cases VARCHAR(500) COMMENT '类似案例(关联ID)',
    manual_edit TEXT COMMENT '手工编辑内容',
    status VARCHAR(20) DEFAULT '草稿' COMMENT '状态(草稿/已发布/已归档)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (fault_id) REFERENCES fault_records(fault_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_fault_id (fault_id),
    KEY idx_author_id (author_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='故障心得表';

-- 知识库表
CREATE TABLE IF NOT EXISTS knowledge_base (
    kb_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '知识库文章ID',
    kb_no VARCHAR(50) NOT NULL UNIQUE COMMENT '知识编号',
    category VARCHAR(50) NOT NULL COMMENT '分类(故障/经验/技巧)',
    subcategory VARCHAR(50) COMMENT '子分类',
    title VARCHAR(200) NOT NULL COMMENT '标题',
    content LONGTEXT NOT NULL COMMENT '内容',
    keywords VARCHAR(500) COMMENT '关键词(逗号分隔)',
    source_type VARCHAR(30) NOT NULL COMMENT '来源类型(故障/心得/手工)',
    source_id BIGINT COMMENT '来源ID',
    related_fault_ids VARCHAR(500) COMMENT '关联故障(JSON数组)',
    related_articles VARCHAR(500) COMMENT '关联文章(JSON数组)',
    views_count INT DEFAULT 0 COMMENT '浏览次数',
    usefulness_score DECIMAL(3,2) COMMENT '有用度评分(0-5)',
    created_by BIGINT COMMENT '创建人',
    publish_date DATETIME COMMENT '发布日期',
    compile_month VARCHAR(7) NOT NULL COMMENT '汇总月份(YYYY-MM)',
    archive_status VARCHAR(20) DEFAULT '草稿' COMMENT '归档状态(草稿/已发布)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_kb_no (kb_no),
    KEY idx_category (category),
    KEY idx_keywords (keywords),
    KEY idx_publish_date (publish_date),
    KEY idx_compile_month (compile_month),
    KEY idx_archive_status (archive_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库表';

-- 知识库评论表
CREATE TABLE IF NOT EXISTS knowledge_base_comments (
    comment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评论ID',
    kb_id BIGINT NOT NULL COMMENT '知识库文章ID',
    user_id BIGINT NOT NULL COMMENT '评论人',
    usefulness TINYINT COMMENT '有用度(1-5)',
    comment_content TEXT COMMENT '评论内容',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (kb_id) REFERENCES knowledge_base(kb_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    KEY idx_kb_id (kb_id),
    KEY idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库评论表';

-- =====================================================
-- 6. 系统日志和审计表
-- =====================================================

-- 操作日志表
CREATE TABLE IF NOT EXISTS operation_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id BIGINT COMMENT '操作人',
    module_name VARCHAR(100) COMMENT '模块名称',
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型(增/删/改/查)',
    object_type VARCHAR(50) COMMENT '对象类型',
    object_id BIGINT COMMENT '对象ID',
    old_value LONGTEXT COMMENT '修改前的值',
    new_value LONGTEXT COMMENT '修改后的值',
    ip_address VARCHAR(50) COMMENT '操作IP',
    operation_result VARCHAR(20) COMMENT '操作结果(成功/失败)',
    error_msg TEXT COMMENT '错误信息',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    KEY idx_user_id (user_id),
    KEY idx_operation_type (operation_type),
    KEY idx_object_type (object_type),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- =====================================================
-- 数据库初始化完成
-- =====================================================
