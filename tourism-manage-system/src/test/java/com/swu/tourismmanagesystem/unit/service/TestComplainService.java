package com.swu.tourismmanagesystem.unit.service;

import com.swu.tourismmanagesystem.constant.ComplaintConstant;
import com.swu.tourismmanagesystem.entity.agency.AgencyCredit;
import com.swu.tourismmanagesystem.entity.agency.TravelAgency;
import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import com.swu.tourismmanagesystem.entity.guide.Guide;
import com.swu.tourismmanagesystem.entity.guide.GuideCredit;
import com.swu.tourismmanagesystem.mapper.AgencyMapper;
import com.swu.tourismmanagesystem.mapper.ComplaintMapper;
import com.swu.tourismmanagesystem.mapper.GuideMapper;
import com.swu.tourismmanagesystem.service.impl.ComplaintServiceImpl;
import com.swu.tourismmanagesystem.utils.CreditLevelUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TestComplainService {

    @Mock
    private ComplaintMapper complaintMapper;
    @Mock
    private AgencyMapper agencyMapper;
    @Mock
    private GuideMapper guideMapper;

    @InjectMocks
    private ComplaintServiceImpl complaintService;

    private Complaint testComplaint;
    private Guide testGuide;
    private TravelAgency testAgency;
    private GuideCredit testGuideCredit;
    private AgencyCredit testAgencyCredit;

    @BeforeEach
    void setUp() {
        testComplaint = new Complaint();
        testComplaint.setId(1L);
        testComplaint.setComplaintNo("TS20250101ABC123");
        testComplaint.setVisitorName("张三");
        testComplaint.setVisitorPhone("13800138000");
        testComplaint.setTitle("服务差");
        testComplaint.setContent("导游态度恶劣");
        testComplaint.setAgencyId(10L);
        testComplaint.setGuideId(1L);
        testComplaint.setLevel(ComplaintConstant.COMPLAINT_LEVEL_NORMAL);
        testComplaint.setStatus(ComplaintConstant.STATUS_PENDING);
        testComplaint.setCreateTime(LocalDateTime.now());
        testComplaint.setUpdateTime(LocalDateTime.now());

        testGuide = new Guide();
        testGuide.setId(1L);
        testGuide.setName("张导游");
        testGuide.setWorkStatus(1); // 在岗
        testGuide.setAgencyId(10L);

        testAgency = new TravelAgency();
        testAgency.setId(10L);
        testAgency.setAgencyName("测试旅行社");
        testAgency.setCreditLevel("优秀");
        testAgency.setStatus(1);

        testGuideCredit = new GuideCredit();
        testGuideCredit.setId(1L);
        testGuideCredit.setGuideId(1L);
        testGuideCredit.setCreditScore(85);
        testGuideCredit.setTotalComplaint(2);
        testGuideCredit.setBadComplaint(1);

        testAgencyCredit = new AgencyCredit();
        testAgencyCredit.setId(1L);
        testAgencyCredit.setAgencyId(10L);
        testAgencyCredit.setCreditScore(90);
        testAgencyCredit.setTotalComplaint(3);
        testAgencyCredit.setBadComplaint(1);
    }

    // ==================== submitComplaint ====================
    @Test
    void submitComplaint_ShouldThrowException_WhenRequiredFieldsMissing() {
        Complaint invalid = new Complaint();
        invalid.setVisitorName("李四");
        // missing visitorPhone and content
        assertThatThrownBy(() -> complaintService.submitComplaint(invalid))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("投诉信息不完整");
        verify(complaintMapper, never()).insertComplaint(any());
    }

    @Test
    void submitComplaint_ShouldSetFieldsAndInsert() {
        Complaint newComplaint = new Complaint();
        newComplaint.setVisitorName("王五");
        newComplaint.setVisitorPhone("13900139000");
        newComplaint.setContent("投诉内容");
        newComplaint.setAgencyId(20L);

        when(complaintMapper.insertComplaint(any(Complaint.class))).thenReturn(1);

        complaintService.submitComplaint(newComplaint);

        assertThat(newComplaint.getComplaintNo()).startsWith("TS");
        assertThat(newComplaint.getComplaintNo()).hasSizeGreaterThan(10);
        assertThat(newComplaint.getStatus()).isEqualTo(ComplaintConstant.STATUS_PENDING);
        assertThat(newComplaint.getCreateTime()).isNotNull();
        assertThat(newComplaint.getUpdateTime()).isNotNull();

        verify(complaintMapper).insertComplaint(newComplaint);
    }

    // ==================== handleComplaint ====================
    @Test
    void handleComplaint_ShouldThrowException_WhenComplaintNotFound() {
        when(complaintMapper.getComplaintById(99L)).thenReturn(null);
        assertThatThrownBy(() -> complaintService.handleComplaint(99L, "admin", "已核实", ComplaintConstant.STATUS_DONE))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("投诉不存在");
    }

    @Test
    void handleComplaint_ShouldThrowException_WhenComplaintAlreadyDoneOrRejected() {
        testComplaint.setStatus(ComplaintConstant.STATUS_DONE);
        when(complaintMapper.getComplaintById(1L)).thenReturn(testComplaint);
        assertThatThrownBy(() -> complaintService.handleComplaint(1L, "admin", "已处理", ComplaintConstant.STATUS_REJECT))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("投诉已办结或已驳回，无法重复处理");
    }

    @Test
    void handleComplaint_WhenStatusReject_ShouldAppendRejectMessage() {
        testComplaint.setStatus(ComplaintConstant.STATUS_PENDING);
        when(complaintMapper.getComplaintById(1L)).thenReturn(testComplaint);
        when(complaintMapper.updateComplaint(any(Complaint.class))).thenReturn(1);

        complaintService.handleComplaint(1L, "admin", "证据不足", ComplaintConstant.STATUS_REJECT);

        verify(complaintMapper).updateComplaint(argThat(c ->
                c.getHandleResult().contains("证据不足") &&
                        c.getHandleResult().contains("已被驳回") &&
                        c.getStatus().equals(ComplaintConstant.STATUS_REJECT)
        ));
        // 驳回不触发信用分重算
        verify(guideMapper, never()).getGuideCreditByGuideId(any());
        verify(agencyMapper, never()).getAgencyCreditByAgencyId(any());
    }

    @Test
    void handleComplaint_WhenStatusDone_ShouldRecalculateGuideAndAgencyCredit() {
        testComplaint.setStatus(ComplaintConstant.STATUS_PENDING);
        when(complaintMapper.getComplaintById(1L)).thenReturn(testComplaint);
        when(complaintMapper.updateComplaint(any(Complaint.class))).thenReturn(1);

        // 准备信用分重算需要的 mock 数据
        List<Complaint> doneComplaints = Arrays.asList(testComplaint);
        when(complaintMapper.listComplaint(ComplaintConstant.STATUS_DONE, null, 1L)).thenReturn(doneComplaints);
        when(complaintMapper.listComplaint(ComplaintConstant.STATUS_DONE, 10L, null)).thenReturn(doneComplaints);
        when(complaintMapper.countGuideValidComplaints(1L)).thenReturn(3);
        when(complaintMapper.countGuideBadComplaints(1L)).thenReturn(1);
        when(complaintMapper.countAgencyValidComplaints(10L)).thenReturn(5);
        when(complaintMapper.countAgencyBadComplaints(10L)).thenReturn(2);

        when(guideMapper.getGuideCreditByGuideId(1L)).thenReturn(testGuideCredit);
        when(guideMapper.getGuideById(1L)).thenReturn(testGuide);
        when(guideMapper.updateGuideCredit(any(GuideCredit.class))).thenReturn(1);
        when(guideMapper.updateGuide(any(Guide.class))).thenReturn(1);

        when(agencyMapper.getAgencyCreditByAgencyId(10L)).thenReturn(testAgencyCredit);
        when(agencyMapper.getTravelAgencyById(10L)).thenReturn(testAgency);
        when(agencyMapper.updateAgencyCredit(any(AgencyCredit.class))).thenReturn(1);
        when(agencyMapper.updateTravelAgency(any(TravelAgency.class))).thenReturn(1);

        try (MockedStatic<CreditLevelUtil> creditLevelMock = mockStatic(CreditLevelUtil.class)) {
            creditLevelMock.when(() -> CreditLevelUtil.getLevelByScore(anyInt())).thenReturn("良好");

            complaintService.handleComplaint(1L, "admin", "已核实处理", ComplaintConstant.STATUS_DONE);

            verify(complaintMapper).updateComplaint(argThat(c ->
                    c.getStatus().equals(ComplaintConstant.STATUS_DONE) &&
                            c.getHandleUser().equals("admin")
            ));
            // 验证信用分重算被调用（通过私有方法，我们只能验证 mapper 调用）
            verify(guideMapper).getGuideCreditByGuideId(1L);
            verify(guideMapper).updateGuideCredit(any(GuideCredit.class));
            verify(guideMapper).updateGuide(testGuide);
            verify(agencyMapper).getAgencyCreditByAgencyId(10L);
            verify(agencyMapper).updateAgencyCredit(any(AgencyCredit.class));
            verify(agencyMapper).updateTravelAgency(testAgency);
        }
    }

    // ==================== deleteComplaint ====================
    @Test
    void deleteComplaint_ShouldThrowException_WhenNotFound() {
        when(complaintMapper.getComplaintById(99L)).thenReturn(null);
        assertThatThrownBy(() -> complaintService.deleteComplaint(99L))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("投诉不存在");
    }

    @Test
    void deleteComplaint_ShouldDeleteAndRecalcCredits() {
        when(complaintMapper.getComplaintById(1L)).thenReturn(testComplaint);
        when(complaintMapper.deleteComplaint(1L)).thenReturn(1);

        // 模拟信用分重算
        List<Complaint> doneList = Collections.singletonList(testComplaint);
        when(complaintMapper.listComplaint(ComplaintConstant.STATUS_DONE, null, 1L)).thenReturn(doneList);
        when(complaintMapper.listComplaint(ComplaintConstant.STATUS_DONE, 10L, null)).thenReturn(doneList);
        when(complaintMapper.countGuideValidComplaints(1L)).thenReturn(2);
        when(complaintMapper.countGuideBadComplaints(1L)).thenReturn(0);
        when(complaintMapper.countAgencyValidComplaints(10L)).thenReturn(4);
        when(complaintMapper.countAgencyBadComplaints(10L)).thenReturn(1);

        when(guideMapper.getGuideCreditByGuideId(1L)).thenReturn(testGuideCredit);
        when(guideMapper.getGuideById(1L)).thenReturn(testGuide);
        when(agencyMapper.getAgencyCreditByAgencyId(10L)).thenReturn(testAgencyCredit);
        when(agencyMapper.getTravelAgencyById(10L)).thenReturn(testAgency);

        try (MockedStatic<CreditLevelUtil> creditLevelMock = mockStatic(CreditLevelUtil.class)) {
            creditLevelMock.when(() -> CreditLevelUtil.getLevelByScore(anyInt())).thenReturn("良好");

            complaintService.deleteComplaint(1L);

            verify(complaintMapper).deleteComplaint(1L);
            verify(guideMapper).updateGuideCredit(any(GuideCredit.class));
            verify(agencyMapper).updateAgencyCredit(any(AgencyCredit.class));
        }
    }

    // ==================== listComplaints ====================
    @Test
    void listComplaints_ShouldReturnMapperResult() {
        List<Complaint> expected = Collections.singletonList(testComplaint);
        when(complaintMapper.listComplaint(ComplaintConstant.STATUS_PENDING, 10L, 1L)).thenReturn(expected);
        List<Complaint> result = complaintService.listComplaints(ComplaintConstant.STATUS_PENDING, 10L, 1L);
        assertThat(result).isSameAs(expected);
        verify(complaintMapper).listComplaint(ComplaintConstant.STATUS_PENDING, 10L, 1L);
    }

    // ==================== getComplaintById ====================
    @Test
    void getComplaintById_ShouldReturnComplaint() {
        when(complaintMapper.getComplaintById(1L)).thenReturn(testComplaint);
        Complaint result = complaintService.getComplaintById(1L);
        assertThat(result).isEqualTo(testComplaint);
        verify(complaintMapper).getComplaintById(1L);
    }

    // ==================== getGuideCredit ====================
    @Test
    void getGuideCredit_WhenExists_ShouldReturnCredit() {
        when(guideMapper.getGuideCreditByGuideId(1L)).thenReturn(testGuideCredit);
        GuideCredit result = complaintService.getGuideCredit(1L);
        assertThat(result).isEqualTo(testGuideCredit);
    }

    @Test
    void getGuideCredit_WhenNotExists_ShouldReturnDefault() {
        when(guideMapper.getGuideCreditByGuideId(2L)).thenReturn(null);
        GuideCredit result = complaintService.getGuideCredit(2L);
        assertThat(result.getGuideId()).isEqualTo(2L);
        assertThat(result.getCreditScore()).isEqualTo(100);
        assertThat(result.getTotalComplaint()).isEqualTo(0);
        assertThat(result.getBadComplaint()).isEqualTo(0);
    }

    // ==================== getAgencyCredit ====================
    @Test
    void getAgencyCredit_WhenExists_ShouldReturnCredit() {
        when(agencyMapper.getAgencyCreditByAgencyId(10L)).thenReturn(testAgencyCredit);
        AgencyCredit result = complaintService.getAgencyCredit(10L);
        assertThat(result).isEqualTo(testAgencyCredit);
    }

    @Test
    void getAgencyCredit_WhenNotExists_ShouldReturnDefault() {
        when(agencyMapper.getAgencyCreditByAgencyId(20L)).thenReturn(null);
        AgencyCredit result = complaintService.getAgencyCredit(20L);
        assertThat(result.getAgencyId()).isEqualTo(20L);
        assertThat(result.getCreditScore()).isEqualTo(100);
        assertThat(result.getTotalComplaint()).isEqualTo(0);
        assertThat(result.getBadComplaint()).isEqualTo(0);
    }

    // ==================== 私有方法 getDeductScoreByLevel 的间接测试 ====================
    // 通过 handleComplaint 中信用分计算来验证扣分逻辑
    @Test
    void handleComplaint_ShouldCalculateCreditScoreWithDeductions() {
        testComplaint.setStatus(ComplaintConstant.STATUS_PENDING);
        // 假设该投诉级别为严重
        testComplaint.setLevel(ComplaintConstant.COMPLAINT_LEVEL_SERIOUS);
        when(complaintMapper.getComplaintById(1L)).thenReturn(testComplaint);
        when(complaintMapper.updateComplaint(any())).thenReturn(1);

        // 已经有一个严重投诉（扣20分），另一个普通投诉（扣5分）
        Complaint serious = new Complaint();
        serious.setLevel(ComplaintConstant.COMPLAINT_LEVEL_SERIOUS);
        Complaint normal = new Complaint();
        normal.setLevel(ComplaintConstant.COMPLAINT_LEVEL_NORMAL);
        List<Complaint> doneList = Arrays.asList(serious, normal);
        when(complaintMapper.listComplaint(ComplaintConstant.STATUS_DONE, null, 1L)).thenReturn(doneList);
        when(complaintMapper.countGuideValidComplaints(1L)).thenReturn(2);
        when(complaintMapper.countGuideBadComplaints(1L)).thenReturn(1);
        when(guideMapper.getGuideCreditByGuideId(1L)).thenReturn(testGuideCredit);
        when(guideMapper.getGuideById(1L)).thenReturn(testGuide);
        when(guideMapper.updateGuideCredit(any())).thenReturn(1);
        when(guideMapper.updateGuide(any())).thenReturn(1);

        // 旅行社部分简化
        when(complaintMapper.listComplaint(ComplaintConstant.STATUS_DONE, 10L, null)).thenReturn(Collections.emptyList());
        when(complaintMapper.countAgencyValidComplaints(10L)).thenReturn(0);
        when(complaintMapper.countAgencyBadComplaints(10L)).thenReturn(0);
        when(agencyMapper.getAgencyCreditByAgencyId(10L)).thenReturn(testAgencyCredit);
        when(agencyMapper.getTravelAgencyById(10L)).thenReturn(testAgency);
        when(agencyMapper.updateAgencyCredit(any())).thenReturn(1);
        when(agencyMapper.updateTravelAgency(any())).thenReturn(1);

        try (MockedStatic<CreditLevelUtil> creditLevelMock = mockStatic(CreditLevelUtil.class)) {
            creditLevelMock.when(() -> CreditLevelUtil.getLevelByScore(anyInt())).thenReturn("中等");
            complaintService.handleComplaint(1L, "admin", "处理", ComplaintConstant.STATUS_DONE);
            // 验证最终信用分 = 100 - (20+5) = 75
            verify(guideMapper).updateGuideCredit(argThat(credit -> {
                assertThat(credit.getCreditScore()).isEqualTo(75);
                return true;
            }));
        }
    }
}