package com.swu.tourismmanagesystem.unit.service;

import com.swu.tourismmanagesystem.entity.scenic.*;
import com.swu.tourismmanagesystem.mapper.ScenicMapper;
import com.swu.tourismmanagesystem.service.impl.ScenicServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TestScenicService {

    @Mock
    private ScenicMapper scenicMapper;

    @InjectMocks
    private ScenicServiceImpl scenicService;

    private ScenicSpot testSpot;
    private ScenicManager testManager;
    private ScenicEmergency testEmergency;
    private ScenicRealTimeData testRealTime;

    @BeforeEach
    void setUp() {
        testSpot = new ScenicSpot();
        testSpot.setId(1L);
        testSpot.setSpotName("西湖");
        testSpot.setMaxCapacity(10000);
        testSpot.setTotalParking(500);
        testSpot.setAddress("杭州市");
        testSpot.setLongitude(new BigDecimal("120.155"));
        testSpot.setLatitude(new BigDecimal("30.274"));
        testSpot.setMapUrl("http://map.com/xihu");
        testSpot.setCreateTime(LocalDateTime.now());
        testSpot.setUpdateTime(LocalDateTime.now());

        testManager = new ScenicManager();
        testManager.setId(1L);
        testManager.setSpotId(1L);
        testManager.setWorkNo("M001");
        testManager.setManagerName("张经理");
        testManager.setPhone("13800000000");
        testManager.setPost("经理");
        testManager.setStatus(1);
        testManager.setCreateTime(LocalDateTime.now());

        testEmergency = new ScenicEmergency();
        testEmergency.setId(1L);
        testEmergency.setSpotId(1L);
        testEmergency.setRescuerName("李救援");
        testEmergency.setRescuerPhone("13900000000");
        testEmergency.setVehicleNo("浙A123");
        testEmergency.setCreateTime(LocalDateTime.now());

        testRealTime = new ScenicRealTimeData();
        testRealTime.setId(1L);
        testRealTime.setSpotId(1L);
        testRealTime.setCurrentVisitors(3500);
        testRealTime.setRemainingParking(120);
        testRealTime.setCableWaitTime(15);
        testRealTime.setUpdateTime(LocalDateTime.now());
    }

    // ==================== getSpotNameList ====================
    @Test
    void getSpotNameList_ShouldReturnNameList() {
        List<ScenicSpot> spots = Arrays.asList(testSpot, createSpot(2L, "灵隐寺"));
        List<String> names = scenicService.getSpotNameList(spots);
        assertThat(names).containsExactly("西湖", "灵隐寺");
    }

    @Test
    void getSpotNameList_ShouldReturnEmptyList_WhenInputEmpty() {
        List<String> names = scenicService.getSpotNameList(new ArrayList<>());
        assertThat(names).isEmpty();
    }

    // ==================== getSpotListByName ====================
    @Test
    void getSpotListByName_ShouldReturnMapperResult() {
        List<ScenicSpot> expected = Collections.singletonList(testSpot);
        when(scenicMapper.selectSpotByName("西湖")).thenReturn(expected);

        List<ScenicSpot> result = scenicService.getSpotListByName("西湖");
        assertThat(result).isSameAs(expected);
        verify(scenicMapper).selectSpotByName("西湖");
    }

    // ==================== getSpotDetailByName ====================
    @Test
    void getSpotDetailByName_ShouldReturnEmptyMap() {
        Map<String, Object> result = scenicService.getSpotDetailByName("任意名称");
        assertThat(result).isEmpty();
        verifyNoInteractions(scenicMapper);
    }

    // ==================== getSpotDetailById ====================
    @Test
    void getSpotDetailById_ShouldReturnAllData() {
        when(scenicMapper.selectSpotById(1L)).thenReturn(testSpot);
        when(scenicMapper.getRealTimeByScenicId(1L)).thenReturn(testRealTime);
        when(scenicMapper.selectManagerBySpotId(1L)).thenReturn(Collections.singletonList(testManager));
        when(scenicMapper.selectEmergencyBySpotId(1L)).thenReturn(Collections.singletonList(testEmergency));

        Map<String, Object> result = scenicService.getSpotDetailById(1L);

        assertThat(result).containsKeys("baseInfo", "realTimeData", "managerList", "emergencyList");
        assertThat(result.get("baseInfo")).isEqualTo(testSpot);
        assertThat(result.get("realTimeData")).isEqualTo(testRealTime);
        assertThat(result.get("managerList")).isEqualTo(Collections.singletonList(testManager));
        assertThat(result.get("emergencyList")).isEqualTo(Collections.singletonList(testEmergency));

        verify(scenicMapper).selectSpotById(1L);
        verify(scenicMapper).getRealTimeByScenicId(1L);
        verify(scenicMapper).selectManagerBySpotId(1L);
        verify(scenicMapper).selectEmergencyBySpotId(1L);
    }

    @Test
    void getSpotDetailById_ShouldHandleNullValues() {
        when(scenicMapper.selectSpotById(1L)).thenReturn(null);
        when(scenicMapper.getRealTimeByScenicId(1L)).thenReturn(null);
        when(scenicMapper.selectManagerBySpotId(1L)).thenReturn(null);
        when(scenicMapper.selectEmergencyBySpotId(1L)).thenReturn(null);

        Map<String, Object> result = scenicService.getSpotDetailById(1L);

        assertThat(result.get("baseInfo")).isNull();
        assertThat(result.get("realTimeData")).isNull();
        assertThat(result.get("managerList")).isNull();
        assertThat(result.get("emergencyList")).isNull();
    }

    // ==================== findAllSpot ====================
    @Test
    void findAllSpot_ShouldReturnList() {
        List<ScenicSpot> expected = Arrays.asList(testSpot, createSpot(2L, "雷峰塔"));
        when(scenicMapper.selectSpotAll()).thenReturn(expected);

        List<ScenicSpot> result = scenicService.findAllSpot();
        assertThat(result).isSameAs(expected);
        verify(scenicMapper).selectSpotAll();
    }

    // ==================== findSpotById ====================
    @Test
    void findSpotById_ShouldReturnSpot() {
        when(scenicMapper.selectSpotById(1L)).thenReturn(testSpot);
        ScenicSpot result = scenicService.findSpotById(1L);
        assertThat(result).isEqualTo(testSpot);
        verify(scenicMapper).selectSpotById(1L);
    }

    @Test
    void findSpotById_ShouldReturnNull_WhenNotExists() {
        when(scenicMapper.selectSpotById(99L)).thenReturn(null);
        ScenicSpot result = scenicService.findSpotById(99L);
        assertThat(result).isNull();
        verify(scenicMapper).selectSpotById(99L);
    }

    // ==================== addSpot ====================
    @Test
    void addSpot_ShouldReturnTrue_WhenInsertSuccess() {
        when(scenicMapper.insertSpot(testSpot)).thenReturn(1);
        boolean result = scenicService.addSpot(testSpot);
        assertThat(result).isTrue();
        verify(scenicMapper).insertSpot(testSpot);
    }

    @Test
    void addSpot_ShouldReturnFalse_WhenInsertFails() {
        when(scenicMapper.insertSpot(testSpot)).thenReturn(0);
        boolean result = scenicService.addSpot(testSpot);
        assertThat(result).isFalse();
        verify(scenicMapper).insertSpot(testSpot);
    }

    // ==================== updateSpot ====================
    @Test
    void updateSpot_ShouldReturnTrue_WhenUpdateSuccess() {
        when(scenicMapper.updateSpot(testSpot)).thenReturn(1);
        boolean result = scenicService.updateSpot(testSpot);
        assertThat(result).isTrue();
        verify(scenicMapper).updateSpot(testSpot);
    }

    @Test
    void updateSpot_ShouldReturnFalse_WhenUpdateFails() {
        when(scenicMapper.updateSpot(testSpot)).thenReturn(0);
        boolean result = scenicService.updateSpot(testSpot);
        assertThat(result).isFalse();
        verify(scenicMapper).updateSpot(testSpot);
    }

    // ==================== deleteSpot ====================
    @Test
    void deleteSpot_ShouldReturnTrue_WhenDeleteSuccess() {
        when(scenicMapper.deleteSpot(1L)).thenReturn(1);
        boolean result = scenicService.deleteSpot(1L);
        assertThat(result).isTrue();
        verify(scenicMapper).deleteSpot(1L);
    }

    @Test
    void deleteSpot_ShouldReturnFalse_WhenDeleteFails() {
        when(scenicMapper.deleteSpot(1L)).thenReturn(0);
        boolean result = scenicService.deleteSpot(1L);
        assertThat(result).isFalse();
        verify(scenicMapper).deleteSpot(1L);
    }

    // ==================== findManagerBySpotId ====================
    @Test
    void findManagerBySpotId_ShouldReturnList() {
        List<ScenicManager> expected = Collections.singletonList(testManager);
        when(scenicMapper.selectManagerBySpotId(1L)).thenReturn(expected);
        List<ScenicManager> result = scenicService.findManagerBySpotId(1L);
        assertThat(result).isSameAs(expected);
        verify(scenicMapper).selectManagerBySpotId(1L);
    }

    // ==================== addManager ====================
    @Test
    void addManager_ShouldReturnTrue_WhenInsertSuccess() {
        when(scenicMapper.insertManager(testManager)).thenReturn(1);
        boolean result = scenicService.addManager(testManager);
        assertThat(result).isTrue();
        verify(scenicMapper).insertManager(testManager);
    }

    @Test
    void addManager_ShouldReturnFalse_WhenInsertFails() {
        when(scenicMapper.insertManager(testManager)).thenReturn(0);
        boolean result = scenicService.addManager(testManager);
        assertThat(result).isFalse();
        verify(scenicMapper).insertManager(testManager);
    }

    // ==================== findEmergenceBySpotId ====================
    @Test
    void findEmergenceBySpotId_ShouldReturnList() {
        List<ScenicEmergency> expected = Collections.singletonList(testEmergency);
        when(scenicMapper.selectEmergencyBySpotId(1L)).thenReturn(expected);
        List<ScenicEmergency> result = scenicService.findEmergenceBySpotId(1L);
        assertThat(result).isSameAs(expected);
        verify(scenicMapper).selectEmergencyBySpotId(1L);
    }

    // ==================== addEmergency ====================
    @Test
    void addEmergency_ShouldReturnTrue_WhenInsertSuccess() {
        when(scenicMapper.insertEmergency(testEmergency)).thenReturn(1);
        boolean result = scenicService.addEmergency(testEmergency);
        assertThat(result).isTrue();
        verify(scenicMapper).insertEmergency(testEmergency);
    }

    @Test
    void addEmergency_ShouldReturnFalse_WhenInsertFails() {
        when(scenicMapper.insertEmergency(testEmergency)).thenReturn(0);
        boolean result = scenicService.addEmergency(testEmergency);
        assertThat(result).isFalse();
        verify(scenicMapper).insertEmergency(testEmergency);
    }

    // ==================== getRealTimeByScenicId ====================
    @Test
    void getRealTimeByScenicId_ShouldReturnData() {
        when(scenicMapper.getRealTimeByScenicId(1L)).thenReturn(testRealTime);
        ScenicRealTimeData result = scenicService.getRealTimeByScenicId(1L);
        assertThat(result).isEqualTo(testRealTime);
        verify(scenicMapper).getRealTimeByScenicId(1L);
    }

    // ==================== insertRealTime ====================
    @Test
    void insertRealTime_ShouldReturnInsertResult() {
        when(scenicMapper.insertRealTime(testRealTime)).thenReturn(1);
        int result = scenicService.insertRealTime(testRealTime);
        assertThat(result).isEqualTo(1);
        verify(scenicMapper).insertRealTime(testRealTime);
    }

    // ==================== updateRealTime ====================
    @Test
    void updateRealTime_ShouldReturnUpdateResult() {
        when(scenicMapper.updateRealTime(testRealTime)).thenReturn(1);
        int result = scenicService.updateRealTime(testRealTime);
        assertThat(result).isEqualTo(1);
        verify(scenicMapper).updateRealTime(testRealTime);
    }

    // ==================== getScenicIdsWithRealData ====================
    @Test
    void getScenicIdsWithRealData_ShouldReturnIdList() {
        List<Long> expected = Arrays.asList(1L, 2L, 3L);
        when(scenicMapper.selectScenicIdsWithRealData()).thenReturn(expected);
        List<Long> result = scenicService.getScenicIdsWithRealData();
        assertThat(result).isSameAs(expected);
        verify(scenicMapper).selectScenicIdsWithRealData();
    }

    // ==================== helper ====================
    private ScenicSpot createSpot(Long id, String name) {
        ScenicSpot spot = new ScenicSpot();
        spot.setId(id);
        spot.setSpotName(name);
        return spot;
    }
}