package com.swu.tourismmanagesystem.service;

import com.swu.tourismmanagesystem.entity.hotel.*;
import java.util.List;
import java.util.Map;

public interface HotelService {

    // 模糊查询 + 星级筛选
    List<HotelBase> getHotelListByName(String hotelName, Integer starLevel);
    // ==================== 新增：根据景区ID查酒店 ====================
    List<HotelBase> findHotelByScenicId(Long scenicId);

    // 查询所有酒店
    List<HotelBase> findAllHotel();

    // 根据ID查询详情
    Map<String, Object> getHotelDetailById(Long id);

    // 获取酒店名称列表
    List<String> getHotelNameList(List<HotelBase> allHotel);
    //===========实时数据========
    // ===================== 酒店实时数据 =====================
    HotelRealTimeData getRealTimeByHotelId(Long hotelId);
    void saveOrUpdateRealTime(HotelRealTimeData data);
    List<Long> getHotelIdsWithRealData();
}