package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.hotel.HotelBase;
import com.swu.tourismmanagesystem.entity.hotel.HotelEmergency;
import com.swu.tourismmanagesystem.entity.hotel.HotelManager;
import com.swu.tourismmanagesystem.entity.hotel.HotelRealTimeData;
import com.swu.tourismmanagesystem.mapper.HotelMapper;
import com.swu.tourismmanagesystem.service.HotelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class HotelServiceImpl implements HotelService {
    private static final Logger logger = LoggerFactory.getLogger(HotelServiceImpl.class);
    @Autowired
    private HotelMapper hotelMapper;

    // 模糊查询 + 星级筛选
    @Override
    public List<HotelBase> getHotelListByName(String hotelName, Integer starLevel) {
        return hotelMapper.selectHotelByCondition(hotelName, starLevel);
    }

    // 查询所有酒店
    @Override
    public List<HotelBase> findAllHotel() {
        return hotelMapper.selectAllHotel();
    }

    // 根据ID查询详情（包含：基本信息、管理员、应急信息、实时数据）
    @Override
    public Map<String, Object> getHotelDetailById(Long id) {
        Map<String, Object> detailMap = new HashMap<>();

        // 酒店基本信息
        Map<String, Object> hotelBase = hotelMapper.selectHotelDetailById(id);
        // 管理员列表
        List<HotelManager> managerList = hotelMapper.selectManagerByHotelId(id);
        // 应急信息
        List<HotelEmergency> emergencyList = hotelMapper.selectEmergencyByHotelId(id);
        // 实时数据
        HotelRealTimeData realData = hotelMapper.selectRealDataByHotelId(id);

        detailMap.put("baseInfo", hotelBase);
        detailMap.put("managerList", managerList);
        detailMap.put("emergencyList", emergencyList);
        detailMap.put("realTimeData", realData);

        return detailMap;
    }
    // ==================== 新增：根据景区ID查询酒店 ====================
    @Override
    public List<HotelBase> findHotelByScenicId(Long scenicId) {
        return hotelMapper.selectHotelByScenicId(scenicId);
    }
    // 获取酒店名称列表
    @Override
    public List<String> getHotelNameList(List<HotelBase> allHotel) {
        List<String> nameList = new ArrayList<>();
        for (HotelBase hotel : allHotel) {
            nameList.add(hotel.getHotelName());
        }
        return nameList;
    }
    // ===================== 酒店实时数据 =====================
    @Override
    public HotelRealTimeData getRealTimeByHotelId(Long hotelId) {
        return hotelMapper.selectRealDataByHotelId(hotelId);
    }

    @Override
    public void saveOrUpdateRealTime(HotelRealTimeData data) {
        // 1. 基础参数校验
        Assert.notNull(data.getHotelId(), "酒店ID不能为空");
        Assert.notNull(data.getCurrentVisitors(), "当前游客数不能为空");
        logger.info("开始处理酒店实时数据上传，酒店ID：{}，当前游客数：{}", data.getHotelId(), data.getCurrentVisitors());

        // 2. 查询酒店最大容纳量（max_capacity）
        Integer maxCapacity = hotelMapper.selectMaxCapacityByHotelId(data.getHotelId());
        logger.info("查询到酒店{}的最大容纳量：{}", data.getHotelId(), maxCapacity); // 打印maxCapacity

        if (maxCapacity == null || maxCapacity == 0) {
            String errorMsg = "酒店最大容纳量未配置或为0，无法计算入住率（酒店ID：" + data.getHotelId() + "）";
            logger.error(errorMsg);
            throw new IllegalArgumentException(errorMsg); // 抛精准异常（参数非法）
        }

        // 3. 计算入住率（currentVisitors / maxCapacity * 100，保留1位小数）
        double occupancyRate = (double) data.getCurrentVisitors() / maxCapacity * 100;
        occupancyRate = Math.round(occupancyRate * 10) / 10.0; // 保留1位小数
        logger.info("计算出酒店{}的入住率：{}%", data.getHotelId(), occupancyRate); // 打印计算结果
        data.setOccupancyRate(occupancyRate); // 自动赋值到实体类

        // 4. 保存/更新逻辑
        HotelRealTimeData exist = getRealTimeByHotelId(data.getHotelId());
        if (exist == null) {
            logger.info("酒店{}无原有实时数据，执行新增操作", data.getHotelId());
            hotelMapper.insertRealTimeData(data);
        } else {
            logger.info("酒店{}有原有实时数据，执行更新操作", data.getHotelId());
            hotelMapper.updateRealTimeData(data);
        }
        logger.info("酒店{}实时数据处理完成，入住率：{}%", data.getHotelId(), occupancyRate);
    }
    @Override
    public List<Long> getHotelIdsWithRealData() {
        return hotelMapper.selectHotelIdsWithRealData();
    }
}