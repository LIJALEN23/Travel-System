package com.swu.tourismmanagesystem.service;

import com.swu.tourismmanagesystem.entity.scenic.*;
import java.util.List;
import java.util.Map;

public interface ScenicService {

    List<String> getSpotNameList(List<ScenicSpot> list);

    // 旧方法（保留，但不再使用）
    Map<String, Object> getSpotDetailByName(String spotName);

    // ==================== 模糊查询景区列表（给前端搜索用） ====================
    List<ScenicSpot> getSpotListByName(String spotName);

    // ==================== 根据 ID 查询景区完整详情（点击行使用） ====================
    Map<String, Object> getSpotDetailById(Long id);

    //===========景区基础操作========
    List<ScenicSpot> findAllSpot();
    ScenicSpot findSpotById(Long id);
    boolean addSpot(ScenicSpot spot);
    boolean updateSpot(ScenicSpot spot);
    boolean deleteSpot(Long id);

    //===========管理人员=========
    List<ScenicManager> findManagerBySpotId(Long spotId);
    boolean addManager(ScenicManager manager);

    //===========紧急事态=========
    List<ScenicEmergency> findEmergenceBySpotId(Long spotId);
    boolean addEmergency(ScenicEmergency emergency);

    //==========实时数据===========
    ScenicRealTimeData getRealTimeByScenicId(Long spotId);
    int insertRealTime(ScenicRealTimeData data);
    int updateRealTime(ScenicRealTimeData data);
    List<Long> getScenicIdsWithRealData();
}