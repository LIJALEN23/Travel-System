package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.guide.*;
import com.swu.tourismmanagesystem.mapper.GuideMapper;
import com.swu.tourismmanagesystem.mapper.AgencyMapper;
import com.swu.tourismmanagesystem.service.GuideService;
import org.springframework.stereotype.Service;
import javax.annotation.Resource;
import java.util.List;
import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import com.swu.tourismmanagesystem.mapper.ComplaintMapper;

@Service
public class GuideServiceImpl implements GuideService {

    @Resource
    private GuideMapper guideMapper;
    @Resource
    private ComplaintMapper complaintMapper;
    @Resource
    private AgencyMapper   agencyMapper;

    // ====================== 导游基础信息 ======================
    @Override
    public int addGuide(Guide guide) {
        return guideMapper.insertGuide(guide);
    }

    @Override
    public int updateGuide(Guide guide) {
        return guideMapper.updateGuide(guide);
    }

    @Override
    public int deleteGuide(Long id) {
        return guideMapper.deleteGuide(id);
    }

    @Override
    public Guide getGuideById(Long id) {
        return guideMapper.getGuideById(id);
    }

    @Override
    public List<Guide> getAllGuides() {
        return guideMapper.listGuides();
    }
    @Override
    public List<Guide> getGuideListByLike(String name, String phone, String idCard) {
        return guideMapper.listGuidesByLike(name, phone, idCard);
    }

    // ====================== 导游资格审核 ======================
    @Override
    public int addQualification(GuideQualification q) {
        return guideMapper.insertQualification(q);
    }

    @Override
    public int updateQualification(GuideQualification q) {
        return guideMapper.updateQualification(q);
    }

    @Override
    public GuideQualification getQualificationByGuideId(Long guideId) {
        return guideMapper.getQualificationByGuideId(guideId);
    }

    // ====================== 导游实时状态 ======================
    @Override
    public int addRealTime(GuideRealTime rt) {
        return guideMapper.insertRealTime(rt);
    }

    @Override
    public int updateRealTime(GuideRealTime rt) {
        return guideMapper.updateRealTime(rt);
    }

    @Override
    public GuideRealTime getRealTimeByGuideId(Long guideId) {
        return guideMapper.getRealTimeByGuideId(guideId);
    }

    // ====================== 导游求职申请 ======================
    @Override
    public int addJobApply(GuideJobApply apply) {
        return guideMapper.insertJobApply(apply);
    }

    @Override
    public int updateJobApply(GuideJobApply apply) {
        return guideMapper.updateJobApply(apply);
    }

    @Override
    public List<GuideJobApply> getJobAppliesByAgencyId(Long agencyId) {
        return guideMapper.listJobAppliesByAgencyId(agencyId);
    }

    // ====================== 导游行程单申领 ======================
    @Override
    public int addOrderApply(GuideOrderApply apply) {
        // 默认待审核
        if (apply.getApplyStatus() == null) {
            apply.setApplyStatus(0);
        }
        return guideMapper.insertOrderApply(apply);
    }

    /**
     * 审核申领单（核心业务）
     * 审核通过(1) → 更新导游状态为1(在职) → 更新行程单导游+状态
     */
    @Override
    public int updateOrderApply(GuideOrderApply apply) {
        // 1. 更新申领单状态
        int rows = guideMapper.updateOrderApply(apply);
        // 如果没有更新到任何数据，直接返回 0
        if (rows == 0) {
            return 0;
        }
        // 2. 仅审核通过时执行后续操作
        if (rows > 0 && apply.getApplyStatus() == 1) {
            // 查询申领单完整信息（含orderId/guideId）
            GuideOrderApply applyInfo = guideMapper.getOrderApplyById(apply.getId());

            // ==========================================
            // 【复用原有方法】更新导游执业状态 → 1(在职)
            // ==========================================
            Guide guide = guideMapper.getGuideById(applyInfo.getGuideId());
            guide.setWorkStatus(1); // 执业状态 0-待业 1-在职 2-冻结
            guideMapper.updateGuide(guide);

            // ==========================================
            // 【复用AgencyMapper】更新行程单
            // ==========================================
            agencyMapper.updateOrderGuideAndStatus(
                    applyInfo.getOrderId(),
                    applyInfo.getGuideId(),
                    "待出发"
            );
        }
        return rows;
    }

    @Override
    public List<GuideOrderApply> getOrderAppliesByAgencyId(Long agencyId) {
        return guideMapper.listOrderAppliesByAgencyId(agencyId);
    }
    @Override
    public GuideOrderApply getOrderApplyById(Long id) {
        return guideMapper.getOrderApplyById(id);
    }
    //==================诚信档案和投诉===========
    // 1. 查询导游诚信档案
    @Override
    public GuideCredit getGuideCreditByGuideId(Long guideId) {
        GuideCredit credit = guideMapper.getGuideCreditByGuideId(guideId);
        // 无记录则初始化默认值
        if (credit == null) {
            credit = new GuideCredit();
            credit.setGuideId(guideId);
            credit.setCreditScore(100); // 初始诚信分100
            credit.setTotalComplaint(0); // 初始投诉数0
            credit.setBadComplaint(0); // 初始差评数0
            credit.setCreditLevel("优秀"); // 默认等级
            // 插入默认记录到数据库
            guideMapper.insertGuideCredit(credit);
        }
        return credit;
    }

    // 2. 查询导游投诉记录（适配 ComplaintMapper 的 listComplaint 方法）
    @Override
    public List<Complaint> getGuideComplaintList(Long guideId, String status) {
        // 调用现有 listComplaint 方法，仅传 guideId 和 status，agencyId 传 null
        return complaintMapper.listComplaint(status, null, guideId);
    }
}