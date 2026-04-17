package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.agency.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface AgencyMapper {

    // ====================== 1. 旅行社基础信息 ======================
    List<TravelAgency> listTravelAgency();
    TravelAgency getTravelAgencyById(Long id);
    List<TravelAgency> findAgencyByLike(@Param("agencyName") String agencyName,
                                        @Param("licenseNo") String licenseNo);
    int insertTravelAgency(TravelAgency agency);
    int updateTravelAgency(TravelAgency agency);
    int deleteTravelAgency(Long id);


    // ====================== 2. 管理人员 ======================
    List<AgencyManager> listManagerByAgencyId(Long agencyId);
    int insertManager(AgencyManager manager);

    // ====================== 3. 驾驶员 ======================
    List<VehicleDriver> listDriverByAgencyId(Long agencyId);
    int insertDriver(VehicleDriver driver);
    VehicleDriver getDriverById(Long driverId);


    // ====================== 4. 旅游车辆 ======================
    List<TourismVehicle> listVehicleByAgencyId(Long agencyId);
    TourismVehicle getVehicleById(Long vehicleId);
    int insertVehicle(TourismVehicle vehicle);

    // ====================== 5. 应急救援 ======================
    List<AgencyEmergency> listEmergencyByAgencyId(Long agencyId);
    int insertEmergency(AgencyEmergency emergency);

    // ====================== 6. 实时运行数据 ======================
    AgencyRealTimeData getRealTimeDataByAgencyId(Long agencyId);
    int updateRealTimeData(AgencyRealTimeData data);

    // ====================== 7. 电子行程单 ======================
    List<TravelOrder> listOrderByCondition(
            @Param("agencyId") Long agencyId,
            @Param("orderStatus") String orderStatus,
            @Param("teamName") String teamName,
            @Param("startTime") String startTime
    );
    List<TravelOrder> listRunningOrder();
    TravelOrder getOrderById(Long orderId);
    int insertTravelOrder(TravelOrder order);
    int updateOrderStatus(TravelOrder order);

    // 【新增】审核通过后，更新行程单的导游ID和状态
    int updateOrderGuideAndStatus(
            @Param("orderId") Long orderId,
            @Param("guideId") Long guideId,
            @Param("orderStatus") String orderStatus
    );

    // ====================== 8. 出境游审核 ======================
    List<AbroadTravel> getAbroadByAgency(
            @Param("agencyId") Long agencyId,
            @Param("visaStatus") String visaStatus
    );
    List<AbroadTravel> listWaitAuditAbroad();
    int insertAbroadTravel(AbroadTravel abroad);
    int updateVisaStatus(AbroadTravel abroad);

    // ====================== 9. GIS 车辆实时定位 ======================
    List<VehicleRealLocation> listAllVehicleLocation();
    VehicleRealLocation getLocationByVehicleId(Long vehicleId);
    int insertOrUpdateLocation(VehicleRealLocation loc);

    // ====================== 10. GIS 车辆轨迹历史 ======================
    List<VehicleTrackHistory> listTrackByVehicleId(Long vehicleId);
    int insertVehicleTrack(VehicleTrackHistory track);
    // ====================== 11. 诚信档案（对接投诉系统）======================
    // 根据旅行社ID查询诚信档案
    AgencyCredit getAgencyCreditByAgencyId(Long agencyId);

    // 新增诚信档案（第一次投诉时自动创建）
    int insertAgencyCredit(AgencyCredit credit);

    // 更新诚信分数、投诉统计
    int updateAgencyCredit(AgencyCredit credit);
}