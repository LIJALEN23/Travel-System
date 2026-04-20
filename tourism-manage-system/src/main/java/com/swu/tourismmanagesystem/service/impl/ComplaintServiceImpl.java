package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.constant.ComplaintConstant;
import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import com.swu.tourismmanagesystem.entity.agency.AgencyCredit;
import com.swu.tourismmanagesystem.entity.agency.TravelAgency;
import com.swu.tourismmanagesystem.entity.guide.Guide;
import com.swu.tourismmanagesystem.entity.guide.GuideCredit;
import com.swu.tourismmanagesystem.mapper.ComplaintMapper;
import com.swu.tourismmanagesystem.mapper.AgencyMapper;
import com.swu.tourismmanagesystem.mapper.GuideMapper;
import com.swu.tourismmanagesystem.service.ComplaintService;
import com.swu.tourismmanagesystem.utils.CreditLevelUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

@Service
public class ComplaintServiceImpl implements ComplaintService {

    @Autowired
    private ComplaintMapper complaintMapper;

    @Autowired
    private AgencyMapper agencyMapper;

    @Autowired
    private GuideMapper guideMapper;

    // ===================== 提交投诉（只存记录，不计数） =====================
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitComplaint(Complaint complaint) {
        if (complaint.getVisitorName() == null || complaint.getVisitorPhone() == null || complaint.getContent() == null) {
            throw new RuntimeException("必填字段不能为空");
        }

        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomStr = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        complaint.setComplaintNo("TS" + dateStr + randomStr);

        complaint.setStatus(ComplaintConstant.STATUS_PENDING);
        complaint.setCreateTime(LocalDateTime.now());
        complaint.setUpdateTime(LocalDateTime.now());

        complaintMapper.insertComplaint(complaint);
    }

    // ===================== 处理投诉（核心：办结 → 统计 → 更新信用） =====================
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleComplaint(Long complaintId, String handleUser, String handleResult, String status) {
        Complaint complaint = complaintMapper.getComplaintById(complaintId);
        if (complaint == null) {
            throw new RuntimeException("投诉不存在");
        }

        // 已处理不能重复操作
        if (ComplaintConstant.STATUS_DONE.equals(complaint.getStatus()) || ComplaintConstant.STATUS_REJECT.equals(complaint.getStatus())) {
            throw new RuntimeException("已处理，不可操作");
        }

        // 驳回自动加提示
        if (ComplaintConstant.STATUS_REJECT.equals(status)) {
            handleResult += "（经核查驳回，疑问咨询客服）";
        }

        // 更新投诉
        complaint.setHandleUser(handleUser);
        complaint.setHandleResult(handleResult);
        complaint.setHandleTime(LocalDateTime.now());
        complaint.setStatus(status);
        complaint.setUpdateTime(LocalDateTime.now());
        complaintMapper.updateComplaint(complaint);

        // ===================== ✅ 办结 → 重新统计信用（完全靠数据库） =====================
        if (ComplaintConstant.STATUS_DONE.equals(status)) {
            // 统计并更新导游信用
            if (complaint.getGuideId() != null) {
                calculateAndUpdateGuideCredit(complaint.getGuideId());
            }
            // 统计并更新旅行社信用
            if (complaint.getAgencyId() != null) {
                calculateAndUpdateAgencyCredit(complaint.getAgencyId());
            }
        }
    }

    // ===================== ✅ 核心：导游信用 = 全靠数据库统计 =====================
    private void calculateAndUpdateGuideCredit(Long guideId) {
        // 1. 查询该导游【所有已办结投诉】
        List<Complaint> doneList = complaintMapper.listComplaint(
                ComplaintConstant.STATUS_DONE, null, guideId);

        // 2. 计算总扣分
        int totalDeduct = 0;
        for (Complaint c : doneList) {
            totalDeduct += getDeductScoreByLevel(c.getLevel());
        }

        // 3. 最终分数 = 100 - 总扣分（最低0）
        int finalScore = Math.max(100 - totalDeduct, 0);

        // 4. 查投诉总数、不良数（全靠mapper）
        int total = complaintMapper.countGuideValidComplaints(guideId);
        int bad = complaintMapper.countGuideBadComplaints(guideId);

        // 5. 查询或初始化诚信记录
        GuideCredit credit = guideMapper.getGuideCreditByGuideId(guideId);
        if (credit == null) {
            credit = new GuideCredit();
            credit.setGuideId(guideId);
            credit.setCreditScore(finalScore);
            credit.setTotalComplaint(total);
            credit.setBadComplaint(bad);
            guideMapper.insertGuideCredit(credit);
        } else {
            // ✅ 直接覆盖为最新统计结果
            credit.setCreditScore(finalScore);
            credit.setTotalComplaint(total);
            credit.setBadComplaint(bad);
            credit.setUpdateTime(LocalDateTime.now());
            guideMapper.updateGuideCredit(credit);
        }

        // 6. 冻结/解冻（自动）
        Guide guide = guideMapper.getGuideById(guideId);
        if (finalScore < 50) {
            guide.setWorkStatus(2); // 冻结
        } else {
            guide.setWorkStatus(1); // 正常
        }
        guideMapper.updateGuide(guide);
    }

