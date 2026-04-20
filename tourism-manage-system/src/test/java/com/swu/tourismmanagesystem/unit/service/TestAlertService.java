package com.swu.tourismmanagesystem.unit.service;

import com.swu.tourismmanagesystem.entity.alertmessage.AlertHandle;
import com.swu.tourismmanagesystem.entity.alertmessage.AlertMessage;
import com.swu.tourismmanagesystem.entity.hotel.HotelBase;
import com.swu.tourismmanagesystem.entity.hotel.HotelRealTimeData;
import com.swu.tourismmanagesystem.entity.scenic.ScenicRealTimeData;
import com.swu.tourismmanagesystem.entity.scenic.ScenicSpot;
import com.swu.tourismmanagesystem.mapper.AlertMessageMapper;
import com.swu.tourismmanagesystem.service.AgencyService;
import com.swu.tourismmanagesystem.service.HotelService;
import com.swu.tourismmanagesystem.service.ScenicService;
import com.swu.tourismmanagesystem.service.impl.AlertServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TestAlertService {

    @Mock
    private AlertMessageMapper alertMapper;
    @Mock
    private ScenicService scenicService;
    @Mock
    private HotelService hotelService;
    @Mock
    private AgencyService agencyService; // 虽未使用但需注入

    @InjectMocks
    private AlertServiceImpl alertService;

    private ScenicSpot testSpot;
    private ScenicRealTimeData testScenicReal;
    private HotelBase testHotel;
    private HotelRealTimeData testHotelReal;
    private AlertMessage existingAlert;

    @BeforeEach
    void setUp() {
        testSpot = new ScenicSpot();
        testSpot.setId(1L);
        testSpot.setSpotName("西湖");
        testSpot.setMaxCapacity(10000);
        testSpot.setTotalParking(500);

        testScenicReal = new ScenicRealTimeData();
        testScenicReal.setSpotId(1L);
        testScenicReal.setCurrentVisitors(8500);
        testScenicReal.setRemainingParking(50);
        testScenicReal.setCableWaitTime(45);

        testHotel = new HotelBase();
        testHotel.setId(1L);
        testHotel.setHotelName("西湖大酒店");
        testHotel.setTotalParking(200);
        testHotel.setMaxCapacity(500);

        testHotelReal = new HotelRealTimeData();
        testHotelReal.setHotelId(1L);
        testHotelReal.setOccupancyRate(92.5);
        testHotelReal.setRemainingParking(20);

        existingAlert = new AlertMessage();
        existingAlert.setId(10L);
        existingAlert.setContent("西湖?客流量(85%)?停车位(90%)?缆车等待(45分钟)");
        existingAlert.setMsgType("prompt");
        existingAlert.setStatus(0);
        existingAlert.setExtInfo("SCENE_1");
        existingAlert.setCreateTime(LocalDateTime.now().minusHours(1));
        existingAlert.setUpdateTime(LocalDateTime.now().minusHours(1));
    }

    // ==================== autoCheckAndGenerateMessage ====================
    @Test
    void autoCheckAndGenerateMessage_ShouldProcessScenicAndHotel() {
        // Mock 景区数据
        List<Long> scenicIds = Collections.singletonList(1L);
        when(scenicService.getScenicIdsWithRealData()).thenReturn(scenicIds);
        when(scenicService.findSpotById(1L)).thenReturn(testSpot);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(testScenicReal);
        // 景区告警触发（客流85%，停车位使用率(500-50)/500=90%，缆车等待45 >= 30）
        // 期望调用 alertMapper.selectUnprocessedAlertByContentAndType
        when(alertMapper.selectUnprocessedAlertByContentAndType(anyString(), eq("prompt"), eq("SCENE_1")))
                .thenReturn(null);
        when(alertMapper.insertMessage(any(AlertMessage.class))).thenReturn(1);

        // Mock 酒店数据
        List<Long> hotelIds = Collections.singletonList(1L);
        when(hotelService.getHotelIdsWithRealData()).thenReturn(hotelIds);
        List<HotelBase> allHotels = Collections.singletonList(testHotel);
        when(hotelService.findAllHotel()).thenReturn(allHotels);
        Map<String, Object> detailMap = new HashMap<>();
        detailMap.put("realTimeData", testHotelReal);
        when(hotelService.getHotelDetailById(1L)).thenReturn(detailMap);
        when(alertMapper.selectUnprocessedAlertByContentAndType(anyString(), eq("prompt"), eq("HOTEL_1")))
                .thenReturn(null);
        when(alertMapper.insertMessage(any(AlertMessage.class))).thenReturn(1);

        // 执行
        alertService.autoCheckAndGenerateMessage();

        // 验证景区插入了1条告警
        ArgumentCaptor<AlertMessage> captor = ArgumentCaptor.forClass(AlertMessage.class);
        verify(alertMapper, times(2)).insertMessage(captor.capture());
        List<AlertMessage> inserted = captor.getAllValues();
        assertThat(inserted).hasSize(2);
        assertThat(inserted.get(0).getExtInfo()).isEqualTo("SCENE_1");
        assertThat(inserted.get(0).getContent()).contains("西湖", "客流量(85%)", "停车位(90%)", "缆车等待(45分钟)");
        assertThat(inserted.get(1).getExtInfo()).isEqualTo("HOTEL_1");
        assertThat(inserted.get(1).getContent()).contains("西湖大酒店", "入住率(92.5%)", "停车位(90%)");

        // 验证未调用更新
        verify(alertMapper, never()).updateMessage(any());
    }

    @Test
    void autoCheckAndGenerateMessage_ShouldUpdateExistingUnprocessedAlert() {
        List<Long> scenicIds = Collections.singletonList(1L);
        when(scenicService.getScenicIdsWithRealData()).thenReturn(scenicIds);
        when(scenicService.findSpotById(1L)).thenReturn(testSpot);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(testScenicReal);
        when(alertMapper.selectUnprocessedAlertByContentAndType(anyString(), eq("prompt"), eq("SCENE_1")))
                .thenReturn(existingAlert);
        when(alertMapper.updateMessage(any(AlertMessage.class))).thenReturn(1);

        // 酒店无数据
        when(hotelService.getHotelIdsWithRealData()).thenReturn(Collections.emptyList());

        alertService.autoCheckAndGenerateMessage();

        verify(alertMapper, never()).insertMessage(any());
        verify(alertMapper).updateMessage(argThat(msg -> {
            assertThat(msg.getId()).isEqualTo(10L);
            assertThat(msg.getContent()).contains("西湖", "客流量(85%)", "停车位(90%)", "缆车等待(45分钟)");
            assertThat(msg.getUpdateTime()).isNotNull();
            return true;
        }));
    }

    @Test
    void autoCheckAndGenerateMessage_ShouldNotGenerateAlertWhenThresholdNotMet() {
        // 客流未达阈值
        testScenicReal.setCurrentVisitors(5000); // 50%
        testScenicReal.setRemainingParking(400); // 使用率20%
        testScenicReal.setCableWaitTime(20);     // <30
        List<Long> scenicIds = Collections.singletonList(1L);
        when(scenicService.getScenicIdsWithRealData()).thenReturn(scenicIds);
        when(scenicService.findSpotById(1L)).thenReturn(testSpot);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(testScenicReal);
        when(hotelService.getHotelIdsWithRealData()).thenReturn(Collections.emptyList());

        alertService.autoCheckAndGenerateMessage();

        verify(alertMapper, never()).insertMessage(any());
        verify(alertMapper, never()).updateMessage(any());
    }

    @Test
    void autoCheckAndGenerateMessage_ShouldHandleMissingRealTimeData() {
        List<Long> scenicIds = Collections.singletonList(1L);
        when(scenicService.getScenicIdsWithRealData()).thenReturn(scenicIds);
        when(scenicService.findSpotById(1L)).thenReturn(testSpot);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(null); // 无实时数据
        when(hotelService.getHotelIdsWithRealData()).thenReturn(Collections.emptyList());

        alertService.autoCheckAndGenerateMessage();

        verify(alertMapper, never()).insertMessage(any());
        verify(alertMapper, never()).updateMessage(any());
    }

    @Test
    void autoCheckAndGenerateMessage_ShouldHandleHotelWithMissingDetail() {
        List<Long> hotelIds = Collections.singletonList(1L);
        when(hotelService.getHotelIdsWithRealData()).thenReturn(hotelIds);
        when(hotelService.findAllHotel()).thenReturn(Collections.singletonList(testHotel));
        Map<String, Object> detailMap = new HashMap<>();
        detailMap.put("realTimeData", null); // 无实时数据
        when(hotelService.getHotelDetailById(1L)).thenReturn(detailMap);
        when(scenicService.getScenicIdsWithRealData()).thenReturn(Collections.emptyList());

        alertService.autoCheckAndGenerateMessage();

        verify(alertMapper, never()).insertMessage(any());
        verify(alertMapper, never()).updateMessage(any());
    }

    @Test
    void autoCheckAndGenerateMessage_ShouldDeduplicateAcrossMultipleCalls() {
        // 第一次调用
        List<Long> scenicIds = Collections.singletonList(1L);
        when(scenicService.getScenicIdsWithRealData()).thenReturn(scenicIds);
        when(scenicService.findSpotById(1L)).thenReturn(testSpot);
        when(scenicService.getRealTimeByScenicId(1L)).thenReturn(testScenicReal);
        when(alertMapper.selectUnprocessedAlertByContentAndType(anyString(), eq("prompt"), eq("SCENE_1")))
                .thenReturn(null);
        when(alertMapper.insertMessage(any())).thenReturn(1);
        when(hotelService.getHotelIdsWithRealData()).thenReturn(Collections.emptyList());

        alertService.autoCheckAndGenerateMessage();
        // 第二次调用，同一个景区，但此时 duplicateSet 已包含 "SCENE_1"，不会再生成告警
        alertService.autoCheckAndGenerateMessage();

        // 应只插入一次
        verify(alertMapper, times(1)).insertMessage(any());
    }

    // ==================== getLatestUnprocessedAlerts ====================
    @Test
    void getLatestUnprocessedAlerts_ShouldReturnMapperResult() {
        List<AlertMessage> expected = Collections.singletonList(existingAlert);
        when(alertMapper.selectLatestUnprocessedAlerts()).thenReturn(expected);
        List<AlertMessage> result = alertService.getLatestUnprocessedAlerts();
        assertThat(result).isSameAs(expected);
        verify(alertMapper).selectLatestUnprocessedAlerts();
    }

    // ==================== createMessage ====================
    @Test
    void createMessage_ShouldSetStatusAndTimesAndInsert() {
        AlertMessage msg = new AlertMessage();
        msg.setContent("测试告警");
        when(alertMapper.insertMessage(any(AlertMessage.class))).thenReturn(1);

        int result = alertService.createMessage(msg);

        assertThat(result).isEqualTo(1);
        assertThat(msg.getStatus()).isEqualTo(0);
        assertThat(msg.getCreateTime()).isNotNull();
        assertThat(msg.getUpdateTime()).isNotNull();
        verify(alertMapper).insertMessage(msg);
    }

    // ==================== getMessageById ====================
    @Test
    void getMessageById_ShouldReturnMapperResult() {
        when(alertMapper.getMessageById(10L)).thenReturn(existingAlert);
        AlertMessage result = alertService.getMessageById(10L);
        assertThat(result).isEqualTo(existingAlert);
        verify(alertMapper).getMessageById(10L);
    }

    // ==================== getMessageList ====================
    @Test
    void getMessageList_ShouldReturnMapperResult() {
        List<AlertMessage> expected = Collections.singletonList(existingAlert);
        when(alertMapper.getMessageList()).thenReturn(expected);
        List<AlertMessage> result = alertService.getMessageList();
        assertThat(result).isSameAs(expected);
        verify(alertMapper).getMessageList();
    }

    // ==================== checkPass ====================
    @Test
    void checkPass_ShouldUpdateStatusAndOperator() {
        when(alertMapper.updateMessage(any(AlertMessage.class))).thenReturn(1);
        int result = alertService.checkPass(10L, "operator123");
        assertThat(result).isEqualTo(1);
        ArgumentCaptor<AlertMessage> captor = ArgumentCaptor.forClass(AlertMessage.class);
        verify(alertMapper).updateMessage(captor.capture());
        AlertMessage updated = captor.getValue();
        assertThat(updated.getId()).isEqualTo(10L);
        assertThat(updated.getStatus()).isEqualTo(1);
        assertThat(updated.getOperator()).isEqualTo("operator123");
        assertThat(updated.getUpdateTime()).isNotNull();
    }

    // ==================== publish ====================
    @Test
    void publish_ShouldUpdateStatusAndLeader() {
        when(alertMapper.updateMessage(any(AlertMessage.class))).thenReturn(1);
        int result = alertService.publish(10L, "leader456");
        assertThat(result).isEqualTo(1);
        ArgumentCaptor<AlertMessage> captor = ArgumentCaptor.forClass(AlertMessage.class);
        verify(alertMapper).updateMessage(captor.capture());
        AlertMessage updated = captor.getValue();
        assertThat(updated.getId()).isEqualTo(10L);
        assertThat(updated.getStatus()).isEqualTo(2);
        assertThat(updated.getLeader()).isEqualTo("leader456");
    }

    // ==================== handle ====================
    @Test
    void handle_ShouldUpdateMessageAndInsertHandle() {
        when(alertMapper.updateMessage(any(AlertMessage.class))).thenReturn(1);
        when(alertMapper.insertHandle(any(AlertHandle.class))).thenReturn(1);

        int result = alertService.handle(10L, "已处理完毕", "handler789");
        assertThat(result).isEqualTo(1);

        // 验证消息更新
        ArgumentCaptor<AlertMessage> msgCaptor = ArgumentCaptor.forClass(AlertMessage.class);
        verify(alertMapper).updateMessage(msgCaptor.capture());
        AlertMessage updatedMsg = msgCaptor.getValue();
        assertThat(updatedMsg.getId()).isEqualTo(10L);
        assertThat(updatedMsg.getStatus()).isEqualTo(3);
        assertThat(updatedMsg.getUpdateTime()).isNotNull();

        // 验证处理记录插入
        ArgumentCaptor<AlertHandle> handleCaptor = ArgumentCaptor.forClass(AlertHandle.class);
        verify(alertMapper).insertHandle(handleCaptor.capture());
        AlertHandle handle = handleCaptor.getValue();
        assertThat(handle.getAlertId()).isEqualTo(10L);
        assertThat(handle.getHandleResult()).isEqualTo("已处理完毕");
        assertThat(handle.getHandler()).isEqualTo("handler789");
        assertThat(handle.getHandleTime()).isNotNull();
    }

    // ==================== getHandleList ====================
    @Test
    void getHandleList_ShouldReturnMapperResult() {
        AlertHandle handle = new AlertHandle();
        handle.setId(1L);
        handle.setAlertId(10L);
        handle.setHandleResult("已处理");
        List<AlertHandle> expected = Collections.singletonList(handle);
        when(alertMapper.getHandlesByAlertId(10L)).thenReturn(expected);
        List<AlertHandle> result = alertService.getHandleList(10L);
        assertThat(result).isSameAs(expected);
        verify(alertMapper).getHandlesByAlertId(10L);
    }
}