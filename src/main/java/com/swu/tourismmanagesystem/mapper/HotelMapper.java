package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.hotel.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
@Mapper
public interface HotelMapper {
    // 查询所有饭店
    List<HotelBase> selectAllHotel();

    // 根据ID查询饭店详情
    Map<String, Object> selectHotelDetailById(@Param("hotelId") Long hotelId);

    // 根据饭店ID查询管理人员
    List<HotelManager> selectManagerByHotelId(@Param("hotelId") Long hotelId);

    // 根据饭店ID查询应急信息
    List<HotelEmergency> selectEmergencyByHotelId(@Param("hotelId") Long hotelId);

    // 根据饭店ID查询实时数据
    HotelRealTimeData selectRealDataByHotelId(@Param("hotelId") Long hotelId);

    //名字模糊查询、星级和状态筛选
    List<HotelBase> selectHotelByCondition(
            @Param("hotelName") String hotelName,
            @Param("starLevel") Integer starLevel
    );
}
