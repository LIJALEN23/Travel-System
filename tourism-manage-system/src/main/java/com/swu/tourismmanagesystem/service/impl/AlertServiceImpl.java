package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.alertmessage.AlertHandle;
import com.swu.tourismmanagesystem.entity.alertmessage.AlertMessage;
import com.swu.tourismmanagesystem.entity.hotel.HotelBase;
import com.swu.tourismmanagesystem.entity.hotel.HotelRealTimeData;
import com.swu.tourismmanagesystem.entity.scenic.ScenicRealTimeData;
import com.swu.tourismmanagesystem.entity.scenic.ScenicSpot;
import com.swu.tourismmanagesystem.mapper.AlertMessageMapper;
import com.swu.tourismmanagesystem.service.AgencyService;
import com.swu.tourismmanagesystem.service.AlertService;
import com.swu.tourismmanagesystem.service.HotelService;
import com.swu.tourismmanagesystem.service.ScenicService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.swu.tourismmanagesystem.constant.AlertConstant;

@Service
public class AlertServiceImpl implements AlertService {
    private static final Logger logger = LoggerFactory.getLogger(AlertServiceImpl.class);

    @Resource
    private AlertMessageMapper alertMapper;

    @Resource
    private ScenicService scenicService;

    @Resource
    private HotelService hotelService;

    @Resource
    private AgencyService agencyService;

    // 去重：同一个景点/酒店只生成一条消息
    private final Set<String> duplicateSet = new HashSet<>();

    // ==================== 核心自动检测（仅处理有实时数据的条目） ====================
    @Override
    public void autoCheckAndGenerateMessage() {
        duplicateSet.clear();
        int generateMsgCount = 0;

        checkScenic(); // 仅检测有实时数据的景区
        checkHotel();  // 仅检测有实时数据的酒店

        // 统计本次生成/更新的总消息数
        generateMsgCount = duplicateSet.size();
        logger.info("自动检测完成：共检测{}个景区+{}个酒店（仅含有实时数据的条目），本次处理{}条告警消息（新增/更新）",
                scenicService.getScenicIdsWithRealData().size(),
                hotelService.getHotelIdsWithRealData().size(),
                generateMsgCount);
    }

