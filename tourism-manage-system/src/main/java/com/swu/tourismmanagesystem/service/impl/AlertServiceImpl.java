package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.alertmessage.*;
import com.swu.tourismmanagesystem.entity.hotel.*;
import com.swu.tourismmanagesystem.entity.scenic.*;
import com.swu.tourismmanagesystem.mapper.AlertMessageMapper;
import com.swu.tourismmanagesystem.service.AgencyService;
import com.swu.tourismmanagesystem.service.AlertService;
import com.swu.tourismmanagesystem.service.HotelService;
import com.swu.tourismmanagesystem.service.ScenicService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Map;

@Service
public class AlertServiceImpl implements AlertService {

    @Resource
    private AlertMessageMapper alertMapper;

    @Resource
    private ScenicService scenicService;

    @Resource
    private HotelService hotelService;

    @Resource
    private AgencyService agencyService;

    // ==================== 阈值配置 ====================
    private static final int SCENIC_LIMIT = 80;
    private static final int PARKING_LIMIT = 85;
    private static final int HOTEL_LIMIT = 90;
    private static final int CABLE_WAIT_LIMIT = 20;

    // 去重：同一个景点/酒店只生成一条消息
    private final Set<String> duplicateSet = new HashSet<>();

    // ==================== 核心自动检测 ====================
    @Override
    public void autoCheckAndGenerateMessage() {
        duplicateSet.clear();
        checkScenic();
        checkHotel();
    }

    // ==================== 景区：人数 + 车位 + 缆车等待 ====================
    private void checkScenic() {
        List<ScenicSpot> spotList = scenicService.findAllSpot();

        for (ScenicSpot spot : spotList) {
            ScenicRealTimeData real = scenicService.findRealDataBySpotId(spot.getId());
            if (real == null) continue;

            List<String> tips = new ArrayList<>();

            // 游客饱和度
            int current = real.getCurrentVisitors();
            int max = spot.getMaxCapacity();
            if (max > 0) {
                int rate = (current * 100) / max;
                if (rate >= SCENIC_LIMIT) {
                    tips.add("游客饱和(" + rate + "%)");
                }
            }

            // 车位
            int total = spot.getTotalParking();
            int remaining = real.getRemainingParking();
            if (total > 0) {
                int used = total - remaining;
                int rate = (used * 100) / total;
                if (rate >= PARKING_LIMIT) {
                    tips.add("车位紧张(" + rate + "%)");
                }
            }

            // 缆车等待
            Integer waitTime = real.getCableWaitTime();
            if (waitTime != null && waitTime >= CABLE_WAIT_LIMIT) {
                tips.add("缆车等待过久(" + waitTime + "分钟)");
            }

            // 多个异常合并为一条消息
            if (!tips.isEmpty() && !duplicateSet.contains("SCENE_" + spot.getId())) {
                duplicateSet.add("SCENE_" + spot.getId());
                AlertMessage msg = new AlertMessage();
                msg.setMsgType("prompt");
                msg.setContent(spot.getSpotName() + "：" + String.join("，", tips));
                msg.setStatus(0);
                alertMapper.insertMessage(msg);
            }
        }
    }

    // ==================== 酒店：入住率 + 车位 ====================
    private void checkHotel() {
        List<HotelBase> hotelList = hotelService.findAllHotel();

        for (HotelBase hotel : hotelList) {
            Map<String, Object> detail = hotelService.getHotelDetailById(hotel.getId());
            HotelRealTimeData real = (HotelRealTimeData) detail.get("realTimeData");
            if (real == null) continue;

            List<String> tips = new ArrayList<>();

            // 入住率
            double rate = real.getOccupancyRate();
            if (rate >= HOTEL_LIMIT) {
                tips.add("入住率过高(" + rate + "%)");
            }

            // 车位
            int total = hotel.getTotalParking();
            int remaining = real.getRemainingParking();
            if (total > 0) {
                int used = total - remaining;
                int parkRate = (used * 100) / total;
                if (parkRate >= PARKING_LIMIT) {
                    tips.add("车位紧张(" + parkRate + "%)");
                }
            }

            if (!tips.isEmpty() && !duplicateSet.contains("HOTEL_" + hotel.getId())) {
                duplicateSet.add("HOTEL_" + hotel.getId());
                AlertMessage msg = new AlertMessage();
                msg.setMsgType("prompt");
                msg.setContent(hotel.getHotelName() + "：" + String.join("，", tips));
                msg.setStatus(0);
                alertMapper.insertMessage(msg);
            }
        }
    }

    // ==================== 基础方法（不变） ====================
    @Override
    public int createMessage(AlertMessage message) {
        message.setStatus(0);
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
        return alertMapper.updateMessage(msg);
    }

    @Override
    public int publish(Long id, String leader) {
        AlertMessage msg = new AlertMessage();
        msg.setId(id);
        msg.setStatus(2);
        msg.setLeader(leader);
        return alertMapper.updateMessage(msg);
    }

    @Override
    public int handle(Long id, String handleResult, String handler) {
        AlertMessage msg = new AlertMessage();
        msg.setId(id);
        msg.setStatus(3);
        alertMapper.updateMessage(msg);

        AlertHandle handle = new AlertHandle();
        handle.setAlertId(id);
        handle.setHandleResult(handleResult);
        handle.setHandler(handler);
        return alertMapper.insertHandle(handle);
    }

    @Override
    public List<AlertHandle> getHandleList(Long alertId) {
        return alertMapper.getHandlesByAlertId(alertId);
    }
}