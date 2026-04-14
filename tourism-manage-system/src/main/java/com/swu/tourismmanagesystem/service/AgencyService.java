package com.swu.tourismmanagesystem.service;

import com.swu.tourismmanagesystem.entity.agency.*;
import java.util.List;

public interface AgencyService {

    // ====================== 旅行社基础信息 ======================
    List<TravelAgency> getAllAgency();
    TravelAgency getAgencyById(Long id);
    // 新增
    List<TravelAgency> getAgencyByLike(String agencyName, String licenseNo);
    int addAgency(TravelAgency agency);
    int updateAgency(TravelAgency agency);
    int deleteAgency(Long id);

    // ====================== 管理人员 ======================
    List<AgencyManager> getManagerByAgency(Long agencyId);
    int addManager(AgencyManager manager);

    // ====================== 驾驶员 ======================
    List<VehicleDriver> getDriverByAgency(Long agencyId);
    // 根据ID查单个驾驶员
    VehicleDriver getDriverById(Long driverId);
    int addDriver(VehicleDriver driver);

    // ====================== 旅游车辆 ======================
    List<TourismVehicle> getVehicleByAgency(Long agencyId);
    int addVehicle(TourismVehicle vehicle);
    // 根据ID查单个车辆
    TourismVehicle getVehicleById(Long vehicleId);

    // ====================== 应急救援 ======================
    List<AgencyEmergency> getEmergencyByAgency(Long agencyId);
    int addEmergency(AgencyEmergency emergency);

    // ====================== 实时数据 ======================
    AgencyRealTimeData getRealTimeData(Long agencyId);
    int updateRealData(AgencyRealTimeData data);

    // ====================== 电子行程单 ======================
    List<TravelOrder> getOrderByAgency(Long agencyId);
    TravelOrder getOrderById(Long orderId);
    List<TravelOrder> getRunningOrder();
    int addOrder(TravelOrder order);
    int updateOrderStatus(TravelOrder order);

    // ====================== 出境游审核 ======================
    List<AbroadTravel> getAbroadByAgency(Long agencyId);
    List<AbroadTravel> getWaitAuditAbroad();
    int addAbroad(AbroadTravel abroad);
    int updateVisa(AbroadTravel abroad);

    // ====================== GIS 定位 + 轨迹 ======================
    List<VehicleRealLocation> getAllLocation();
    int updateLocation(VehicleRealLocation loc);
    List<VehicleTrackHistory> getTrackByVehicle(Long vehicleId);
    int addTrack(VehicleTrackHistory track);
}