    // ==================== 景区检测：仅保留最新未处理告警 ====================
    private void checkScenic() {
        List<Long> scenicIds = scenicService.getScenicIdsWithRealData();
        if (scenicIds.isEmpty()) {
            logger.info("无景区实时数据，跳过景区告警检测");
            return;
        }
        logger.info("开始检测{}个有实时数据的景区", scenicIds.size());

        int alertScenicCount = 0;

        for (Long scenicId : scenicIds) {
            ScenicSpot spot = scenicService.findSpotById(scenicId);
            if (spot == null) {
                logger.warn("景区ID：{} 无基础信息，跳过检测", scenicId);
                continue;
            }

            ScenicRealTimeData real = scenicService.getRealTimeByScenicId(scenicId);
            if (real == null) {
                logger.warn("景区{}（ID：{}）实时数据异常，跳过检测", spot.getSpotName(), scenicId);
                continue;
            }

            List<String> tips = new ArrayList<>();
            // 1. 游客饱和度检测
            Integer currentVisitors = real.getCurrentVisitors();
            Integer maxCapacity = spot.getMaxCapacity();
            if (currentVisitors != null && maxCapacity != null && maxCapacity > 0) {
                int rate = (currentVisitors * 100) / maxCapacity;
                if (rate >= AlertConstant.SCENIC_LIMIT) {
                    tips.add("游客饱和(" + rate + "%)");
                }
            } else {
                logger.warn("景区{}（ID：{}）游客数/最大容量异常，跳过饱和度检测", spot.getSpotName(), scenicId);
            }

            // 2. 车位检测
            Integer totalParking = spot.getTotalParking();
            Integer remainingParking = real.getRemainingParking();
            if (totalParking != null && remainingParking != null && totalParking > 0) {
                int used = totalParking - remainingParking;
                int rate = (used * 100) / totalParking;
                if (rate >= AlertConstant.PARKING_LIMIT) {
                    tips.add("车位紧张(" + rate + "%)");
                }
            } else {
                logger.warn("景区{}（ID：{}）总车位/剩余车位异常，跳车位检测", spot.getSpotName(), scenicId);
            }

            // 3. 缆车等待检测
            Integer waitTime = real.getCableWaitTime();
            if (waitTime != null && waitTime >= AlertConstant.CABLE_WAIT_LIMIT) {
                tips.add("缆车等待过久(" + waitTime + "分钟)");
            }

            // 4. 有告警条件触发时，处理重复告警
            if (!tips.isEmpty()) {
                String alertContent = spot.getSpotName() + "：" + String.join("，", tips);
                String uniqueKey = "SCENE_" + scenicId;

                // 查询该景区是否已有【未处理】的告警（status=0）
                AlertMessage existAlert = alertMapper.selectUnprocessedAlertByContentAndType(alertContent, "prompt", uniqueKey);

                if (existAlert != null) {
                    // 已有未处理告警 → 仅更新更新时间（标记为最新）
                    existAlert.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
                    // 如果内容有变化（比如新增了告警条件），更新内容
                    if (!existAlert.getContent().equals(alertContent)) {
                        existAlert.setContent(alertContent);
                        logger.info("景区{}（ID：{}）告警内容变化，更新告警：{}", spot.getSpotName(), scenicId, alertContent);
                    } else {
                        logger.info("景区{}（ID：{}）已有未处理告警，仅更新时间，不新增", spot.getSpotName(), scenicId);
                    }
                    alertMapper.updateMessage(existAlert);
                } else {
                    // 无未处理告警 → 新增
                    AlertMessage msg = new AlertMessage();
                    msg.setMsgType("prompt");
                    msg.setContent(alertContent);
                    msg.setStatus(0);
                    msg.setCreateTime(LocalDateTime.now()); // 替换为LocalDateTime
                    msg.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
                    msg.setExtInfo(uniqueKey); // 存储唯一标识
                    alertMapper.insertMessage(msg);
                    logger.info("为景区{}（ID：{}）新增告警：{}", spot.getSpotName(), scenicId, alertContent);
                    alertScenicCount++;
                }
                duplicateSet.add(uniqueKey);
            }
        }

        logger.info("景区检测完成：{}个有实时数据的景区中，{}个触发告警（新增/更新）",
                scenicIds.size(), alertScenicCount);
    }

