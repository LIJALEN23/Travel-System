package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.agency.*;
import com.swu.tourismmanagesystem.mapper.AgencyMapper;
import com.swu.tourismmanagesystem.service.AgencyService;
import org.springframework.stereotype.Service;
import javax.annotation.Resource;
import java.util.List;

@Service
public class AgencyServiceImpl implements AgencyService {

    @Resource
    private AgencyMapper agencyMapper;

    // ====================== 旅行社 ======================
    @Override
    public List<TravelAgency> getAllAgency() {
        return agencyMapper.listTravelAgency();
    }
    @Override
    public TravelAgency getAgencyById(Long id) {
        return agencyMapper.getTravelAgencyById(id);
    }

    @Override
    public List<TravelAgency> getAgencyByLike(String agencyName, String licenseNo) {
        return agencyMapper.findAgencyByLike(agencyName, licenseNo);
    }
    @Override
    public int addAgency(TravelAgency agency) {
        return agencyMapper.insertTravelAgency(agency);
    }
    @Override
    public int updateAgency(TravelAgency agency) {
        return agencyMapper.updateTravelAgency(agency);
    }
    @Override
    public int deleteAgency(Long id) {
        return agencyMapper.deleteTravelAgency(id);
    }

    // ====================== 管理人员 ======================
    @Override
    public List<AgencyManager> getManagerByAgency(Long agencyId) {
        return agencyMapper.listManagerByAgencyId(agencyId);
    }
    @Override
    public int addManager(AgencyManager manager) {
        return agencyMapper.insertManager(manager);
    }

    // ====================== 驾驶员 ======================
    @Override
    public List<VehicleDriver> getDriverByAgency(Long agencyId) {
        return agencyMapper.listDriverByAgencyId(agencyId);
    }
    @Override
    public int addDriver(VehicleDriver driver) {
        return agencyMapper.insertDriver(driver);
    }
    @Override
    public VehicleDriver getDriverById(Long driverId) {
        return agencyMapper.getDriverById(driverId);
    }

    // ====================== 车辆 ======================
    @Override
    public List<TourismVehicle> getVehicleByAgency(Long agencyId) {
        return agencyMapper.listVehicleByAgencyId(agencyId);
    }
    @Override
    public int addVehicle(TourismVehicle vehicle) {
        return agencyMapper.insertVehicle(vehicle);
    }
    @Override
    public TourismVehicle getVehicleById(Long vehicleId) {
        return agencyMapper.getVehicleById(vehicleId);
    }
    // ====================== 应急救援 ======================
    @Override
    public List<AgencyEmergency> getEmergencyByAgency(Long agencyId) {
        return agencyMapper.listEmergencyByAgencyId(agencyId);
    }
    @Override
    public int addEmergency(AgencyEmergency emergency) {
        return agencyMapper.insertEmergency(emergency);
    }

    // ====================== 实时数据 ======================
    @Override
    public AgencyRealTimeData getRealTimeData(Long agencyId) {
        return agencyMapper.getRealTimeDataByAgencyId(agencyId);
    }
    @Override
    public int updateRealData(AgencyRealTimeData data) {
        return agencyMapper.updateRealTimeData(data);
    }

    // ====================== 行程单 ======================
    // 多条件筛选（新增）
    @Override
    public List<TravelOrder> getOrderByCondition(Long agencyId, String orderStatus, String teamName, String startTime) {
        return agencyMapper.listOrderByCondition(agencyId, orderStatus, teamName, startTime);
    }

    @Override
    public TravelOrder getOrderById(Long orderId){
        return agencyMapper.getOrderById(orderId);
    }
    @Override
    public List<TravelOrder> getRunningOrder() {
        return agencyMapper.listRunningOrder();
    }
    @Override
    public int addOrder(TravelOrder order) {
        return agencyMapper.insertTravelOrder(order);
    }
    @Override
    public int updateOrderStatus(TravelOrder order) {
        return agencyMapper.updateOrderStatus(order);
    }

    // ====================== 出境游 ======================
    @Override
    public List<AbroadTravel> getAbroadByAgency(Long agencyId, String visaStatus) {
        // 方法名必须和 Mapper.xml 的 id 完全一致
        return agencyMapper.getAbroadByAgency(agencyId, visaStatus);
    }
    @Override
    public List<AbroadTravel> getWaitAuditAbroad() {
        return agencyMapper.listWaitAuditAbroad();
    }
    @Override
    public int addAbroad(AbroadTravel abroad) {
        return agencyMapper.insertAbroadTravel(abroad);
    }
    @Override
    public int updateVisa(AbroadTravel abroad) {
        return agencyMapper.updateVisaStatus(abroad);
    }

    // ====================== GIS 定位 ======================
    @Override
    public List<VehicleRealLocation> getAllLocation() {
        return agencyMapper.listAllVehicleLocation();
    }
    @Override
    public int updateLocation(VehicleRealLocation loc) {
        return agencyMapper.insertOrUpdateLocation(loc);
    }

    // ====================== GIS 轨迹 ======================
    @Override
    public List<VehicleTrackHistory> getTrackByVehicle(Long vehicleId) {
        return agencyMapper.listTrackByVehicleId(vehicleId);
    }
    @Override
    public int addTrack(VehicleTrackHistory track) {
        return agencyMapper.insertVehicleTrack(track);
    }
}