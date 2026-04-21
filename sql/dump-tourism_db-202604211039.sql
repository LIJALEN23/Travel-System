-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: tourism_db
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `abroad_travel`
--

DROP TABLE IF EXISTS `abroad_travel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `abroad_travel` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '出境游ID',
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `team_name` varchar(100) NOT NULL COMMENT '境外团队名称',
  `country` varchar(50) DEFAULT NULL COMMENT '目的地国家',
  `visa_status` varchar(20) DEFAULT '待审核' COMMENT '签证状态 待审核/通过/驳回',
  `apply_time` datetime DEFAULT NULL COMMENT '申请时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `abroad_travel_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='出境游业务审核表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `abroad_travel`
--

LOCK TABLES `abroad_travel` WRITE;
/*!40000 ALTER TABLE `abroad_travel` DISABLE KEYS */;
INSERT INTO `abroad_travel` VALUES (1,1,'泰国曼谷6日游','泰国','通过','2025-01-10 09:00:00','2026-04-15 15:32:12','2026-04-15 15:32:12'),(2,1,'日本东京7日游','日本','通过','2025-01-12 10:00:00','2026-04-15 15:32:12','2026-04-20 09:43:24'),(3,2,'法国巴黎10日游','法国','通过','2025-01-11 14:00:00','2026-04-15 15:32:12','2026-04-15 15:32:12'),(4,1,'欧洲十日游','法国','待审核','2025-01-01 10:00:00','2026-04-15 16:06:02','2026-04-15 16:06:02'),(5,1,'欧洲十日游','法国','待审核','2025-01-01 10:00:00','2026-04-20 09:43:30','2026-04-20 09:43:30');
/*!40000 ALTER TABLE `abroad_travel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agency_credit`
--

DROP TABLE IF EXISTS `agency_credit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agency_credit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `credit_score` int NOT NULL DEFAULT '100' COMMENT '诚信分 100分制',
  `total_complaint` int DEFAULT '0' COMMENT '总投诉数',
  `bad_complaint` int DEFAULT '0' COMMENT '严重投诉',
  `credit_desc` text COMMENT '诚信评价',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `agency_id` (`agency_id`),
  UNIQUE KEY `uk_agency_id` (`agency_id`),
  CONSTRAINT `agency_credit_FK` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅行社诚信档案表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agency_credit`
--

LOCK TABLES `agency_credit` WRITE;
/*!40000 ALTER TABLE `agency_credit` DISABLE KEYS */;
INSERT INTO `agency_credit` VALUES (1,1,95,1,0,NULL,'2026-04-18 14:42:41'),(2,2,70,2,2,NULL,'2026-04-18 15:03:45');
/*!40000 ALTER TABLE `agency_credit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agency_emergency`
--

DROP TABLE IF EXISTS `agency_emergency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agency_emergency` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `rescuer_name` varchar(50) NOT NULL COMMENT '救援人员姓名',
  `rescuer_phone` varchar(20) DEFAULT NULL COMMENT '救援电话',
  `vehicle_no` varchar(50) NOT NULL COMMENT '救援车牌号',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `agency_emergency_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅行社应急救援表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agency_emergency`
--

LOCK TABLES `agency_emergency` WRITE;
/*!40000 ALTER TABLE `agency_emergency` DISABLE KEYS */;
INSERT INTO `agency_emergency` VALUES (1,1,'王二小','18000001111','川A99999','2026-04-15 15:32:07'),(2,2,'利斯韦','18000002222','川A88888','2026-04-15 15:32:07');
/*!40000 ALTER TABLE `agency_emergency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agency_manager`
--

DROP TABLE IF EXISTS `agency_manager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agency_manager` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `work_no` varchar(50) NOT NULL COMMENT '工号',
  `manager_name` varchar(50) NOT NULL COMMENT '姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `post` varchar(50) DEFAULT NULL COMMENT '职务',
  `status` int DEFAULT '1' COMMENT '1在职 0离职',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_work_no` (`work_no`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `agency_manager_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅行社管理人员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agency_manager`
--

LOCK TABLES `agency_manager` WRITE;
/*!40000 ALTER TABLE `agency_manager` DISABLE KEYS */;
INSERT INTO `agency_manager` VALUES (1,1,'M001','刘强','13800001111','总经理',1,'2026-04-15 15:31:59'),(2,1,'M002','王丽','13800002222','运营总监',1,'2026-04-15 15:31:59'),(3,2,'M003','陈明','13800003333','总经理',1,'2026-04-15 15:31:59'),(4,2,'M004','赵燕','13800004444','计调主管',1,'2026-04-15 15:31:59');
/*!40000 ALTER TABLE `agency_manager` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agency_real_time_data`
--

DROP TABLE IF EXISTS `agency_real_time_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agency_real_time_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `today_teams` int DEFAULT '0' COMMENT '今日发团数',
  `today_people` int DEFAULT '0' COMMENT '今日出游人数',
  `online_vehicles` int DEFAULT '0' COMMENT '在线车辆数',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `agency_real_time_data_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅行社实时运行数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agency_real_time_data`
--

LOCK TABLES `agency_real_time_data` WRITE;
/*!40000 ALTER TABLE `agency_real_time_data` DISABLE KEYS */;
INSERT INTO `agency_real_time_data` VALUES (1,1,5,120,2,'2026-04-15 15:32:09'),(2,2,3,80,2,'2026-04-15 15:32:09');
/*!40000 ALTER TABLE `agency_real_time_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alert_handle`
--

DROP TABLE IF EXISTS `alert_handle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alert_handle` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `alert_id` bigint NOT NULL COMMENT '对应告警ID',
  `handle_result` varchar(500) NOT NULL COMMENT '处理结果',
  `handler` varchar(50) NOT NULL COMMENT '处理人',
  `handle_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='告警处理登记表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alert_handle`
--

LOCK TABLES `alert_handle` WRITE;
/*!40000 ALTER TABLE `alert_handle` DISABLE KEYS */;
INSERT INTO `alert_handle` VALUES (1,1,'已联系景区处理完毕','王五','2026-04-18 10:31:29');
/*!40000 ALTER TABLE `alert_handle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `alert_message`
--

DROP TABLE IF EXISTS `alert_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alert_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `msg_type` varchar(32) NOT NULL COMMENT 'prompt=提示信息 alert=告警信息',
  `content` varchar(500) NOT NULL COMMENT '当前问题描述',
  `status` int DEFAULT '0' COMMENT '0=待审核 1=审核通过(待发布) 2=已发布 3=已处置',
  `operator` varchar(50) DEFAULT NULL COMMENT '值班员',
  `leader` varchar(50) DEFAULT NULL COMMENT '审批领导',
  `ext_info` varchar(50) DEFAULT NULL COMMENT '关联标识（SCENE_1/HOTEL_1，用于去重）',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='告警提示信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alert_message`
--

LOCK TABLES `alert_message` WRITE;
/*!40000 ALTER TABLE `alert_message` DISABLE KEYS */;
INSERT INTO `alert_message` VALUES (7,'prompt','成都青城山：车位紧张(86%)，缆车等待过久(45分钟)',0,NULL,NULL,'SCENE_1','2026-04-18 11:12:58','2026-04-18 11:13:18'),(8,'prompt','青城山豪生国际酒店：入住率过高(87.5%)',0,NULL,NULL,'HOTEL_1','2026-04-18 11:12:58','2026-04-18 11:13:18');
/*!40000 ALTER TABLE `alert_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaint`
--

DROP TABLE IF EXISTS `complaint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `complaint` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '投诉ID',
  `complaint_no` varchar(32) NOT NULL COMMENT '投诉单号 TS+时间戳',
  `visitor_name` varchar(50) NOT NULL COMMENT '游客姓名',
  `visitor_phone` varchar(20) NOT NULL COMMENT '游客电话',
  `title` varchar(100) NOT NULL COMMENT '投诉标题',
  `content` text NOT NULL COMMENT '投诉详情',
  `agency_id` bigint DEFAULT NULL COMMENT '被投诉旅行社ID',
  `guide_id` bigint DEFAULT NULL COMMENT '被投诉导游ID',
  `level` varchar(20) DEFAULT '一般' COMMENT '投诉等级：一般/较重/严重',
  `handle_user` varchar(50) DEFAULT NULL COMMENT '首问处理人',
  `handle_result` text COMMENT '处理结果',
  `handle_time` datetime DEFAULT NULL COMMENT '处理时间',
  `status` varchar(20) DEFAULT '待处理' COMMENT '待处理/处理中/已办结/驳回',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_agency_id` (`agency_id`),
  KEY `idx_guide_id` (`guide_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `complaint_FK` FOREIGN KEY (`guide_id`) REFERENCES `guide` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `complaint_FK_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='游客投诉管理表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaint`
--

LOCK TABLES `complaint` WRITE;
/*!40000 ALTER TABLE `complaint` DISABLE KEYS */;
INSERT INTO `complaint` VALUES (4,'TS202604188C125B','游客王五','13800138001','导游服务态度差投诉','导游服务态度差，未按约定讲解景点',1,1,'一般','管理员','已联系游客道歉并补偿，游客满意','2026-04-18 14:42:41','已办结','2026-04-18 14:42:21','2026-04-18 14:42:41'),(5,'TS202604188F65AA','游客李四','13800138002','导游擅自改变行程','擅自减少景点，压缩游览时间',2,2,'较重','管理员','已核实处理','2026-04-18 15:03:32','已办结','2026-04-18 14:56:47','2026-04-18 15:03:32'),(6,'TS20260418D9D85D','游客王五','13800138003','导游强制消费、态度恶劣','强制购物，辱骂游客，严重违反规范',2,2,'严重','管理员','已核实处理','2026-04-18 15:03:46','已办结','2026-04-18 14:56:50','2026-04-18 15:03:45');
/*!40000 ALTER TABLE `complaint` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guide`
--

DROP TABLE IF EXISTS `guide`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '导游ID',
  `agency_id` bigint DEFAULT NULL COMMENT '所属旅行社ID NULL=自由工作者',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `gender` char(1) DEFAULT NULL COMMENT '性别 男/女',
  `age` int DEFAULT NULL COMMENT '年龄',
  `id_card` varchar(18) NOT NULL COMMENT '身份证号',
  `phone` varchar(20) NOT NULL COMMENT '联系电话',
  `guide_level` varchar(20) DEFAULT NULL COMMENT '导游等级 初级/中级/高级/特级',
  `work_status` int DEFAULT '0' COMMENT '执业状态 0-待业 1-在职 2-冻结',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_id_card` (`id_card`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `guide_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导游基础信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guide`
--

LOCK TABLES `guide` WRITE;
/*!40000 ALTER TABLE `guide` DISABLE KEYS */;
INSERT INTO `guide` VALUES (1,1,'李四','男',35,'510123199001011234','13700137000','中级',1,'2026-04-17 14:33:34','2026-04-18 14:42:41'),(2,2,'梵谷有','男',26,'511527200002221853','13778978592','初级',1,'2026-04-17 14:41:16','2026-04-18 15:03:45');
/*!40000 ALTER TABLE `guide` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guide_credit`
--

DROP TABLE IF EXISTS `guide_credit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_credit` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `guide_id` bigint NOT NULL COMMENT '导游ID（关联 guide 表）',
  `credit_score` int NOT NULL DEFAULT '100' COMMENT '导游诚信分（100分制）',
  `total_complaint` int DEFAULT '0' COMMENT '导游总投诉次数',
  `bad_complaint` int DEFAULT '0' COMMENT '严重/不良投诉次数',
  `credit_desc` text COMMENT '诚信评价说明',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `guide_id` (`guide_id`),
  UNIQUE KEY `uk_guide_id` (`guide_id`),
  CONSTRAINT `guide_credit_FK` FOREIGN KEY (`guide_id`) REFERENCES `guide` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导游诚信档案表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guide_credit`
--

LOCK TABLES `guide_credit` WRITE;
/*!40000 ALTER TABLE `guide_credit` DISABLE KEYS */;
INSERT INTO `guide_credit` VALUES (3,1,95,1,0,NULL,'2026-04-18 14:42:41'),(4,2,70,2,2,NULL,'2026-04-18 15:03:45');
/*!40000 ALTER TABLE `guide_credit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guide_job_apply`
--

DROP TABLE IF EXISTS `guide_job_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_job_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `guide_id` bigint NOT NULL COMMENT '求职导游',
  `agency_id` bigint NOT NULL COMMENT '应聘旅行社',
  `apply_status` int DEFAULT '0' COMMENT '0-待审核 1-录用 2-未录用',
  `apply_remark` varchar(500) DEFAULT NULL COMMENT '应聘说明',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `guide_id` (`guide_id`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `guide_job_apply_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guide` (`id`),
  CONSTRAINT `guide_job_apply_ibfk_2` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导游求职申请表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guide_job_apply`
--

LOCK TABLES `guide_job_apply` WRITE;
/*!40000 ALTER TABLE `guide_job_apply` DISABLE KEYS */;
INSERT INTO `guide_job_apply` VALUES (1,1,1,1,'经验丰富，同意录用','2026-04-17 14:44:11','2026-04-17 14:48:50');
/*!40000 ALTER TABLE `guide_job_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guide_order_apply`
--

DROP TABLE IF EXISTS `guide_order_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_order_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '申领ID',
  `guide_id` bigint NOT NULL COMMENT '申领导游',
  `agency_id` bigint NOT NULL COMMENT '所属旅行社',
  `order_id` bigint NOT NULL COMMENT '关联行程单ID',
  `apply_status` int NOT NULL DEFAULT '0' COMMENT '0-待审批 1-通过 2-拒绝',
  `apply_reason` varchar(500) DEFAULT NULL COMMENT '申领原因',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '审批时间',
  PRIMARY KEY (`id`),
  KEY `guide_id` (`guide_id`),
  KEY `agency_id` (`agency_id`),
  KEY `guide_order_apply_FK` (`order_id`),
  CONSTRAINT `guide_order_apply_FK` FOREIGN KEY (`order_id`) REFERENCES `travel_order` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `guide_order_apply_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guide` (`id`),
  CONSTRAINT `guide_order_apply_ibfk_2` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导游行程单申领表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guide_order_apply`
--

LOCK TABLES `guide_order_apply` WRITE;
/*!40000 ALTER TABLE `guide_order_apply` DISABLE KEYS */;
INSERT INTO `guide_order_apply` VALUES (2,1,1,1,1,'审核通过，同意分配行程单','2026-04-17 16:23:18','2026-04-17 16:32:43');
/*!40000 ALTER TABLE `guide_order_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guide_qualification`
--

DROP TABLE IF EXISTS `guide_qualification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_qualification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `guide_id` bigint NOT NULL COMMENT '导游ID',
  `qualification_no` varchar(50) NOT NULL COMMENT '导游资格证号',
  `issue_date` date DEFAULT NULL COMMENT '发证日期',
  `expire_date` date DEFAULT NULL COMMENT '到期日期',
  `check_status` int DEFAULT '0' COMMENT '资格审核状态 0-待审核 1-通过 2-驳回',
  `check_remark` varchar(500) DEFAULT NULL COMMENT '审核意见',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `guide_id` (`guide_id`),
  CONSTRAINT `guide_qualification_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guide` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导游资格审核表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guide_qualification`
--

LOCK TABLES `guide_qualification` WRITE;
/*!40000 ALTER TABLE `guide_qualification` DISABLE KEYS */;
INSERT INTO `guide_qualification` VALUES (1,1,'D123456789','2020-01-01','2025-12-31',1,'资料齐全，审核通过','2026-04-17 14:43:14');
/*!40000 ALTER TABLE `guide_qualification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guide_real_time`
--

DROP TABLE IF EXISTS `guide_real_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_real_time` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `guide_id` bigint NOT NULL COMMENT '导游ID',
  `order_id` bigint DEFAULT NULL COMMENT '当前行程单ID',
  `team_size` int DEFAULT '0' COMMENT '当前带团人数',
  `longitude` decimal(12,6) DEFAULT NULL COMMENT '经度',
  `latitude` decimal(12,6) DEFAULT NULL COMMENT '纬度',
  `work_status` varchar(20) DEFAULT '空闲' COMMENT '工作状态 空闲/带团中/休息',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_guide` (`guide_id`),
  KEY `guide_real_time_FK` (`order_id`),
  CONSTRAINT `guide_real_time_FK` FOREIGN KEY (`order_id`) REFERENCES `travel_order` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `guide_real_time_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guide` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导游实时状态信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guide_real_time`
--

LOCK TABLES `guide_real_time` WRITE;
/*!40000 ALTER TABLE `guide_real_time` DISABLE KEYS */;
INSERT INTO `guide_real_time` VALUES (1,1,1,2,103.819800,30.663800,'带团中','2026-04-17 16:43:04');
/*!40000 ALTER TABLE `guide_real_time` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_base`
--

DROP TABLE IF EXISTS `hotel_base`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_base` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `hotel_name` varchar(100) NOT NULL COMMENT '饭店名称',
  `star_level` int DEFAULT NULL COMMENT '星级 3/4/5',
  `max_capacity` int DEFAULT NULL COMMENT '最大接待量',
  `total_parking` int DEFAULT NULL COMMENT '停车位数量',
  `address` varchar(255) DEFAULT NULL COMMENT '详细地址',
  `longitude` decimal(10,6) DEFAULT NULL COMMENT '经度',
  `latitude` decimal(10,6) DEFAULT NULL COMMENT '纬度',
  `status` int DEFAULT '1' COMMENT '状态 1正常 0关闭',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='饭店基础信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_base`
--

LOCK TABLES `hotel_base` WRITE;
/*!40000 ALTER TABLE `hotel_base` DISABLE KEYS */;
INSERT INTO `hotel_base` VALUES (1,'青城山豪生国际酒店',5,800,300,'四川省成都市都江堰市青城山镇青城山路88号',103.608900,30.901200,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(2,'青城后山泰安会馆',4,300,120,'四川省成都市都江堰市青城山镇泰安古镇',103.612500,30.905800,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(3,'青城山六善酒店',5,200,80,'四川省成都市都江堰市青城山镇大三路222号',103.607700,30.900500,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(4,'青城道温泉酒店',4,400,150,'四川省成都市都江堰市青城山镇豪生路33号',103.609200,30.900900,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(5,'广汉三星堆博物馆酒店',4,350,180,'四川省德阳市广汉市西安路133号',104.217900,30.994200,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(6,'广汉华美达安可酒店',3,280,100,'四川省德阳市广汉市中山大道南一段',104.220100,30.989500,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(7,'广汉西园大酒店',4,450,200,'四川省德阳市广汉市中山大道北一段',104.218800,30.991000,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(8,'都江堰古城智选假日酒店',4,320,120,'四川省成都市都江堰市幸福路88号',103.631200,31.003500,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(9,'都江堰青城豪生度假酒店',5,700,280,'四川省成都市都江堰市公园路6号',103.630500,31.003000,1,'2026-04-15 15:13:50','2026-04-15 15:13:50'),(10,'都江堰熊猫基地酒店',3,250,90,'四川省成都市都江堰市玉堂镇熊猫大道',103.628800,31.001800,1,'2026-04-15 15:13:50','2026-04-15 15:13:50');
/*!40000 ALTER TABLE `hotel_base` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_emergency`
--

DROP TABLE IF EXISTS `hotel_emergency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_emergency` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `hotel_id` bigint NOT NULL COMMENT '饭店ID',
  `rescuer_name` varchar(50) NOT NULL COMMENT '救援人员名字',
  `rescuer_phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `vehicle_no` varchar(50) NOT NULL COMMENT '车牌号',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `hotel_id` (`hotel_id`),
  CONSTRAINT `hotel_emergency_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotel_base` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='饭店应急救援表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_emergency`
--

LOCK TABLES `hotel_emergency` WRITE;
/*!40000 ALTER TABLE `hotel_emergency` DISABLE KEYS */;
INSERT INTO `hotel_emergency` VALUES (1,1,'张灿','1555555555','川Q5638','2026-04-20 15:56:30');
/*!40000 ALTER TABLE `hotel_emergency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_manager`
--

DROP TABLE IF EXISTS `hotel_manager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_manager` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `hotel_id` bigint NOT NULL COMMENT '饭店ID',
  `work_no` varchar(50) NOT NULL COMMENT '工号',
  `manager_name` varchar(50) NOT NULL COMMENT '姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `post` varchar(50) DEFAULT NULL COMMENT '职务',
  `status` int DEFAULT '1' COMMENT '1在职 0离职',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_work_no` (`work_no`),
  KEY `hotel_id` (`hotel_id`),
  CONSTRAINT `hotel_manager_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotel_base` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='饭店管理人员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_manager`
--

LOCK TABLES `hotel_manager` WRITE;
/*!40000 ALTER TABLE `hotel_manager` DISABLE KEYS */;
INSERT INTO `hotel_manager` VALUES (1,1,'0001','吴淞','18888888','大堂经理',1,'2026-04-20 15:55:56');
/*!40000 ALTER TABLE `hotel_manager` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_real_time_data`
--

DROP TABLE IF EXISTS `hotel_real_time_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_real_time_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `hotel_id` bigint NOT NULL COMMENT '饭店ID',
  `current_visitors` int DEFAULT '0' COMMENT '当前入住人数',
  `remaining_parking` int DEFAULT '0' COMMENT '剩余车位',
  `occupancy_rate` decimal(5,2) DEFAULT '0.00' COMMENT '入住率 %',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `hotel_id` (`hotel_id`),
  CONSTRAINT `hotel_real_time_data_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotel_base` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='饭店实时运行数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_real_time_data`
--

LOCK TABLES `hotel_real_time_data` WRITE;
/*!40000 ALTER TABLE `hotel_real_time_data` DISABLE KEYS */;
INSERT INTO `hotel_real_time_data` VALUES (1,1,700,10,87.50,'2026-04-18 10:43:38');
/*!40000 ALTER TABLE `hotel_real_time_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hotel_scenic_relation`
--

DROP TABLE IF EXISTS `hotel_scenic_relation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hotel_scenic_relation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID',
  `hotel_id` bigint NOT NULL COMMENT '酒店ID（关联hotel_base.id）',
  `scenic_id` bigint NOT NULL COMMENT '景区ID（关联scenic_spot.id）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_hotel_scenic` (`hotel_id`,`scenic_id`),
  KEY `fk_relation_scenic_id` (`scenic_id`),
  CONSTRAINT `fk_relation_hotel_id` FOREIGN KEY (`hotel_id`) REFERENCES `hotel_base` (`id`),
  CONSTRAINT `fk_relation_scenic_id` FOREIGN KEY (`scenic_id`) REFERENCES `scenic_spot` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='酒店-景区关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hotel_scenic_relation`
--

LOCK TABLES `hotel_scenic_relation` WRITE;
/*!40000 ALTER TABLE `hotel_scenic_relation` DISABLE KEYS */;
INSERT INTO `hotel_scenic_relation` VALUES (1,1,1,'2026-04-15 15:14:57','2026-04-15 15:14:57'),(2,2,1,'2026-04-15 15:14:57','2026-04-15 15:14:57'),(3,3,1,'2026-04-15 15:14:57','2026-04-15 15:14:57'),(4,4,1,'2026-04-15 15:14:57','2026-04-15 15:14:57'),(5,5,2,'2026-04-15 15:15:02','2026-04-15 15:15:02'),(6,6,2,'2026-04-15 15:15:02','2026-04-15 15:15:02'),(7,7,2,'2026-04-15 15:15:02','2026-04-15 15:15:02'),(8,8,3,'2026-04-15 15:15:04','2026-04-15 15:15:04'),(9,9,3,'2026-04-15 15:15:04','2026-04-15 15:15:04'),(10,10,3,'2026-04-15 15:15:04','2026-04-15 15:15:04'),(11,9,1,'2026-04-15 15:15:06','2026-04-15 15:15:06');
/*!40000 ALTER TABLE `hotel_scenic_relation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenic_emergency`
--

DROP TABLE IF EXISTS `scenic_emergency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scenic_emergency` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `spot_id` bigint NOT NULL COMMENT '景区ID',
  `rescuer_name` varchar(50) NOT NULL COMMENT '救援人员名字',
  `rescuer_phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `vehicle_no` varchar(50) NOT NULL COMMENT '车牌号',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `spot_id` (`spot_id`),
  CONSTRAINT `scenic_emergency_ibfk_1` FOREIGN KEY (`spot_id`) REFERENCES `scenic_spot` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='景区应急救援表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenic_emergency`
--

LOCK TABLES `scenic_emergency` WRITE;
/*!40000 ALTER TABLE `scenic_emergency` DISABLE KEYS */;
INSERT INTO `scenic_emergency` VALUES (1,1,'李四','110','川A8828','2026-04-13 14:48:24');
/*!40000 ALTER TABLE `scenic_emergency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenic_manager`
--

DROP TABLE IF EXISTS `scenic_manager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scenic_manager` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `spot_id` bigint NOT NULL COMMENT '景区ID',
  `work_no` varchar(50) NOT NULL COMMENT '工号',
  `manager_name` varchar(50) NOT NULL COMMENT '姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `post` varchar(50) DEFAULT NULL COMMENT '职务',
  `status` int DEFAULT '1' COMMENT '1在职 0离职',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_work_no` (`work_no`),
  KEY `spot_id` (`spot_id`),
  CONSTRAINT `scenic_manager_ibfk_1` FOREIGN KEY (`spot_id`) REFERENCES `scenic_spot` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='景区管理人员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenic_manager`
--

LOCK TABLES `scenic_manager` WRITE;
/*!40000 ALTER TABLE `scenic_manager` DISABLE KEYS */;
INSERT INTO `scenic_manager` VALUES (1,1,'001','王五','151','景区总负责人',1,'2026-04-13 14:49:30');
/*!40000 ALTER TABLE `scenic_manager` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenic_real_time_data`
--

DROP TABLE IF EXISTS `scenic_real_time_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scenic_real_time_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `spot_id` bigint NOT NULL COMMENT '景区ID',
  `current_visitors` int DEFAULT '0' COMMENT '当前游客',
  `remaining_parking` int DEFAULT '0' COMMENT '剩余车位',
  `cable_wait_time` int DEFAULT '0' COMMENT '缆车等候时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `spot_id` (`spot_id`),
  CONSTRAINT `scenic_real_time_data_ibfk_1` FOREIGN KEY (`spot_id`) REFERENCES `scenic_spot` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='景区实时运行数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenic_real_time_data`
--

LOCK TABLES `scenic_real_time_data` WRITE;
/*!40000 ALTER TABLE `scenic_real_time_data` DISABLE KEYS */;
INSERT INTO `scenic_real_time_data` VALUES (1,1,6000,200,45,'2026-04-18 09:49:27');
/*!40000 ALTER TABLE `scenic_real_time_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scenic_spot`
--

DROP TABLE IF EXISTS `scenic_spot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scenic_spot` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '景区ID',
  `spot_name` varchar(100) NOT NULL COMMENT '景区名称',
  `max_capacity` int NOT NULL COMMENT '最大容客量',
  `total_parking` int NOT NULL COMMENT '总停车位',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `longitude` decimal(12,8) DEFAULT NULL COMMENT '经度',
  `latitude` decimal(12,8) DEFAULT NULL COMMENT '纬度',
  `map_url` varchar(500) DEFAULT NULL COMMENT '电子地图URL/路径',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='景区基础信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenic_spot`
--

LOCK TABLES `scenic_spot` WRITE;
/*!40000 ALTER TABLE `scenic_spot` DISABLE KEYS */;
INSERT INTO `scenic_spot` VALUES (1,'成都青城山',8000,1500,'四川省成都市都江堰市青城山镇',103.60970000,30.90080000,'https://map.baidu.com/search/%E9%9D%92%E5%9F%8E%E5%B1%B1/@11522792.168508157,3601089.56354765,14.28z?querytype=s&da_src=shareurl&wd=%E9%9D%92%E5%9F%8E%E5%B1%B1&c=1&src=0&wd2=%E6%88%90%E9%83%BD%E5%B8%82%E9%83%BD%E6%B1%9F%E5%A0%B0%E5%B8%82&pn=0&sug=1&l=13&b=(-21344.3903,-8681.0992;27551.6097,14742.9008)&from=webmap&biz_forward=%7B%22scaler%22:2,%22styles%22:%22pl%22%7D&sug_forward=f446091835d1e46bb11e3619&device_ratio=2','2026-04-13 14:46:02','2026-04-13 14:46:02'),(2,'三星堆博物馆',1000,500,'四川省德阳市广汉市西安路 133 号',104.21830000,30.99390000,'https://map.baidu.com/search/%E4%B8%89%E6%98%9F%E5%A0%86%E5%8D%9A%E7%89%A9%E9%A6%86/@11602223.890776822,3611449.8938056,18.02z?querytype=s&da_src=shareurl&wd=%E4%B8%89%E6%98%9F%E5%A0%86%E5%8D%9A%E7%89%A9%E9%A6%86&c=75&src=0&wd2=%E5%BE%B7%E9%98%B3%E5%B8%82%E5%B9%BF%E6%B1%89%E5%B8%82&pn=0&sug=1&l=13&b=(11538680,3575460;11587576,3598884)&from=webmap&biz_forward=%7B%22scaler%22:2,%22styles%22:%22pl%22%7D&sug_forward=fb56c9dc72c033721b94c61b&device_ratio=2','2026-04-15 14:44:03','2026-04-15 14:44:03'),(3,'都江堰景区',10000,2500,'四川省成都市都江堰市公园路',103.63070000,31.00330000,'https://map.baidu.com/search/%E9%83%BD%E6%B1%9F%E5%A0%B0/@11533800.92096895,3609304.48610525,14.49z?querytype=s&da_src=shareurl&wd=%E9%83%BD%E6%B1%9F%E5%A0%B0&c=74&src=0&pn=0&sug=0&l=18&b=(11601470.315071827,3611088.887643259;11602977.466481818,3611810.8999679405)&from=webmap&biz_forward=%7B%22scaler%22:2,%22styles%22:%22pl%22%7D&device_ratio=2','2026-04-15 14:45:05','2026-04-15 14:45:05');
/*!40000 ALTER TABLE `scenic_spot` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `account` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(100) NOT NULL COMMENT '登录密码(可加密)',
  `real_name` varchar(50) NOT NULL COMMENT '真实姓名',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `role` varchar(20) NOT NULL DEFAULT 'OPERATOR' COMMENT '角色 ADMIN/OPERATOR',
  `status` tinyint DEFAULT '1' COMMENT '状态 1-正常 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`account`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,'student','$2a$10$M85jZs1ORE3GWqJl/OHiWuXmXOuu464crBn1nHX8KzKWhW/g/gjQm','张三','13800138000','test@qq.com','user',1,'2026-04-13 09:43:19','2026-04-13 09:43:19','注册测试'),(2,'silver','$2a$10$DAFrEqa3o0IQkuYH1TBhuenbSgG04PWm0Q02j7cArlE8o8xk6xFOW','钟亚南','18208286050','1508129596@qq.com','OPERATOR',1,'2026-04-20 10:32:56','2026-04-20 10:32:56','');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tourism_vehicle`
--

DROP TABLE IF EXISTS `tourism_vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tourism_vehicle` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '车辆ID',
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `plate_no` varchar(20) NOT NULL COMMENT '车牌号',
  `vehicle_type` varchar(30) DEFAULT NULL COMMENT '车辆类型',
  `seat_count` int DEFAULT NULL COMMENT '座位数',
  `vehicle_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '正常' COMMENT '车况 正常/维修/报废/使用中',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_plate_no` (`plate_no`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `tourism_vehicle_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅游车辆信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tourism_vehicle`
--

LOCK TABLES `tourism_vehicle` WRITE;
/*!40000 ALTER TABLE `tourism_vehicle` DISABLE KEYS */;
INSERT INTO `tourism_vehicle` VALUES (1,1,'川A12345','大型客车',55,'正常','2026-04-15 15:32:05','2026-04-15 15:32:05'),(2,1,'川A67890','中型客车',33,'正常','2026-04-15 15:32:05','2026-04-15 15:32:05'),(3,2,'川A54321','大型客车',55,'正常','2026-04-15 15:32:05','2026-04-15 15:32:05'),(4,2,'川A09876','商务车',14,'正常','2026-04-15 15:32:05','2026-04-15 15:32:05');
/*!40000 ALTER TABLE `tourism_vehicle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `travel_agency`
--

DROP TABLE IF EXISTS `travel_agency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `travel_agency` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '旅行社ID',
  `agency_name` varchar(100) NOT NULL COMMENT '旅行社名称',
  `license_no` varchar(50) NOT NULL COMMENT '经营许可证号',
  `credit_level` varchar(20) DEFAULT NULL COMMENT '诚信等级 A/B/C/D',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `status` int DEFAULT '1' COMMENT '1正常 0注销',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_license_no` (`license_no`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅行社基础信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `travel_agency`
--

LOCK TABLES `travel_agency` WRITE;
/*!40000 ALTER TABLE `travel_agency` DISABLE KEYS */;
INSERT INTO `travel_agency` VALUES (1,'四川省中国国际旅行社有限责任公司','SC-LY-2023001','A','成都市锦江区总府路2号时代广场','028-86677777',1,'2026-04-15 15:31:57','2026-04-18 14:42:41'),(2,'四川省中青旅旅游有限公司','SC-LY-2023002','B','成都市武侯区人民南路四段12号','028-85556666',1,'2026-04-15 15:31:57','2026-04-18 15:03:45');
/*!40000 ALTER TABLE `travel_agency` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `travel_order`
--

DROP TABLE IF EXISTS `travel_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `travel_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '行程单ID',
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `vehicle_id` bigint NOT NULL COMMENT '使用车辆ID',
  `driver_id` bigint NOT NULL COMMENT '当班驾驶员ID',
  `guide_id` bigint DEFAULT NULL COMMENT '带团导游ID',
  `team_name` varchar(100) NOT NULL COMMENT '团队名称',
  `people_count` int DEFAULT '0' COMMENT '出游人数',
  `start_address` varchar(255) DEFAULT NULL COMMENT '出发地',
  `end_address` varchar(255) DEFAULT NULL COMMENT '目的地',
  `start_time` datetime DEFAULT NULL COMMENT '出发时间',
  `order_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '待确定' COMMENT '行程状态 待确定/待出发/运行中/已完成',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `agency_id` (`agency_id`),
  KEY `vehicle_id` (`vehicle_id`),
  KEY `driver_id` (`driver_id`),
  KEY `travel_order_FK` (`guide_id`),
  CONSTRAINT `travel_order_FK` FOREIGN KEY (`guide_id`) REFERENCES `guide` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `travel_order_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `travel_order_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `tourism_vehicle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `travel_order_ibfk_3` FOREIGN KEY (`driver_id`) REFERENCES `vehicle_driver` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅游电子行程单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `travel_order`
--

LOCK TABLES `travel_order` WRITE;
/*!40000 ALTER TABLE `travel_order` DISABLE KEYS */;
INSERT INTO `travel_order` VALUES (1,1,1,1,1,'青城山一日游',22,'重庆','青城山景区','2026-04-20 08:30:00','待出发','2026-04-17 15:44:58','2026-04-17 16:32:43'),(2,1,1,1,NULL,'青城山一日游',22,'重庆','青城山景区','2026-04-20 08:30:00','待确定','2026-04-20 09:43:11','2026-04-20 09:43:11');
/*!40000 ALTER TABLE `travel_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_driver`
--

DROP TABLE IF EXISTS `vehicle_driver`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_driver` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '驾驶员ID',
  `agency_id` bigint NOT NULL COMMENT '旅行社ID',
  `driver_name` varchar(50) NOT NULL COMMENT '驾驶员姓名',
  `phone` varchar(20) NOT NULL COMMENT '驾驶员电话',
  `license_type` varchar(20) DEFAULT NULL COMMENT '驾照类型 A1/A2/B1',
  `status` int DEFAULT '1' COMMENT '1在职 0空闲',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `vehicle_driver_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `travel_agency` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='旅游车辆驾驶员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_driver`
--

LOCK TABLES `vehicle_driver` WRITE;
/*!40000 ALTER TABLE `vehicle_driver` DISABLE KEYS */;
INSERT INTO `vehicle_driver` VALUES (1,1,'张师傅','13911110001','A1',0,'2026-04-15 15:32:02','2026-04-17 15:07:15'),(2,1,'李师傅','13911110002','A1',0,'2026-04-15 15:32:02','2026-04-17 15:07:15'),(3,2,'王师傅','13911110003','A2',0,'2026-04-15 15:32:02','2026-04-17 15:07:15'),(4,2,'刘师傅','13911110004','B1',0,'2026-04-15 15:32:02','2026-04-17 15:07:15');
/*!40000 ALTER TABLE `vehicle_driver` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_real_location`
--

DROP TABLE IF EXISTS `vehicle_real_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_real_location` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vehicle_id` bigint NOT NULL COMMENT '关联你的旅游车辆ID',
  `longitude` decimal(12,6) NOT NULL COMMENT '经度',
  `latitude` decimal(12,6) NOT NULL COMMENT '纬度',
  `speed` int DEFAULT '0' COMMENT '当前速度 km/h',
  `vehicle_status` varchar(20) DEFAULT '运行中' COMMENT '车辆状态：运行中/停车/离线',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_vehicle` (`vehicle_id`),
  CONSTRAINT `vehicle_real_location_ibfk_1` FOREIGN KEY (`vehicle_id`) REFERENCES `tourism_vehicle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='车辆实时定位信息（地图实时显示）';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_real_location`
--

LOCK TABLES `vehicle_real_location` WRITE;
/*!40000 ALTER TABLE `vehicle_real_location` DISABLE KEYS */;
INSERT INTO `vehicle_real_location` VALUES (1,1,104.065800,30.659400,40,'运行中','2026-04-15 15:32:14'),(2,2,104.066000,30.658000,0,'停车','2026-04-15 15:32:14'),(3,3,104.067000,30.657000,35,'运行中','2026-04-15 15:32:14'),(4,4,104.068000,30.656000,0,'停车','2026-04-15 15:32:14');
/*!40000 ALTER TABLE `vehicle_real_location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vehicle_track_history`
--

DROP TABLE IF EXISTS `vehicle_track_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_track_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `vehicle_id` bigint NOT NULL COMMENT '关联旅游车辆ID',
  `longitude` decimal(12,6) NOT NULL COMMENT '经度',
  `latitude` decimal(12,6) NOT NULL COMMENT '纬度',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '定位时间',
  PRIMARY KEY (`id`),
  KEY `vehicle_id` (`vehicle_id`),
  CONSTRAINT `vehicle_track_history_ibfk_1` FOREIGN KEY (`vehicle_id`) REFERENCES `tourism_vehicle` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='车辆行驶轨迹历史表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vehicle_track_history`
--

LOCK TABLES `vehicle_track_history` WRITE;
/*!40000 ALTER TABLE `vehicle_track_history` DISABLE KEYS */;
INSERT INTO `vehicle_track_history` VALUES (1,1,104.060000,30.660000,'2026-04-15 15:32:17'),(2,1,104.063000,30.659500,'2026-04-15 15:32:17'),(3,1,104.065800,30.659400,'2026-04-15 15:32:17');
/*!40000 ALTER TABLE `vehicle_track_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'tourism_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-21 10:39:56
