package com.swu.tourismmanagesystem.unit.service;

import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import com.swu.tourismmanagesystem.entity.guide.*;
import com.swu.tourismmanagesystem.mapper.AgencyMapper;
import com.swu.tourismmanagesystem.mapper.ComplaintMapper;
import com.swu.tourismmanagesystem.mapper.GuideMapper;
import com.swu.tourismmanagesystem.service.impl.GuideServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TestGuideService {

    @Mock
    private GuideMapper guideMapper;
    @Mock
    private ComplaintMapper complaintMapper;
    @Mock
    private AgencyMapper agencyMapper;

    @InjectMocks
    private GuideServiceImpl guideService;

    private Guide testGuide;
    private GuideQualification testQualification;
    private GuideRealTime testRealTime;
    private GuideJobApply testJobApply;
    private GuideOrderApply testOrderApply;
    private GuideCredit testCredit;
    private Complaint testComplaint;

    @BeforeEach
    void setUp() {
        testGuide = new Guide();
        testGuide.setId(1L);
        testGuide.setAgencyId(10L);
        testGuide.setName("张导游");
        testGuide.setGender("男");
        testGuide.setAge(30);
        testGuide.setIdCard("123456199001011234");
        testGuide.setPhone("13800138000");
        testGuide.setGuideLevel("高级");
        testGuide.setWorkStatus(0);
        testGuide.setCreateTime(LocalDateTime.now());
        testGuide.setUpdateTime(LocalDateTime.now());

        testQualification = new GuideQualification();
        testQualification.setId(1L);
        testQualification.setGuideId(1L);
        testQualification.setQualificationNo("G20240001");
        testQualification.setIssueDate(LocalDate.of(2024, 1, 1));
        testQualification.setExpireDate(LocalDate.of(2029, 1, 1));
        testQualification.setCheckStatus(1);
        testQualification.setCheckRemark("通过");
        testQualification.setCreateTime(LocalDateTime.now());

        testRealTime = new GuideRealTime();
        testRealTime.setId(1L);
        testRealTime.setGuideId(1L);
        testRealTime.setOrderId(100L);
        testRealTime.setTeamSize(25);
        testRealTime.setWorkStatus("工作中");
        testRealTime.setUpdateTime(LocalDateTime.now());

        testJobApply = new GuideJobApply();
        testJobApply.setId(1L);
        testJobApply.setGuideId(1L);
        testJobApply.setAgencyId(10L);
        testJobApply.setApplyStatus(0);
        testJobApply.setApplyRemark("申请入职");
        testJobApply.setCreateTime(LocalDateTime.now());
        testJobApply.setUpdateTime(LocalDateTime.now());

        testOrderApply = new GuideOrderApply();
        testOrderApply.setId(1L);
        testOrderApply.setGuideId(1L);
        testOrderApply.setAgencyId(10L);
        testOrderApply.setOrderId(200L);
        testOrderApply.setApplyStatus(0);
        testOrderApply.setApplyReason("希望带团");
        testOrderApply.setCreateTime(LocalDateTime.now());
        testOrderApply.setUpdateTime(LocalDateTime.now());

        testCredit = new GuideCredit();
        testCredit.setId(1L);
        testCredit.setGuideId(1L);
        testCredit.setCreditScore(95);
        testCredit.setTotalComplaint(2);
        testCredit.setBadComplaint(1);
        testCredit.setCreditLevel("良好");
        testCredit.setUpdateTime(LocalDateTime.now());

        testComplaint = new Complaint();
        testComplaint.setId(1L);
        testComplaint.setGuideId(1L);
        testComplaint.setStatus("已处理");
        testComplaint.setContent("服务态度差");
    }

    // ==================== 导游 CRUD ====================
    @Test
    void addGuide_ShouldReturnInsertResult() {
        when(guideMapper.insertGuide(testGuide)).thenReturn(1);
        int result = guideService.addGuide(testGuide);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).insertGuide(testGuide);
    }

    @Test
    void updateGuide_ShouldReturnUpdateResult() {
        when(guideMapper.updateGuide(testGuide)).thenReturn(1);
        int result = guideService.updateGuide(testGuide);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).updateGuide(testGuide);
    }

    @Test
    void deleteGuide_ShouldReturnDeleteResult() {
        when(guideMapper.deleteGuide(1L)).thenReturn(1);
        int result = guideService.deleteGuide(1L);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).deleteGuide(1L);
    }

    @Test
    void getGuideById_ShouldReturnGuide() {
        when(guideMapper.getGuideById(1L)).thenReturn(testGuide);
        Guide result = guideService.getGuideById(1L);
        assertThat(result).isEqualTo(testGuide);
        verify(guideMapper).getGuideById(1L);
    }

    @Test
    void getAllGuides_ShouldReturnList() {
        List<Guide> expected = Arrays.asList(testGuide, createGuide(2L, "李导游"));
        when(guideMapper.listGuides()).thenReturn(expected);
        List<Guide> result = guideService.getAllGuides();
        assertThat(result).isSameAs(expected);
        verify(guideMapper).listGuides();
    }

    @Test
    void getGuideListByLike_ShouldReturnFilteredList() {
        List<Guide> expected = Collections.singletonList(testGuide);
        when(guideMapper.listGuidesByLike("张", "138", null)).thenReturn(expected);
        List<Guide> result = guideService.getGuideListByLike("张", "138", null);
        assertThat(result).isSameAs(expected);
        verify(guideMapper).listGuidesByLike("张", "138", null);
    }

    // ==================== 导游资质 ====================
    @Test
    void addQualification_ShouldReturnInsertResult() {
        when(guideMapper.insertQualification(testQualification)).thenReturn(1);
        int result = guideService.addQualification(testQualification);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).insertQualification(testQualification);
    }

    @Test
    void updateQualification_ShouldReturnUpdateResult() {
        when(guideMapper.updateQualification(testQualification)).thenReturn(1);
        int result = guideService.updateQualification(testQualification);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).updateQualification(testQualification);
    }

    @Test
    void getQualificationByGuideId_ShouldReturnQualification() {
        when(guideMapper.getQualificationByGuideId(1L)).thenReturn(testQualification);
        GuideQualification result = guideService.getQualificationByGuideId(1L);
        assertThat(result).isEqualTo(testQualification);
        verify(guideMapper).getQualificationByGuideId(1L);
    }

    // ==================== 导游实时信息 ====================
    @Test
    void addRealTime_ShouldReturnInsertResult() {
        when(guideMapper.insertRealTime(testRealTime)).thenReturn(1);
        int result = guideService.addRealTime(testRealTime);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).insertRealTime(testRealTime);
    }

    @Test
    void updateRealTime_ShouldReturnUpdateResult() {
        when(guideMapper.updateRealTime(testRealTime)).thenReturn(1);
        int result = guideService.updateRealTime(testRealTime);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).updateRealTime(testRealTime);
    }

    @Test
    void getRealTimeByGuideId_ShouldReturnRealTime() {
        when(guideMapper.getRealTimeByGuideId(1L)).thenReturn(testRealTime);
        GuideRealTime result = guideService.getRealTimeByGuideId(1L);
        assertThat(result).isEqualTo(testRealTime);
        verify(guideMapper).getRealTimeByGuideId(1L);
    }

    // ==================== 工作申请 ====================
    @Test
    void addJobApply_ShouldReturnInsertResult() {
        when(guideMapper.insertJobApply(testJobApply)).thenReturn(1);
        int result = guideService.addJobApply(testJobApply);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).insertJobApply(testJobApply);
    }

    @Test
    void updateJobApply_ShouldReturnUpdateResult() {
        when(guideMapper.updateJobApply(testJobApply)).thenReturn(1);
        int result = guideService.updateJobApply(testJobApply);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).updateJobApply(testJobApply);
    }

    @Test
    void getJobAppliesByAgencyId_ShouldReturnList() {
        List<GuideJobApply> expected = Collections.singletonList(testJobApply);
        when(guideMapper.listJobAppliesByAgencyId(10L)).thenReturn(expected);
        List<GuideJobApply> result = guideService.getJobAppliesByAgencyId(10L);
        assertThat(result).isSameAs(expected);
        verify(guideMapper).listJobAppliesByAgencyId(10L);
    }

    // ==================== 带团申请 ====================
    @Test
    void addOrderApply_ShouldSetDefaultStatusAndInsert() {
        GuideOrderApply apply = new GuideOrderApply();
        apply.setGuideId(1L);
        apply.setAgencyId(10L);
        apply.setOrderId(200L);
        // 未设置 applyStatus
        when(guideMapper.insertOrderApply(apply)).thenReturn(1);

        int result = guideService.addOrderApply(apply);
        assertThat(result).isEqualTo(1);
        assertThat(apply.getApplyStatus()).isEqualTo(0); // 默认 0-待审核
        verify(guideMapper).insertOrderApply(apply);
    }

    @Test
    void addOrderApply_ShouldKeepExistingStatus() {
        GuideOrderApply apply = new GuideOrderApply();
        apply.setApplyStatus(2); // 已拒绝
        when(guideMapper.insertOrderApply(apply)).thenReturn(1);

        int result = guideService.addOrderApply(apply);
        assertThat(result).isEqualTo(1);
        assertThat(apply.getApplyStatus()).isEqualTo(2); // 未被覆盖
        verify(guideMapper).insertOrderApply(apply);
    }

    @Test
    void updateOrderApply_ShouldReturnZero_WhenUpdateFails() {
        when(guideMapper.updateOrderApply(testOrderApply)).thenReturn(0);
        int result = guideService.updateOrderApply(testOrderApply);
        assertThat(result).isEqualTo(0);
        verify(guideMapper).updateOrderApply(testOrderApply);
        verify(guideMapper, never()).getOrderApplyById(any());
        verify(guideMapper, never()).updateGuide(any());
        verify(agencyMapper, never()).updateOrderGuideAndStatus(any(), any(), any());
    }

    @Test
    void updateOrderApply_WhenStatusNotPassed_ShouldNotUpdateGuideOrAgency() {
        testOrderApply.setApplyStatus(2); // 拒绝
        when(guideMapper.updateOrderApply(testOrderApply)).thenReturn(1);
        // 注意：rows>0 但 status!=1，不会执行后续逻辑

        int result = guideService.updateOrderApply(testOrderApply);
        assertThat(result).isEqualTo(1);
        verify(guideMapper).updateOrderApply(testOrderApply);
        verify(guideMapper, never()).getOrderApplyById(any());
        verify(guideMapper, never()).updateGuide(any());
        verify(agencyMapper, never()).updateOrderGuideAndStatus(any(), any(), any());
    }

    @Test
    void updateOrderApply_WhenStatusPassed_ShouldUpdateGuideWorkStatusAndAgency() {
        // 准备数据
        testOrderApply.setId(1L);
        testOrderApply.setApplyStatus(1); // 通过
        testOrderApply.setGuideId(1L);
        testOrderApply.setOrderId(200L);

        GuideOrderApply applyInfo = new GuideOrderApply();
        applyInfo.setId(1L);
        applyInfo.setGuideId(1L);
        applyInfo.setOrderId(200L);
        applyInfo.setApplyStatus(1);

        when(guideMapper.updateOrderApply(testOrderApply)).thenReturn(1);
        when(guideMapper.getOrderApplyById(1L)).thenReturn(applyInfo);
        when(guideMapper.getGuideById(1L)).thenReturn(testGuide);
        when(guideMapper.updateGuide(testGuide)).thenReturn(1);
        when(agencyMapper.updateOrderGuideAndStatus(200L, 1L, "已分配")).thenReturn(1);

        int result = guideService.updateOrderApply(testOrderApply);
        assertThat(result).isEqualTo(1);

        verify(guideMapper).updateOrderApply(testOrderApply);
        verify(guideMapper).getOrderApplyById(1L);
        verify(guideMapper).getGuideById(1L);
        // 验证导游工作状态被设置为 1（在岗）
        assertThat(testGuide.getWorkStatus()).isEqualTo(1);
        verify(guideMapper).updateGuide(testGuide);
        verify(agencyMapper).updateOrderGuideAndStatus(200L, 1L, "已分配");
    }

    @Test
    void getOrderAppliesByAgencyId_ShouldReturnList() {
        List<GuideOrderApply> expected = Collections.singletonList(testOrderApply);
        when(guideMapper.listOrderAppliesByAgencyId(10L)).thenReturn(expected);
        List<GuideOrderApply> result = guideService.getOrderAppliesByAgencyId(10L);
        assertThat(result).isSameAs(expected);
        verify(guideMapper).listOrderAppliesByAgencyId(10L);
    }

    @Test
    void getOrderApplyById_ShouldReturnApply() {
        when(guideMapper.getOrderApplyById(1L)).thenReturn(testOrderApply);
        GuideOrderApply result = guideService.getOrderApplyById(1L);
        assertThat(result).isEqualTo(testOrderApply);
        verify(guideMapper).getOrderApplyById(1L);
    }

    // ==================== 导游信用分 ====================
    @Test
    void getGuideCreditByGuideId_WhenExists_ShouldReturnCredit() {
        when(guideMapper.getGuideCreditByGuideId(1L)).thenReturn(testCredit);
        GuideCredit result = guideService.getGuideCreditByGuideId(1L);
        assertThat(result).isEqualTo(testCredit);
        verify(guideMapper).getGuideCreditByGuideId(1L);
        verify(guideMapper, never()).insertGuideCredit(any());
    }

    @Test
    void getGuideCreditByGuideId_WhenNotExists_ShouldCreateDefaultAndReturn() {
        when(guideMapper.getGuideCreditByGuideId(2L)).thenReturn(null);
        when(guideMapper.insertGuideCredit(any(GuideCredit.class))).thenReturn(1);
        // 期望 insert 后返回的对象（我们需要捕获并验证默认值）
        GuideCredit expected = new GuideCredit();
        expected.setGuideId(2L);
        expected.setCreditScore(100);
        expected.setTotalComplaint(0);
        expected.setBadComplaint(0);
        expected.setCreditLevel("优秀");
        // 因为 insertGuideCredit 不返回生成的对象，所以实际返回的是我们构造的
        // 但服务方法内部会创建新对象并返回，我们可以验证其字段
        GuideCredit result = guideService.getGuideCreditByGuideId(2L);
        assertThat(result).isNotNull();
        assertThat(result.getGuideId()).isEqualTo(2L);
        assertThat(result.getCreditScore()).isEqualTo(100);
        assertThat(result.getTotalComplaint()).isEqualTo(0);
        assertThat(result.getBadComplaint()).isEqualTo(0);
        assertThat(result.getCreditLevel()).isEqualTo("优秀");
        verify(guideMapper).getGuideCreditByGuideId(2L);
        verify(guideMapper).insertGuideCredit(any(GuideCredit.class));
    }

    // ==================== 导游投诉列表 ====================
    @Test
    void getGuideComplaintList_ShouldCallComplaintMapperWithGuideId() {
        List<Complaint> expected = Collections.singletonList(testComplaint);
        when(complaintMapper.listComplaint("已处理", null, 1L)).thenReturn(expected);
        List<Complaint> result = guideService.getGuideComplaintList(1L, "已处理");
        assertThat(result).isSameAs(expected);
        verify(complaintMapper).listComplaint("已处理", null, 1L);
    }

    @Test
    void getGuideComplaintList_ShouldPassNullStatus() {
        when(complaintMapper.listComplaint(null, null, 1L)).thenReturn(Collections.emptyList());
        List<Complaint> result = guideService.getGuideComplaintList(1L, null);
        assertThat(result).isEmpty();
        verify(complaintMapper).listComplaint(null, null, 1L);
    }

    // ==================== Helper ====================
    private Guide createGuide(Long id, String name) {
        Guide g = new Guide();
        g.setId(id);
        g.setName(name);
        return g;
    }
}