    // ===================== ✅ 核心：旅行社信用 = 全靠数据库统计 =====================
    private void calculateAndUpdateAgencyCredit(Long agencyId) {
        // 1. 查所有已办结投诉
        List<Complaint> doneList = complaintMapper.listComplaint(
                ComplaintConstant.STATUS_DONE, agencyId, null);

        // 2. 算总扣分
        int totalDeduct = 0;
        for (Complaint c : doneList) {
            totalDeduct += getDeductScoreByLevel(c.getLevel());
        }

        // 3. 最终分数
        int finalScore = Math.max(100 - totalDeduct, 0);

        // 4. 查最新数量
        int total = complaintMapper.countAgencyValidComplaints(agencyId);
        int bad = complaintMapper.countAgencyBadComplaints(agencyId);

        // 5. 更新信用
        AgencyCredit credit = agencyMapper.getAgencyCreditByAgencyId(agencyId);
        if (credit == null) {
            credit = new AgencyCredit();
            credit.setAgencyId(agencyId);
            credit.setCreditScore(finalScore);
            credit.setTotalComplaint(total);
            credit.setBadComplaint(bad);
            agencyMapper.insertAgencyCredit(credit);
        } else {
            credit.setCreditScore(finalScore);
            credit.setTotalComplaint(total);
            credit.setBadComplaint(bad);
            credit.setUpdateTime(LocalDateTime.now());
            agencyMapper.updateAgencyCredit(credit);
        }

        // 6. 更新等级
        TravelAgency agency = agencyMapper.getTravelAgencyById(agencyId);
        agency.setCreditLevel(CreditLevelUtil.getLevelByScore(finalScore));
        agencyMapper.updateTravelAgency(agency);
    }

    // ===================== 删除投诉（自动重新统计 → 自动恢复分数） =====================
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteComplaint(Long id) {
        Complaint complaint = complaintMapper.getComplaintById(id);
        if (complaint == null) throw new RuntimeException("投诉不存在");

        // 删除投诉
        complaintMapper.deleteComplaint(id);

        // ✅ 删除后 → 重新统计 → 自动恢复分数
        if (complaint.getGuideId() != null) {
            calculateAndUpdateGuideCredit(complaint.getGuideId());
        }
        if (complaint.getAgencyId() != null) {
            calculateAndUpdateAgencyCredit(complaint.getAgencyId());
        }
    }

    // ===================== 工具方法 =====================
    private int getDeductScoreByLevel(String level) {
        int score;
        switch (level) {
            case ComplaintConstant.COMPLAINT_LEVEL_NORMAL: score = 5; break;
            case ComplaintConstant.COMPLAINT_LEVEL_HEAVY: score = 10; break;
            case ComplaintConstant.COMPLAINT_LEVEL_SERIOUS: score = 20; break;
            default: throw new RuntimeException("等级错误");
        }
        return score;
    }

    @Override
    public List<Complaint> listComplaints(String status, Long agencyId, Long guideId) {
        return complaintMapper.listComplaint(status, agencyId, guideId);
    }

    @Override
    public Complaint getComplaintById(Long id) {
        return complaintMapper.getComplaintById(id);
    }
    // ===================== 新增：查询导游诚信信息 =====================
    @Override
    public GuideCredit getGuideCredit(Long guideId) {
        GuideCredit credit = guideMapper.getGuideCreditByGuideId(guideId);
        if (credit == null) {
            // 没有投诉过就返回默认信用
            credit = new GuideCredit();
            credit.setGuideId(guideId);
            credit.setCreditScore(100);
            credit.setTotalComplaint(0);
            credit.setBadComplaint(0);
        }
        return credit;
    }

    // ===================== 新增：查询旅行社诚信信息 =====================
    @Override
    public AgencyCredit getAgencyCredit(Long agencyId) {
        AgencyCredit credit = agencyMapper.getAgencyCreditByAgencyId(agencyId);
        if (credit == null) {
            credit = new AgencyCredit();
            credit.setAgencyId(agencyId);
            credit.setCreditScore(100);
            credit.setTotalComplaint(0);
            credit.setBadComplaint(0);
        }
        return credit;
    }
}