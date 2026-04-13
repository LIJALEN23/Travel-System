package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.scenic.*;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface ScenicMapper {
    //======景区基础信息======
    List<ScenicSpot> selectSpotAll();
    ScenicSpot selectSpotById(Long id);
    List<ScenicSpot> selectSpotByName(String spotName);
    int insertSpot(ScenicSpot spot);
    int updateSpot(ScenicSpot spot);
    int deleteSpot(Long id);

    //========景区管理人员=======
    List<ScenicManager> selectManagerBySpotId(Long spotId);
    int insertManager(ScenicManager manager);

    //============应急救援=========
    List<ScenicEmergency> selectEmergencyBySpotId(Long spotId);
    int insertEmergency(ScenicEmergency emergency);

    //============实时数据=========
    ScenicRealTimeData selectRealDataBySpotId(Long spotId);
    int updateRealData(ScenicRealTimeData data);
}
