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

/**
 * 投诉管理Service实现（最终版：完全适配你的AgencyMapper/GuideMapper）
 */
@Service
public class ComplaintServiceImpl implements ComplaintService {

    @Autowired
    private ComplaintMapper complaintMapper;
    @Autowired
    private AgencyMapper agencyMapper;
    @Autowired
    private GuideMapper guideMapper;

    /**
     * 提交投诉（自动生成投诉单号 + 初始化状态）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitComplaint(Complaint complaint) {
        // 1. 自动生成投诉单号（格式：TS + 日期 + 6位随机数）
        String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomStr = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        complaint.setComplaintNo("TS" + dateStr + randomStr);

        // 2. 初始化投诉状态和时间
        complaint.setStatus(ComplaintConstant.STATUS_PENDING);
        complaint.setCreateTime(LocalDateTime.now());
        complaint.setUpdateTime(LocalDateTime.now());

        // 3. 保存投诉记录（调用你的ComplaintMapper）
        complaintMapper.insertComplaint(complaint);
    }

    /**
     * 处理投诉（核心：更新状态 + 诚信分扣分）
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleComplaint(Long complaintId, String handleUser, String handleResult, String status) {
        // 1. 查询投诉详情（校验存在性）
        Complaint complaint = complaintMapper.getComplaintById(complaintId);
        if (complaint == null) {
            throw new RuntimeException("投诉记录不存在！ID：" + complaintId);
        }
        if (ComplaintConstant.STATUS_DONE.equals(complaint.getStatus()) || ComplaintConstant.STATUS_REJECT.equals(complaint.getStatus())) {
            throw new RuntimeException("该投诉已处理完成/驳回，不可重复操作！");
        }

        // 2. 更新投诉处理信息
        complaint.setHandleUser(handleUser);
        complaint.setHandleResult(handleResult);
        complaint.setHandleTime(LocalDateTime.now());
        complaint.setStatus(status);
        complaint.setUpdateTime(LocalDateTime.now());
        complaintMapper.updateComplaint(complaint);

        // 3. 仅当“已办结”时执行扣分逻辑
        if (ComplaintConstant.STATUS_DONE.equals(status)) {
            int deductScore = getDeductScoreByLevel(complaint.getLevel());
            // 优先处理导游投诉（guideId非空）
            if (complaint.getGuideId() != null) {
                handleGuideComplaint(complaint.getGuideId(), deductScore, complaint.getLevel());
            } else if (complaint.getAgencyId() != null) {
                handleAgencyComplaint(complaint.getAgencyId(), deductScore, complaint.getLevel());
            } else {
                throw new RuntimeException("投诉对象不能为空（旅行社/导游ID至少填一个）！");
            }
        }
    }

    /**
     * 条件查询投诉列表
     */
    @Override
    public List<Complaint> listComplaints(String status, Long agencyId, Long guideId) {
        return complaintMapper.listComplaint(status, agencyId, guideId);
    }

    /**
     * 查询单个投诉详情
     */
    @Override
    public Complaint getComplaintById(Long id) {
        return complaintMapper.getComplaintById(id);
    }

    // ------------------------ 私有核心方法 ------------------------
    /**
     * 根据投诉等级计算扣分（适配level字段：一般/较重/严重）
     */
    private int getDeductScoreByLevel(String level) {
        int deductScore;
        switch (level) {
            case ComplaintConstant.COMPLAINT_LEVEL_NORMAL:
                deductScore = 5;
                break;
            case ComplaintConstant.COMPLAINT_LEVEL_HEAVY:
                deductScore = 10;
                break;
            case ComplaintConstant.COMPLAINT_LEVEL_SERIOUS:
                deductScore = 20;
                break;
            default:
                throw new RuntimeException("无效的投诉等级：" + level);
        }
        return deductScore;
    }

