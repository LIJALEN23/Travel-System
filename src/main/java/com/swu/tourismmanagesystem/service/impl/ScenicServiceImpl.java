package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.scenic.*;
import com.swu.tourismmanagesystem.mapper.ScenicMapper;
import com.swu.tourismmanagesystem.service.ScenicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
public class ScenicServiceImpl implements ScenicService {
    @Autowired
    private ScenicMapper scenicMapper;

    // 景区名字列表
    @Override
    public List<String> getSpotNameList(List<ScenicSpot> list) {
        List<String> nameList = new ArrayList<>();
        for (ScenicSpot spot : list) {
            nameList.add(spot.getSpotName());
        }
        return nameList;
    }

    // ====================模糊查询返回列表（给搜索用） ====================
    @Override
    public List<ScenicSpot> getSpotListByName(String spotName) {
        return scenicMapper.selectSpotByName(spotName);
    }

    // ==================== 内部改为空实现 ====================
    @Override
    public Map<String, Object> getSpotDetailByName(String spotName) {
        return new HashMap<>();
    }

    // ==================== 根据 ID 查询景区完整详情（前端点击行使用） ====================
    @Override
    public Map<String, Object> getSpotDetailById(Long id) {
        Map<String, Object> result = new HashMap<>();

        // 基础信息
        ScenicSpot spot = scenicMapper.selectSpotById(id);
        // 实时数据
        ScenicRealTimeData realData = scenicMapper.selectRealDataBySpotId(id);
        // 管理人员
        List<ScenicManager> managerList = scenicMapper.selectManagerBySpotId(id);
        // 应急救援
        List<ScenicEmergency> emergencyList = scenicMapper.selectEmergencyBySpotId(id);

        result.put("baseInfo", spot);
        result.put("realTimeData", realData);
        result.put("managerList", managerList);
        result.put("emergencyList", emergencyList);

        return result;
    }

    // 景区基础信息
    @Override
    public List<ScenicSpot> findAllSpot() {
        return scenicMapper.selectSpotAll();
    }

    @Override
    public ScenicSpot findSpotById(Long id) {
        return scenicMapper.selectSpotById(id);
    }

    @Override
    public boolean addSpot(ScenicSpot spot) {
        return scenicMapper.insertSpot(spot) > 0;
    }

    @Override
    public boolean updateSpot(ScenicSpot spot) {
        return scenicMapper.updateSpot(spot) > 0;
    }

    @Override
    public boolean deleteSpot(Long id) {
        return scenicMapper.deleteSpot(id) > 0;
    }

    // 景区管理人员
    @Override
    public List<ScenicManager> findManagerBySpotId(Long spotId) {
        return scenicMapper.selectManagerBySpotId(spotId);
    }

    @Override
    public boolean addManager(ScenicManager manager) {
        return scenicMapper.insertManager(manager) > 0;
    }

    // 应急救援
    @Override
    public List<ScenicEmergency> findEmergenceBySpotId(Long spotId) {
        return scenicMapper.selectEmergencyBySpotId(spotId);
    }

    @Override
    public boolean addEmergency(ScenicEmergency emergency) {
        return scenicMapper.insertEmergency(emergency) > 0;
    }

    // 实时数据
    @Override
    public ScenicRealTimeData findRealDataBySpotId(Long spotId) {
        return scenicMapper.selectRealDataBySpotId(spotId);
    }

    @Override
    public boolean updateRealData(ScenicRealTimeData data) {
        return scenicMapper.updateRealData(data) > 0;
    }
}