package com.swu.tourismmanagesystem.unit.service;

import com.swu.tourismmanagesystem.entity.agency.*;
import com.swu.tourismmanagesystem.mapper.AgencyMapper;
import com.swu.tourismmanagesystem.service.impl.AgencyServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TestAgencyService {

    @Mock
    private AgencyMapper agencyMapper;

    @InjectMocks
    private AgencyServiceImpl agencyService;

    private TravelAgency testAgency;
    private AgencyManager testManager;
    private VehicleDriver testDriver;
    private TourismVehicle testVehicle;
    private AgencyEmergency testEmergency;
    private AgencyRealTimeData testRealTime;
    private TravelOrder testOrder;
    private AbroadTravel testAbroad;
    private VehicleRealLocation testLocation;
    private VehicleTrackHistory testTrack;

    @BeforeEach
    void setUp() {
        testAgency = new TravelAgency();
        testAgency.setId(1L);
        testAgency.setAgencyName("测试旅行社");
        testAgency.setLicenseNo("L-123456");
        testAgency.setCreditLevel("A");
        testAgency.setAddress("北京市朝阳区");
        testAgency.setContactPhone("010-12345678");
        testAgency.setStatus(1);
        testAgency.setCreateTime(LocalDateTime.now());
        testAgency.setUpdateTime(LocalDateTime.now());

        testManager = new AgencyManager();
        testManager.setId(1L);
        testManager.setAgencyId(1L);
        testManager.setWorkNo("M001");
        testManager.setManagerName("王经理");
        testManager.setPhone("13800138000");
        testManager.setPost("总经理");
        testManager.setStatus(1);
        testManager.setCreateTime(LocalDateTime.now());

        testDriver = new VehicleDriver();
        testDriver.setId(1L);
        testDriver.setAgencyId(1L);
        testDriver.setDriverName("李师傅");
        testDriver.setPhone("13900139000");
        testDriver.setLicenseType("A1");
        testDriver.setStatus(1);
        testDriver.setCreateTime(LocalDateTime.now());
        testDriver.setUpdateTime(LocalDateTime.now());

        testVehicle = new TourismVehicle();
        testVehicle.setId(1L);
        testVehicle.setAgencyId(1L);
        testVehicle.setPlateNo("京A12345");
        testVehicle.setVehicleType("大巴");
        testVehicle.setSeatCount(50);
        testVehicle.setVehicleStatus("正常");
        testVehicle.setCreateTime(LocalDateTime.now());
        testVehicle.setUpdateTime(LocalDateTime.now());

        testEmergency = new AgencyEmergency();
        testEmergency.setId(1L);
        testEmergency.setAgencyId(1L);
        testEmergency.setRescuerName("赵救援");
        testEmergency.setRescuerPhone("13700137000");
        testEmergency.setVehicleNo("京B67890");
        testEmergency.setCreateTime(LocalDateTime.now());

        testRealTime = new AgencyRealTimeData();
        testRealTime.setId(1L);
        testRealTime.setAgencyId(1L);
        testRealTime.setTodayTeams(5);
        testRealTime.setTodayPeople(120);
        testRealTime.setOnlineVehicles(3);
        testRealTime.setUpdateTime(LocalDateTime.now());

        testOrder = new TravelOrder();
        testOrder.setId(1L);
        testOrder.setAgencyId(1L);
        testOrder.setVehicleId(1L);
        testOrder.setDriverId(1L);
        testOrder.setGuideId(2L);
        testOrder.setTeamName("北京一日游");
        testOrder.setPeopleCount(30);
        testOrder.setStartAddress("天安门");
        testOrder.setEndAddress("长城");
        testOrder.setStartTime(LocalDateTime.now().plusDays(1));
        testOrder.setOrderStatus("待出发");
        testOrder.setCreateTime(LocalDateTime.now());
        testOrder.setUpdateTime(LocalDateTime.now());

        testAbroad = new AbroadTravel();
        testAbroad.setId(1L);
        testAbroad.setAgencyId(1L);
        testAbroad.setTeamName("泰国七日游");
        testAbroad.setCountry("泰国");
        testAbroad.setVisaStatus("待审核");
        testAbroad.setApplyTime(LocalDateTime.now());
        testAbroad.setCreateTime(LocalDateTime.now());
        testAbroad.setUpdateTime(LocalDateTime.now());

        testLocation = new VehicleRealLocation();
        testLocation.setId(1L);
        testLocation.setVehicleId(1L);
        testLocation.setLongitude(new java.math.BigDecimal("116.397128"));
        testLocation.setLatitude(new java.math.BigDecimal("39.916527"));
        testLocation.setSpeed(60);
        testLocation.setVehicleStatus("行驶中");
        testLocation.setUpdateTime(LocalDateTime.now());

        testTrack = new VehicleTrackHistory();
        testTrack.setId(1L);
        testTrack.setVehicleId(1L);
        testTrack.setLongitude(116.397128);
        testTrack.setLatitude(39.916527);
        testTrack.setCreateTime(LocalDateTime.now());
    }

    // ====================== 旅行社基础操作 ======================
    @Test
    void getAllAgency_ShouldReturnList() {
        List<TravelAgency> expected = Arrays.asList(testAgency, createAgency(2L, "第二旅行社"));
        when(agencyMapper.listTravelAgency()).thenReturn(expected);
        List<TravelAgency> result = agencyService.getAllAgency();
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listTravelAgency();
    }

    @Test
    void getAgencyById_WhenExists_ShouldReturnAgency() {
        when(agencyMapper.getTravelAgencyById(1L)).thenReturn(testAgency);
        TravelAgency result = agencyService.getAgencyById(1L);
        assertThat(result).isEqualTo(testAgency);
        verify(agencyMapper).getTravelAgencyById(1L);
    }

    @Test
    void getAgencyById_WhenNotExists_ShouldReturnNull() {
        when(agencyMapper.getTravelAgencyById(99L)).thenReturn(null);
        TravelAgency result = agencyService.getAgencyById(99L);
        assertThat(result).isNull();
        verify(agencyMapper).getTravelAgencyById(99L);
    }

    @Test
    void getAgencyByLike_ShouldReturnList() {
        List<TravelAgency> expected = Collections.singletonList(testAgency);
        when(agencyMapper.findAgencyByLike("测试", "L-123")).thenReturn(expected);
        List<TravelAgency> result = agencyService.getAgencyByLike("测试", "L-123");
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).findAgencyByLike("测试", "L-123");
    }

    @Test
    void addAgency_ShouldReturnInsertResult() {
        when(agencyMapper.insertTravelAgency(testAgency)).thenReturn(1);
        int result = agencyService.addAgency(testAgency);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertTravelAgency(testAgency);
    }

    @Test
    void updateAgency_ShouldReturnUpdateResult() {
        when(agencyMapper.updateTravelAgency(testAgency)).thenReturn(1);
        int result = agencyService.updateAgency(testAgency);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).updateTravelAgency(testAgency);
    }

    @Test
    void deleteAgency_ShouldReturnDeleteResult() {
        when(agencyMapper.deleteTravelAgency(1L)).thenReturn(1);
        int result = agencyService.deleteAgency(1L);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).deleteTravelAgency(1L);
    }

    // ====================== 旅行社管理人员 ======================
    @Test
    void getManagerByAgency_ShouldReturnList() {
        List<AgencyManager> expected = Collections.singletonList(testManager);
        when(agencyMapper.listManagerByAgencyId(1L)).thenReturn(expected);
        List<AgencyManager> result = agencyService.getManagerByAgency(1L);
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listManagerByAgencyId(1L);
    }

    @Test
    void addManager_ShouldReturnInsertResult() {
        when(agencyMapper.insertManager(testManager)).thenReturn(1);
        int result = agencyService.addManager(testManager);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertManager(testManager);
    }

    // ====================== 司机管理 ======================
    @Test
    void getDriverByAgency_ShouldReturnList() {
        List<VehicleDriver> expected = Collections.singletonList(testDriver);
        when(agencyMapper.listDriverByAgencyId(1L)).thenReturn(expected);
        List<VehicleDriver> result = agencyService.getDriverByAgency(1L);
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listDriverByAgencyId(1L);
    }

    @Test
    void addDriver_ShouldReturnInsertResult() {
        when(agencyMapper.insertDriver(testDriver)).thenReturn(1);
        int result = agencyService.addDriver(testDriver);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertDriver(testDriver);
    }

    @Test
    void getDriverById_WhenExists_ShouldReturnDriver() {
        when(agencyMapper.getDriverById(1L)).thenReturn(testDriver);
        VehicleDriver result = agencyService.getDriverById(1L);
        assertThat(result).isEqualTo(testDriver);
        verify(agencyMapper).getDriverById(1L);
    }

    @Test
    void getDriverById_WhenNotExists_ShouldReturnNull() {
        when(agencyMapper.getDriverById(99L)).thenReturn(null);
        VehicleDriver result = agencyService.getDriverById(99L);
        assertThat(result).isNull();
        verify(agencyMapper).getDriverById(99L);
    }

    // ====================== 车辆管理 ======================
    @Test
    void getVehicleByAgency_ShouldReturnList() {
        List<TourismVehicle> expected = Collections.singletonList(testVehicle);
        when(agencyMapper.listVehicleByAgencyId(1L)).thenReturn(expected);
        List<TourismVehicle> result = agencyService.getVehicleByAgency(1L);
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listVehicleByAgencyId(1L);
    }

    @Test
    void addVehicle_ShouldReturnInsertResult() {
        when(agencyMapper.insertVehicle(testVehicle)).thenReturn(1);
        int result = agencyService.addVehicle(testVehicle);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertVehicle(testVehicle);
    }

    @Test
    void getVehicleById_WhenExists_ShouldReturnVehicle() {
        when(agencyMapper.getVehicleById(1L)).thenReturn(testVehicle);
        TourismVehicle result = agencyService.getVehicleById(1L);
        assertThat(result).isEqualTo(testVehicle);
        verify(agencyMapper).getVehicleById(1L);
    }

    @Test
    void getVehicleById_WhenNotExists_ShouldReturnNull() {
        when(agencyMapper.getVehicleById(99L)).thenReturn(null);
        TourismVehicle result = agencyService.getVehicleById(99L);
        assertThat(result).isNull();
        verify(agencyMapper).getVehicleById(99L);
    }

    // ====================== 应急联系人 ======================
    @Test
    void getEmergencyByAgency_ShouldReturnList() {
        List<AgencyEmergency> expected = Collections.singletonList(testEmergency);
        when(agencyMapper.listEmergencyByAgencyId(1L)).thenReturn(expected);
        List<AgencyEmergency> result = agencyService.getEmergencyByAgency(1L);
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listEmergencyByAgencyId(1L);
    }

    @Test
    void addEmergency_ShouldReturnInsertResult() {
        when(agencyMapper.insertEmergency(testEmergency)).thenReturn(1);
        int result = agencyService.addEmergency(testEmergency);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertEmergency(testEmergency);
    }

    // ====================== 实时数据 ======================
    @Test
    void getRealTimeData_WhenExists_ShouldReturnData() {
        when(agencyMapper.getRealTimeDataByAgencyId(1L)).thenReturn(testRealTime);
        AgencyRealTimeData result = agencyService.getRealTimeData(1L);
        assertThat(result).isEqualTo(testRealTime);
        verify(agencyMapper).getRealTimeDataByAgencyId(1L);
    }

    @Test
    void getRealTimeData_WhenNotExists_ShouldReturnNull() {
        when(agencyMapper.getRealTimeDataByAgencyId(1L)).thenReturn(null);
        AgencyRealTimeData result = agencyService.getRealTimeData(1L);
        assertThat(result).isNull();
        verify(agencyMapper).getRealTimeDataByAgencyId(1L);
    }

    @Test
    void updateRealData_ShouldReturnUpdateResult() {
        when(agencyMapper.updateRealTimeData(testRealTime)).thenReturn(1);
        int result = agencyService.updateRealData(testRealTime);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).updateRealTimeData(testRealTime);
    }

    // ====================== 旅行订单 ======================
    @Test
    void getOrderByCondition_ShouldReturnList() {
        List<TravelOrder> expected = Collections.singletonList(testOrder);
        when(agencyMapper.listOrderByCondition(1L, "待出发", "北京", "2025-01-01"))
                .thenReturn(expected);
        List<TravelOrder> result = agencyService.getOrderByCondition(1L, "待出发", "北京", "2025-01-01");
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listOrderByCondition(1L, "待出发", "北京", "2025-01-01");
    }

    @Test
    void getOrderById_WhenExists_ShouldReturnOrder() {
        when(agencyMapper.getOrderById(1L)).thenReturn(testOrder);
        TravelOrder result = agencyService.getOrderById(1L);
        assertThat(result).isEqualTo(testOrder);
        verify(agencyMapper).getOrderById(1L);
    }

    @Test
    void getOrderById_WhenNotExists_ShouldReturnNull() {
        when(agencyMapper.getOrderById(99L)).thenReturn(null);
        TravelOrder result = agencyService.getOrderById(99L);
        assertThat(result).isNull();
        verify(agencyMapper).getOrderById(99L);
    }

    @Test
    void getRunningOrder_ShouldReturnList() {
        List<TravelOrder> expected = Arrays.asList(testOrder, createOrder(2L, "上海团"));
        when(agencyMapper.listRunningOrder()).thenReturn(expected);
        List<TravelOrder> result = agencyService.getRunningOrder();
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listRunningOrder();
    }

    @Test
    void addOrder_ShouldReturnInsertResult() {
        when(agencyMapper.insertTravelOrder(testOrder)).thenReturn(1);
        int result = agencyService.addOrder(testOrder);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertTravelOrder(testOrder);
    }

    @Test
    void updateOrderStatus_ShouldReturnUpdateResult() {
        when(agencyMapper.updateOrderStatus(testOrder)).thenReturn(1);
        int result = agencyService.updateOrderStatus(testOrder);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).updateOrderStatus(testOrder);
    }

    // ====================== 出境游管理 ======================
    @Test
    void getAbroadByAgency_ShouldReturnList() {
        List<AbroadTravel> expected = Collections.singletonList(testAbroad);
        when(agencyMapper.getAbroadByAgency(1L, "待审核")).thenReturn(expected);
        List<AbroadTravel> result = agencyService.getAbroadByAgency(1L, "待审核");
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).getAbroadByAgency(1L, "待审核");
    }

    @Test
    void getWaitAuditAbroad_ShouldReturnList() {
        List<AbroadTravel> expected = Arrays.asList(testAbroad, createAbroad(2L, "日本团"));
        when(agencyMapper.listWaitAuditAbroad()).thenReturn(expected);
        List<AbroadTravel> result = agencyService.getWaitAuditAbroad();
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listWaitAuditAbroad();
    }

    @Test
    void addAbroad_ShouldReturnInsertResult() {
        when(agencyMapper.insertAbroadTravel(testAbroad)).thenReturn(1);
        int result = agencyService.addAbroad(testAbroad);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertAbroadTravel(testAbroad);
    }

    @Test
    void updateVisa_ShouldReturnUpdateResult() {
        when(agencyMapper.updateVisaStatus(testAbroad)).thenReturn(1);
        int result = agencyService.updateVisa(testAbroad);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).updateVisaStatus(testAbroad);
    }

    // ====================== GIS 实时位置 ======================
    @Test
    void getAllLocation_ShouldReturnList() {
        List<VehicleRealLocation> expected = Collections.singletonList(testLocation);
        when(agencyMapper.listAllVehicleLocation()).thenReturn(expected);
        List<VehicleRealLocation> result = agencyService.getAllLocation();
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listAllVehicleLocation();
    }

    @Test
    void updateLocation_ShouldReturnUpdateResult() {
        when(agencyMapper.insertOrUpdateLocation(testLocation)).thenReturn(1);
        int result = agencyService.updateLocation(testLocation);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertOrUpdateLocation(testLocation);
    }

    // ====================== GIS 轨迹历史 ======================
    @Test
    void getTrackByVehicle_ShouldReturnList() {
        List<VehicleTrackHistory> expected = Collections.singletonList(testTrack);
        when(agencyMapper.listTrackByVehicleId(1L)).thenReturn(expected);
        List<VehicleTrackHistory> result = agencyService.getTrackByVehicle(1L);
        assertThat(result).isSameAs(expected);
        verify(agencyMapper).listTrackByVehicleId(1L);
    }

    @Test
    void addTrack_ShouldReturnInsertResult() {
        when(agencyMapper.insertVehicleTrack(testTrack)).thenReturn(1);
        int result = agencyService.addTrack(testTrack);
        assertThat(result).isEqualTo(1);
        verify(agencyMapper).insertVehicleTrack(testTrack);
    }

    // ====================== Helper 方法 ======================
    private TravelAgency createAgency(Long id, String name) {
        TravelAgency agency = new TravelAgency();
        agency.setId(id);
        agency.setAgencyName(name);
        return agency;
    }

    private TravelOrder createOrder(Long id, String teamName) {
        TravelOrder order = new TravelOrder();
        order.setId(id);
        order.setTeamName(teamName);
        return order;
    }

    private AbroadTravel createAbroad(Long id, String teamName) {
        AbroadTravel abroad = new AbroadTravel();
        abroad.setId(id);
        abroad.setTeamName(teamName);
        return abroad;
    }
}