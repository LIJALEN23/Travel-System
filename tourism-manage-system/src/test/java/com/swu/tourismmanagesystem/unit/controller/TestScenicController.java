package com.swu.tourismmanagesystem.unit.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.swu.tourismmanagesystem.config.CorsConfig;
import com.swu.tourismmanagesystem.config.LoginConfig;
import com.swu.tourismmanagesystem.controller.ScenicController;
import com.swu.tourismmanagesystem.entity.scenic.ScenicRealTimeData;
import com.swu.tourismmanagesystem.entity.scenic.ScenicSpot;
import com.swu.tourismmanagesystem.interceptor.LoginInterceptor;
import com.swu.tourismmanagesystem.service.ScenicService;
import com.swu.tourismmanagesystem.utils.JwtUtil;
import com.swu.tourismmanagesystem.utils.Result;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureWebMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@ExtendWith(MockitoExtension.class)
class TestScenicController {
    // 直接创建 Controller，不经过 Spring Web 容器
    @InjectMocks
    private ScenicController scenicController;

    // Mock 你的 Service
    @Mock
    private ScenicService scenicService;

    // 手动构建 MockMvc → 没有任何拦截器！
    private MockMvc mockMvc;

    private ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule()); // 加这一行！

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
                .standaloneSetup(scenicController) // 只加载当前Controller
                .build();
    }
    private ScenicSpot createSpot(Long id, String name) {
        ScenicSpot spot = new ScenicSpot();
        spot.setId(id);
        spot.setSpotName(name);
        spot.setMaxCapacity(10000);
        spot.setTotalParking(500);
        spot.setAddress("测试地址");
        spot.setLongitude(new BigDecimal("120.155"));
        spot.setLatitude(new BigDecimal("30.274"));
        spot.setMapUrl("http://map.com");
        spot.setCreateTime(LocalDateTime.now());
        spot.setUpdateTime(LocalDateTime.now());
        return spot;
    }

    private ScenicRealTimeData createRealTime(Long spotId, Integer visitors, Integer parking, Integer waitTime) {
        ScenicRealTimeData rt = new ScenicRealTimeData();
        rt.setId(1L);
        rt.setSpotId(spotId);
        rt.setCurrentVisitors(visitors);
        rt.setRemainingParking(parking);
        rt.setCableWaitTime(waitTime);
        rt.setUpdateTime(LocalDateTime.now());
        return rt;
    }

    // ==================== GET /spot/list ====================
    @Test
    void list_WithSpotName_ShouldReturnFilteredList() throws Exception {
        String spotName = "西湖";
        List<ScenicSpot> spots = Collections.singletonList(createSpot(1L, "西湖"));
        when(scenicService.getSpotListByName(spotName)).thenReturn(spots);

        mockMvc.perform(get("/spot/list").param("spotName", spotName))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
//                .andExpect(jsonPath("$.msg").value("查询景点列表成功"))
                .andExpect(jsonPath("$.data[0].spotName").value("西湖"));

        verify(scenicService).getSpotListByName(spotName);
        verify(scenicService, never()).findAllSpot();
    }

    @Test
    void list_WithoutSpotName_ShouldReturnAll() throws Exception {
        List<ScenicSpot> allSpots = Arrays.asList(createSpot(1L, "西湖"), createSpot(2L, "灵隐寺"));
        when(scenicService.findAllSpot()).thenReturn(allSpots);

        mockMvc.perform(get("/spot/list"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(2));

        verify(scenicService).findAllSpot();
        verify(scenicService, never()).getSpotListByName(any());
    }

    // ==================== GET /spot/detail ====================
    @Test
    void detail_WithValidId_ShouldReturnDetail() throws Exception {
        Long id = 1L;
        Map<String, Object> detail = new HashMap<>();
        detail.put("baseInfo", createSpot(1L, "西湖"));
        detail.put("realTimeData", null);
        detail.put("managerList", new ArrayList<>());
        detail.put("emergencyList", new ArrayList<>());
        when(scenicService.getSpotDetailById(id)).thenReturn(detail);

        mockMvc.perform(get("/spot/detail").param("id", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.msg").value("获取详情成功"))
                .andExpect(jsonPath("$.data.baseInfo.spotName").value("西湖"));

        verify(scenicService).getSpotDetailById(id);
    }

    @Test
    void detail_WithoutId_ShouldReturnError() throws Exception {
        mockMvc.perform(get("/spot/detail"))
                .andExpect(status().isBadRequest());
//                .andExpect(status().isOk())
//                .andExpect(jsonPath("$.code").value(500))
//                .andExpect(jsonPath("$.msg").value("景点ID不能为空"));

        verify(scenicService, never()).getSpotDetailById(any());
    }

    // ==================== GET /spot/nameList ====================
    @Test
    void getNameList_ShouldReturnNameList() throws Exception {
        List<ScenicSpot> allSpots = Arrays.asList(createSpot(1L, "西湖"), createSpot(2L, "灵隐寺"));
        when(scenicService.findAllSpot()).thenReturn(allSpots);
        when(scenicService.getSpotNameList(allSpots)).thenReturn(Arrays.asList("西湖", "灵隐寺"));

        mockMvc.perform(get("/spot/nameList"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.msg").value("获取成功"))
                .andExpect(jsonPath("$.data[0]").value("西湖"))
                .andExpect(jsonPath("$.data[1]").value("灵隐寺"));

        verify(scenicService).findAllSpot();
        verify(scenicService).getSpotNameList(allSpots);
    }

    // ==================== POST /spot/realTime/upload ====================
    @Test
    void uploadScenicRealTime_WhenSpotIdMissing_ShouldReturnError() throws Exception {
        ScenicRealTimeData rt = new ScenicRealTimeData();
        rt.setCurrentVisitors(1000);
        // spotId 缺失
        mockMvc.perform(post("/spot/realTime/upload")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(rt)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500));
//                .andExpect(jsonPath("$.msg").value("景点ID不能为空"));

        verify(scenicService, never()).getRealTimeByScenicId(any());
    }


    @Test
    void uploadScenicRealTime_WhenNotExists_ShouldInsert() throws Exception {
        ScenicRealTimeData rt = createRealTime(1L, 3500, 120, 15);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(null);
        when(scenicService.insertRealTime(any(ScenicRealTimeData.class))).thenReturn(1);

        mockMvc.perform(post("/spot/realTime/upload")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(rt)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.msg").value("景区实时数据上传成功"));

        verify(scenicService).insertRealTime(rt);
        verify(scenicService, never()).updateRealTime(any());
    }

    @Test
    void uploadScenicRealTime_WhenExists_ShouldUpdate() throws Exception {
        ScenicRealTimeData rt = createRealTime(1L, 4000, 80, 20);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(rt);
        when(scenicService.updateRealTime(any(ScenicRealTimeData.class))).thenReturn(1);

        mockMvc.perform(post("/spot/realTime/upload")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(rt)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.msg").value("景区实时数据上传成功"));

        verify(scenicService).updateRealTime(rt);
        verify(scenicService, never()).insertRealTime(any());
    }

    @Test
    void uploadScenicRealTime_WhenInsertFails_ShouldReturnError() throws Exception {
        ScenicRealTimeData rt = createRealTime(1L, 3500, 120, 15);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(null);
        when(scenicService.insertRealTime(rt)).thenReturn(0);

        mockMvc.perform(post("/spot/realTime/upload")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(rt)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500));
//                .andExpect(jsonPath("$.msg").value("景区实时数据保存失败"));
    }

    @Test
    void uploadScenicRealTime_WhenExceptionThrown_ShouldReturnErrorMessage() throws Exception {
        ScenicRealTimeData rt = createRealTime(1L, 3500, 120, 15);
        when(scenicService.getRealTimeByScenicId(1L)).thenThrow(new RuntimeException("数据库连接失败"));

        mockMvc.perform(post("/spot/realTime/upload")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(rt)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500));
//                .andExpect(jsonPath("$.msg").value("系统异常:数据库连接失败"));
    }

    // ==================== GET /spot/realTime ====================
    @Test
    void getScenicRealTime_WithValidSpotId_ShouldReturnData() throws Exception {
        ScenicRealTimeData data = createRealTime(1L, 3500, 120, 15);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(data);

        mockMvc.perform(get("/spot/realTime").param("spotId", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.msg").value("查询景区实时数据成功"))
                .andExpect(jsonPath("$.data.currentVisitors").value(3500))
                .andExpect(jsonPath("$.data.remainingParking").value(120));

        verify(scenicService).getRealTimeByScenicId(1L);
    }

    @Test
    void getScenicRealTime_WithoutSpotId_ShouldReturnError() throws Exception {
        mockMvc.perform(get("/spot/realTime"))
                .andExpect(status().isBadRequest());
        verify(scenicService, never()).getRealTimeByScenicId(any());
    }

    @Test
    void getScenicRealTime_WhenNoData_ShouldReturnNull() throws Exception {
        when(scenicService.getRealTimeByScenicId(99L)).thenReturn(null);

        mockMvc.perform(get("/spot/realTime").param("spotId", "99"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isEmpty());
    }
}