    /**
     * 处理旅行社投诉（调用AgencyMapper）
     */
    private void handleAgencyComplaint(Long agencyId, int deductScore, String complaintLevel) {
        TravelAgency agency = agencyMapper.getTravelAgencyById(agencyId);
        if (agency == null) {
            throw new RuntimeException("旅行社不存在！ID：" + agencyId);
        }

        AgencyCredit agencyCredit = agencyMapper.getAgencyCreditByAgencyId(agencyId);
        if (agencyCredit == null) {
            agencyCredit = new AgencyCredit();
            agencyCredit.setAgencyId(agencyId);
            agencyCredit.setCreditScore(ComplaintConstant.INIT_CREDIT_SCORE);
            agencyCredit.setTotalComplaint(0);
            agencyCredit.setBadComplaint(0);
            agencyMapper.insertAgencyCredit(agencyCredit);
        }

        int newScore = Math.max(agencyCredit.getCreditScore() - deductScore, 0);
        agencyCredit.setCreditScore(newScore);
        agencyCredit.setTotalComplaint(agencyCredit.getTotalComplaint() + 1);
        if (ComplaintConstant.COMPLAINT_LEVEL_HEAVY.equals(complaintLevel)
                || ComplaintConstant.COMPLAINT_LEVEL_SERIOUS.equals(complaintLevel)) {
            agencyCredit.setBadComplaint(agencyCredit.getBadComplaint() + 1);
        }
        agencyCredit.setUpdateTime(LocalDateTime.now());
        agencyMapper.updateAgencyCredit(agencyCredit);


        String newLevel = CreditLevelUtil.getLevelByScore(newScore);
        agency.setCreditLevel(newLevel);
        agency.setUpdateTime(LocalDateTime.now());
        agencyMapper.updateTravelAgency(agency);
    }

    /**
     * 处理导游投诉（调用GuideMapper）
     */
    private void handleGuideComplaint(Long guideId, int deductScore, String complaintLevel) {
        // 1. 查询导游信息（调用GuideMapper.getGuideById）
        Guide guide = guideMapper.getGuideById(guideId);
        if (guide == null) {
            throw new RuntimeException("导游不存在！ID：" + guideId);
        }

        // 2. 查询/初始化导游诚信档案（调用GuideMapper）
        GuideCredit guideCredit = guideMapper.getGuideCreditByGuideId(guideId);
        if (guideCredit == null) {
            guideCredit = new GuideCredit();
            guideCredit.setGuideId(guideId);
            guideCredit.setCreditScore(ComplaintConstant.INIT_CREDIT_SCORE);
            guideCredit.setTotalComplaint(0);
            guideCredit.setBadComplaint(0);
            guideMapper.insertGuideCredit(guideCredit);
        }

        // 3. 更新诚信分（最低扣至0分）
        int newScore = Math.max(guideCredit.getCreditScore() - deductScore, 0);
        guideCredit.setCreditScore(newScore);

        // 4. 更新投诉统计
        guideCredit.setTotalComplaint(guideCredit.getTotalComplaint() + 1);
        if (ComplaintConstant.COMPLAINT_LEVEL_HEAVY.equals(complaintLevel)
                || ComplaintConstant.COMPLAINT_LEVEL_SERIOUS.equals(complaintLevel)) {
            guideCredit.setBadComplaint(guideCredit.getBadComplaint() + 1);
        }
        guideCredit.setUpdateTime(LocalDateTime.now());
        guideMapper.updateGuideCredit(guideCredit);

        // 5. 自动冻结导游（分数<50时更新workStatus=2）
        if (newScore < 50) {
            guide.setWorkStatus(ComplaintConstant.GUIDE_STATUS_FREEZE);
            guide.setUpdateTime(LocalDateTime.now());
            guideMapper.updateGuide(guide);
        }
    }
    @Override
    public void deleteComplaint(Long id) {
        // 1. 校验投诉是否存在
        if (id == null || id <= 0) {
            throw new RuntimeException("投诉ID不能为空且必须为正数");
        }
        Complaint complaint = complaintMapper.getComplaintById(id);
        if (complaint == null) {
            throw new RuntimeException("投诉不存在，无法删除");
        }
        // 2. 执行删除
        int rows = complaintMapper.deleteComplaint(id);
        if (rows <= 0) {
            throw new RuntimeException("投诉删除失败");
        }
    }
}