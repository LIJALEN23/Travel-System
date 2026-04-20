package com.swu.tourismmanagesystem.unit.service;

import com.swu.tourismmanagesystem.entity.hotel.*;
import com.swu.tourismmanagesystem.mapper.HotelMapper;
import com.swu.tourismmanagesystem.service.impl.HotelServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TestHotelService {

    @Mock
    private HotelMapper hotelMapper;

    @InjectMocks
    private HotelServiceImpl hotelService;

    private HotelBase testHotel;
    private HotelManager testManager;
    private HotelEmergency testEmergency;
    private HotelRealTimeData testRealTime;
    private Map<String, Object> testHotelDetail;

    @BeforeEach
    void setUp() {
        testHotel = new HotelBase();
        testHotel.setId(1L);
        testHotel.setHotelName("西湖大酒店");
        testHotel.setStarLevel(5);
        testHotel.setMaxCapacity(500);
        testHotel.setTotalParking(200);
        testHotel.setAddress("杭州市西湖区");
        testHotel.setLongitude(120.155);
        testHotel.setLatitude(30.274);
        testHotel.setMapUrl("http://map.com/hotel1");
        testHotel.setCreateTime(LocalDateTime.now());
        testHotel.setUpdateTime(LocalDateTime.now());

        testManager = new HotelManager();
        testManager.setId(1L);
        testManager.setHotelId(1L);
        testManager.setWorkNo("H001");
        testManager.setManagerName("王经理");
        testManager.setPhone("13800138000");
        testManager.setPost("总经理");
        testManager.setStatus(1);
        testManager.setCreateTime(LocalDateTime.now());

        testEmergency = new HotelEmergency();
        testEmergency.setId(1L);
        testEmergency.setHotelId(1L);
        testEmergency.setRescuerName("李救援");
        testEmergency.setRescuerPhone("13900139000");
        testEmergency.setVehicleNo("浙A123");
        testEmergency.setCreateTime(LocalDateTime.now());

        testRealTime = new HotelRealTimeData();
        testRealTime.setId(1L);
        testRealTime.setHotelId(1L);
        testRealTime.setCurrentVisitors(350);
        testRealTime.setRemainingParking(80);
        testRealTime.setOccupancyRate(70.0);
        testRealTime.setUpdateTime(LocalDateTime.now());

        testHotelDetail = new HashMap<>();
        testHotelDetail.put("id", 1L);
        testHotelDetail.put("hotelName", "西湖大酒店");
        testHotelDetail.put("starLevel", 5);
    }

    // ==================== getHotelListByName ====================
    @Test
    void getHotelListByName_ShouldReturnMapperResult() {
        List<HotelBase> expected = Collections.singletonList(testHotel);
        when(hotelMapper.selectHotelByCondition("西湖", 5)).thenReturn(expected);

        List<HotelBase> result = hotelService.getHotelListByName("西湖", 5);
        assertThat(result).isSameAs(expected);
        verify(hotelMapper).selectHotelByCondition("西湖", 5);
    }

    @Test
    void getHotelListByName_ShouldHandleNullParams() {
        when(hotelMapper.selectHotelByCondition(null, null)).thenReturn(new ArrayList<>());
        List<HotelBase> result = hotelService.getHotelListByName(null, null);
        assertThat(result).isEmpty();
        verify(hotelMapper).selectHotelByCondition(null, null);
    }

    // ==================== findAllHotel ====================
    @Test
    void findAllHotel_ShouldReturnAll() {
        List<HotelBase> expected = Arrays.asList(testHotel, createHotel(2L, "雷峰塔酒店"));
        when(hotelMapper.selectAllHotel()).thenReturn(expected);

        List<HotelBase> result = hotelService.findAllHotel();
        assertThat(result).isSameAs(expected);
        verify(hotelMapper).selectAllHotel();
    }

    // ==================== getHotelDetailById ====================
    @Test
    void getHotelDetailById_ShouldReturnDetailMap() {
        when(hotelMapper.selectHotelDetailById(1L)).thenReturn(testHotelDetail);
        when(hotelMapper.selectManagerByHotelId(1L)).thenReturn(Collections.singletonList(testManager));
        when(hotelMapper.selectEmergencyByHotelId(1L)).thenReturn(Collections.singletonList(testEmergency));
        when(hotelMapper.selectRealDataByHotelId(1L)).thenReturn(testRealTime);

        Map<String, Object> result = hotelService.getHotelDetailById(1L);

        assertThat(result).containsKeys("baseInfo", "managerList", "emergencyList", "realTimeData");
        assertThat(result.get("baseInfo")).isEqualTo(testHotelDetail);
        assertThat(result.get("managerList")).isEqualTo(Collections.singletonList(testManager));
        assertThat(result.get("emergencyList")).isEqualTo(Collections.singletonList(testEmergency));
        assertThat(result.get("realTimeData")).isEqualTo(testRealTime);

        verify(hotelMapper).selectHotelDetailById(1L);
        verify(hotelMapper).selectManagerByHotelId(1L);
        verify(hotelMapper).selectEmergencyByHotelId(1L);
        verify(hotelMapper).selectRealDataByHotelId(1L);
    }

    @Test
    void getHotelDetailById_ShouldHandleNullValues() {
        when(hotelMapper.selectHotelDetailById(1L)).thenReturn(null);
        when(hotelMapper.selectManagerByHotelId(1L)).thenReturn(null);
        when(hotelMapper.selectEmergencyByHotelId(1L)).thenReturn(null);
        when(hotelMapper.selectRealDataByHotelId(1L)).thenReturn(null);

        Map<String, Object> result = hotelService.getHotelDetailById(1L);
        assertThat(result.get("baseInfo")).isNull();
        assertThat(result.get("managerList")).isNull();
        assertThat(result.get("emergencyList")).isNull();
        assertThat(result.get("realTimeData")).isNull();
    }

    // ==================== findHotelByScenicId ====================
    @Test
    void findHotelByScenicId_ShouldReturnList() {
        List<HotelBase> expected = Collections.singletonList(testHotel);
        when(hotelMapper.selectHotelByScenicId(10L)).thenReturn(expected);

        List<HotelBase> result = hotelService.findHotelByScenicId(10L);
        assertThat(result).isSameAs(expected);
        verify(hotelMapper).selectHotelByScenicId(10L);
    }

    // ==================== getHotelNameList ====================
    @Test
    void getHotelNameList_ShouldReturnNameList() {
        List<HotelBase> hotels = Arrays.asList(testHotel, createHotel(2L, "灵隐酒店"));
        List<String> names = hotelService.getHotelNameList(hotels);
        assertThat(names).containsExactly("西湖大酒店", "灵隐酒店");
    }

    @Test
    void getHotelNameList_ShouldReturnEmpty_WhenInputEmpty() {
        List<String> names = hotelService.getHotelNameList(new ArrayList<>());
        assertThat(names).isEmpty();
    }

    // ==================== getRealTimeByHotelId ====================
    @Test
    void getRealTimeByHotelId_ShouldReturnData() {
        when(hotelMapper.selectRealDataByHotelId(1L)).thenReturn(testRealTime);
        HotelRealTimeData result = hotelService.getRealTimeByHotelId(1L);
        assertThat(result).isEqualTo(testRealTime);
        verify(hotelMapper).selectRealDataByHotelId(1L);
    }

    // ==================== saveOrUpdateRealTime ====================
    @Test
    void saveOrUpdateRealTime_ShouldThrowException_WhenHotelIdNull() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setCurrentVisitors(100);
        assertThatThrownBy(() -> hotelService.saveOrUpdateRealTime(data))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("酒店ID不能为空");
        verifyNoInteractions(hotelMapper);
    }

    @Test
    void saveOrUpdateRealTime_ShouldThrowException_WhenCurrentVisitorsNull() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        assertThatThrownBy(() -> hotelService.saveOrUpdateRealTime(data))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("当前游客数不能为空");
        verifyNoInteractions(hotelMapper);
    }

    @Test
    void saveOrUpdateRealTime_ShouldThrowException_WhenMaxCapacityNull() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(200);
        when(hotelMapper.selectMaxCapacityByHotelId(1L)).thenReturn(null);

        assertThatThrownBy(() -> hotelService.saveOrUpdateRealTime(data))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("最大容量未设置或为0");
        verify(hotelMapper).selectMaxCapacityByHotelId(1L);
        verify(hotelMapper, never()).insertRealTimeData(any());
        verify(hotelMapper, never()).updateRealTimeData(any());
    }

    @Test
    void saveOrUpdateRealTime_ShouldThrowException_WhenMaxCapacityZero() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(200);
        when(hotelMapper.selectMaxCapacityByHotelId(1L)).thenReturn(0);

        assertThatThrownBy(() -> hotelService.saveOrUpdateRealTime(data))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("最大容量未设置或为0");
        verify(hotelMapper).selectMaxCapacityByHotelId(1L);
        verify(hotelMapper, never()).insertRealTimeData(any());
        verify(hotelMapper, never()).updateRealTimeData(any());
    }

    @Test
    void saveOrUpdateRealTime_ShouldInsert_WhenNotExists() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(250);
        when(hotelMapper.selectMaxCapacityByHotelId(1L)).thenReturn(500);
        when(hotelMapper.selectRealDataByHotelId(1L)).thenReturn(null);
        when(hotelMapper.insertRealTimeData(any(HotelRealTimeData.class))).thenReturn(1);

        hotelService.saveOrUpdateRealTime(data);

        // 验证入住率计算：250/500*100=50.0
        assertThat(data.getOccupancyRate()).isEqualTo(50.0);
        verify(hotelMapper).selectMaxCapacityByHotelId(1L);
        verify(hotelMapper).selectRealDataByHotelId(1L);
        verify(hotelMapper).insertRealTimeData(data);
        verify(hotelMapper, never()).updateRealTimeData(any());
    }

    @Test
    void saveOrUpdateRealTime_ShouldUpdate_WhenExists() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(320);
        when(hotelMapper.selectMaxCapacityByHotelId(1L)).thenReturn(500);
        when(hotelMapper.selectRealDataByHotelId(1L)).thenReturn(testRealTime);
        when(hotelMapper.updateRealTimeData(any(HotelRealTimeData.class))).thenReturn(1);

        hotelService.saveOrUpdateRealTime(data);

        // 入住率：320/500*100=64.0
        assertThat(data.getOccupancyRate()).isEqualTo(64.0);
        verify(hotelMapper).selectMaxCapacityByHotelId(1L);
        verify(hotelMapper).selectRealDataByHotelId(1L);
        verify(hotelMapper).updateRealTimeData(data);
        verify(hotelMapper, never()).insertRealTimeData(any());
    }

    @Test
    void saveOrUpdateRealTime_ShouldRoundOccupancyRateToOneDecimal() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(333);
        when(hotelMapper.selectMaxCapacityByHotelId(1L)).thenReturn(500);
        when(hotelMapper.selectRealDataByHotelId(1L)).thenReturn(null);
        when(hotelMapper.insertRealTimeData(any())).thenReturn(1);

        hotelService.saveOrUpdateRealTime(data);

        // 333/500=66.6%，Math.round(66.6*10)/10.0 = 66.6
        assertThat(data.getOccupancyRate()).isEqualTo(66.6);
    }

    // ==================== getHotelIdsWithRealData ====================
    @Test
    void getHotelIdsWithRealData_ShouldReturnIdList() {
        List<Long> expected = Arrays.asList(1L, 2L, 3L);
        when(hotelMapper.selectHotelIdsWithRealData()).thenReturn(expected);
        List<Long> result = hotelService.getHotelIdsWithRealData();
        assertThat(result).isSameAs(expected);
        verify(hotelMapper).selectHotelIdsWithRealData();
    }

    // ==================== Helper ====================
    private HotelBase createHotel(Long id, String name) {
        HotelBase hotel = new HotelBase();
        hotel.setId(id);
        hotel.setHotelName(name);
        return hotel;
    }
}