    // ==================== 酒店检测：仅保留最新未处理告警 ====================
    private void checkHotel() {
        List<Long> hotelIds = hotelService.getHotelIdsWithRealData();
        if (hotelIds.isEmpty()) {
            logger.info("无酒店实时数据，跳过酒店告警检测");
            return;
        }
        logger.info("开始检测{}个有实时数据的酒店", hotelIds.size());

        int alertHotelCount = 0;

        for (Long hotelId : hotelIds) {
            HotelBase hotel = null;
            List<HotelBase> allHotels = hotelService.findAllHotel();
            for (HotelBase h : allHotels) {
                if (h.getId().equals(hotelId)) {
                    hotel = h;
                    break;
                }
            }
            if (hotel == null) {
                logger.warn("酒店ID：{} 无基础信息，跳过检测", hotelId);
                continue;
            }

            Map<String, Object> detail = hotelService.getHotelDetailById(hotelId);
            HotelRealTimeData real = (HotelRealTimeData) detail.get("realTimeData");
            if (real == null) {
                logger.warn("酒店{}（ID：{}）实时数据异常，跳过检测", hotel.getHotelName(), hotelId);
                continue;
            }

            List<String> tips = new ArrayList<>();
            // 1. 入住率检测
            Double occupancyRate = real.getOccupancyRate();
            if (occupancyRate != null && occupancyRate >= AlertConstant.HOTEL_LIMIT) {
                tips.add("入住率过高(" + String.format("%.1f", occupancyRate) + "%)");
            } else if (occupancyRate == null) {
                logger.warn("酒店{}（ID：{}）入住率为NULL，跳入住率检测", hotel.getHotelName(), hotelId);
            }

            // 2. 车位检测
            Integer totalParking = hotel.getTotalParking();
            Integer remainingParking = real.getRemainingParking();
            if (totalParking != null && remainingParking != null && totalParking > 0) {
                int used = totalParking - remainingParking;
                int parkRate = (used * 100) / totalParking;
                if (parkRate >= AlertConstant.PARKING_LIMIT) {
                    tips.add("车位紧张(" + parkRate + "%)");
                }
            } else {
                logger.warn("酒店{}（ID：{}）总车位/剩余车位异常，跳车位检测", hotel.getHotelName(), hotelId);
            }

            // 3. 有告警条件触发时，处理重复告警
            if (!tips.isEmpty()) {
                String alertContent = hotel.getHotelName() + "：" + String.join("，", tips);
                String uniqueKey = "HOTEL_" + hotelId;

                // 查询该酒店是否已有【未处理】的告警
                AlertMessage existAlert = alertMapper.selectUnprocessedAlertByContentAndType(alertContent, "prompt", uniqueKey);

                if (existAlert != null) {
                    // 已有未处理告警 → 更新时间/内容
                    existAlert.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
                    if (!existAlert.getContent().equals(alertContent)) {
                        existAlert.setContent(alertContent);
                        logger.info("酒店{}（ID：{}）告警内容变化，更新告警：{}", hotel.getHotelName(), hotelId, alertContent);
                    } else {
                        logger.info("酒店{}（ID：{}）已有未处理告警，仅更新时间，不新增", hotel.getHotelName(), hotelId);
                    }
                    alertMapper.updateMessage(existAlert);
                } else {
                    // 无未处理告警 → 新增
                    AlertMessage msg = new AlertMessage();
                    msg.setMsgType("prompt");
                    msg.setContent(alertContent);
                    msg.setStatus(0);
                    msg.setCreateTime(LocalDateTime.now()); // 替换为LocalDateTime
                    msg.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
                    msg.setExtInfo(uniqueKey); // 关联酒店唯一标识
                    alertMapper.insertMessage(msg);
                    logger.info("为酒店{}（ID：{}）新增告警：{}", hotel.getHotelName(), hotelId, alertContent);
                    alertHotelCount++;
                }
                duplicateSet.add(uniqueKey);
            }
        }

        logger.info("酒店检测完成：{}个有实时数据的酒店中，{}个触发告警（新增/更新）",
                hotelIds.size(), alertHotelCount);
    }

    // ==================== 基础方法 ====================
    @Override
    public List<AlertMessage> getLatestUnprocessedAlerts() {
        return alertMapper.selectLatestUnprocessedAlerts();
    }
    @Override
    public int createMessage(AlertMessage message) {
        message.setStatus(0);
        message.setCreateTime(LocalDateTime.now()); // 替换为LocalDateTime
        message.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
        return alertMapper.insertMessage(message);
    }

    @Override
    public AlertMessage getMessageById(Long id) {
        return alertMapper.getMessageById(id);
    }

    @Override
    public List<AlertMessage> getMessageList() {
        return alertMapper.getMessageList();
    }

    @Override
    public int checkPass(Long id, String operator) {
        AlertMessage msg = new AlertMessage();
        msg.setId(id);
        msg.setStatus(1);
        msg.setOperator(operator);
        msg.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
        return alertMapper.updateMessage(msg);
    }

    @Override
    public int publish(Long id, String leader) {
        AlertMessage msg = new AlertMessage();
        msg.setId(id);
        msg.setStatus(2);
        msg.setLeader(leader);
        msg.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
        return alertMapper.updateMessage(msg);
    }

    @Override
    public int handle(Long id, String handleResult, String handler) {
        AlertMessage msg = new AlertMessage();
        msg.setId(id);
        msg.setStatus(3);
        msg.setUpdateTime(LocalDateTime.now()); // 替换为LocalDateTime
        alertMapper.updateMessage(msg);

        AlertHandle handle = new AlertHandle();
        handle.setAlertId(id);
        handle.setHandleResult(handleResult);
        handle.setHandler(handler);
        handle.setHandleTime(LocalDateTime.now());
        return alertMapper.insertHandle(handle);
    }

    @Override
    public List<AlertHandle> getHandleList(Long alertId) {
        return alertMapper.getHandlesByAlertId(alertId);
    }
}