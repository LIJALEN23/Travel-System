package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.hotel.HotelBase;
import com.swu.tourismmanagesystem.entity.hotel.HotelEmergency;
import com.swu.tourismmanagesystem.entity.hotel.HotelManager;
import com.swu.tourismmanagesystem.entity.hotel.HotelRealTimeData;
import com.swu.tourismmanagesystem.mapper.HotelMapper;
import com.swu.tourismmanagesystem.service.HotelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class HotelServiceImpl implements HotelService {

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

    // 获取酒店名称列表
    @Override
    public List<String> getHotelNameList(List<HotelBase> allHotel) {
        List<String> nameList = new ArrayList<>();
        for (HotelBase hotel : allHotel) {
            nameList.add(hotel.getHotelName());
        }
        return nameList;
    }
}