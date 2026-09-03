# 项目运维管理系统 - API设计文档

## 系统概览

本文档详细描述项目运维管理系统的所有API接口，采用RESTful设计规范。

### 通用响应格式
所有API返回统一的JSON格式：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": { /* 具体数据 */ },
  "timestamp": "2024-01-01T10:00:00",
  "path": "/api/endpoint"
}
```

---

## 一、认证与授权 API

### 1.1 用户注册
**POST** `/api/auth/register`

**请求体:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "phone": "string",
  "realName": "string"
}
```

**响应:**
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "userId": 1,
    "username": "string",
    "email": "string"
  }
}
```

### 1.2 用户登录
**POST** `/api/auth/login`

**请求体:**
```json
{
  "username": "string",
  "password": "string"
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "token": "eyJhbGc...",
    "userId": 1,
    "username": "string",
    "realName": "string",
    "department": "string",
    "expiryTime": "2024-12-31T23:59:59"
  }
}
```

### 1.3 密码修改
**PUT** `/api/auth/password`

**请求体:**
```json
{
  "oldPassword": "string",
  "newPassword": "string"
}
```

**响应:** HTTP 200

---

## 二、项目安装管理 API

### 2.1 创建项目
**POST** `/api/installation/projects`

**请求体:**
```json
{
  "projectName": "string",
  "projectCode": "string",
  "customerName": "string",
  "customerContact": "string",
  "customerAddress": "string",
  "projectType": "新装",
  "totalAmount": 100000.00,
  "installUserId": 1,
  "scheduleStartDate": "2024-01-01",
  "scheduleEndDate": "2024-02-01"
}
```

### 2.2 获取项目列表
**GET** `/api/installation/projects?page=1&pageSize=10&status=规划`

**响应:**
```json
{
  "code": 200,
  "data": {
    "total": 100,
    "rows": [
      {
        "projectId": 1,
        "projectName": "string",
        "projectCode": "string",
        "customerName": "string",
        "installStatus": "规划"
      }
    ]
  }
}
```

### 2.3 创建工单
**POST** `/api/installation/orders`

**请求体:**
```json
{
  "projectId": 1,
  "orderNo": "string",
  "orderType": "安装",
  "assignUserId": 1,
  "priority": 3,
  "expectedHours": 8.5
}
```

### 2.4 记录施工进度
**POST** `/api/installation/records`

**请求体:**
```json
{
  "projectId": 1,
  "orderId": 1,
  "recordType": "日志",
  "content": "string",
  "workDate": "2024-01-01"
}
```

---

## 三、售后维护管理 API

### 3.1 创建售后工单
**POST** `/api/maintenance/orders`

**请求体:**
```json
{
  "projectId": 1,
  "orderNo": "string",
  "faultType": "硬件",
  "faultLevel": 3,
  "faultDescription": "string",
  "reportUserId": 1
}
```

### 3.2 记录故障诊断
**POST** `/api/maintenance/faults`

**请求体:**
```json
{
  "maintenanceId": 1,
  "faultPhenomenon": "string",
  "faultReason": "string",
  "diagnosisTime": "2024-01-01T14:00:00"
}
```

### 3.3 记录维修处理
**POST** `/api/maintenance/repairs`

**请求体:**
```json
{
  "maintenanceId": 1,
  "repairSolution": "string",
  "partsReplaced": ["part1"],
  "repairHours": 2.5,
  "testResult": "通过"
}
```

---

## 四、沟通协调管理 API

### 4.1 创建沟通记录
**POST** `/api/communication/records`

**请求体:**
```json
{
  "projectId": 1,
  "commNo": "string",
  "commType": "会议",
  "participants": [1, 2, 3],
  "topic": "string",
  "content": "string"
}
```

### 4.2 创建对接事项
**POST** `/api/coordination/docking-matters`

**请求体:**
```json
{
  "projectId": 1,
  "title": "string",
  "priority": 3,
  "ownerId": 1,
  "dueDate": "2024-02-01"
}
```

### 4.3 创建待办项
**POST** `/api/coordination/todos`

**请求体:**
```json
{
  "title": "string",
  "priority": 3,
  "dueDate": "2024-02-01"
}
```

---

## 五、AI文档生成 API（用户隔离）

### 5.1 生成日报
**POST** `/api/ai/daily-reports/generate`

**请求体:**
```json
{
  "reportDate": "2024-01-01"
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "reportId": 1,
    "generationStatus": "已生成",
    "workContent": "string",
    "workloadHours": 8.5,
    "achievements": "string"
  }
}
```

**权限:** 仅返回当前登录用户的日报

### 5.2 获取日报列表
**GET** `/api/ai/daily-reports?reportDate=2024-01-01`

**响应:** 仅返回当前用户的日报

### 5.3 生成月报
**POST** `/api/ai/monthly-reports/generate`

**请求体:**
```json
{
  "reportYear": 2024,
  "reportMonth": 1
}
```

**权限:** 仅返回当前登录用户的月报

### 5.4 生成年报
**POST** `/api/ai/annual-reports/generate`

**请求体:**
```json
{
  "reportYear": 2024,
  "generatePPT": true
}
```

**响应:**
```json
{
  "code": 200,
  "data": {
    "reportId": 1,
    "pptFilePath": "path/to/report.pptx",
    "pptDownloadUrl": "http://..."
  }
}
```

**权限:** 仅返回当前登录用户的年报和PPT

### 5.5 生成故障心得
**POST** `/api/ai/fault-summaries/generate`

**请求体:**
```json
{
  "faultId": 1
}
```

### 5.6 获取知识库文章（全量可见）
**GET** `/api/knowledge-base?category=故障&keywords=网络`

**权限:** 全部用户可见

### 5.7 评价知识库文章
**POST** `/api/knowledge-base/{kbId}/comments`

**请求体:**
```json
{
  "usefulness": 5,
  "commentContent": "string"
}
```

---

## 六、系统统计 API

### 6.1 个人工作统计（隔离）
**GET** `/api/statistics/personal?dateRange=2024-01-01,2024-01-31`

**响应:** 仅返回当前用户的统计数据

### 6.2 全局项目统计
**GET** `/api/statistics/projects`

**响应:**
```json
{
  "code": 200,
  "data": {
    "totalProjects": 100,
    "inProgressProjects": 30,
    "completedProjects": 65
  }
}
```

---

## 错误代码说明

| 代码 | 含义 | 说明 |
|------|------|------|
| 200 | 成功 | 请求成功 |
| 400 | 错误 | 请求参数错误 |
| 401 | 未授权 | 登录失效或令牌过期 |
| 403 | 禁止 | 无权限访问（如访问他人数据） |
| 404 | 不存在 | 资源不存在 |
| 500 | 错误 | 服务器内部错误 |

---

## 数据隔离规则

### ✅ 全量共享（所有用户可见）
- 项目列表和详情
- 工单和任务
- 故障记录
- 沟通协调内容
- 知识库文章

### 🔒 用户隔离（仅用户本人可见）
- 日报（daily_reports）
- 月报（monthly_reports）
- 年报（annual_reports）
- 个人统计数据

### 实现示例
```java
// ❌ 错误：返回所有用户的日报
@GetMapping("/daily-reports")
public List<DailyReport> getAllReports() {
    return dailyReportService.list();
}

// ✅ 正确：仅返回当前用户的日报
@GetMapping("/daily-reports")
public List<DailyReport> getMyReports() {
    Long userId = SecurityUtils.getCurrentUserId();
    return dailyReportService.listByUserId(userId);
}
```

