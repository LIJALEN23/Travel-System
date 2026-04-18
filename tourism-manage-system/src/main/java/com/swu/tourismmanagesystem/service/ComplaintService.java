package com.swu.tourismmanagesystem.service;

import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import java.util.List;
import com.swu.tourismmanagesystem.entity.agency.AgencyCredit;
import com.swu.tourismmanagesystem.entity.guide.GuideCredit;
/**
 * 投诉管理Service（完全适配你的Complaint实体）
 */
public interface ComplaintService {

    /**
     * 提交投诉（自动生成投诉单号 + 初始化状态）
     */
    void submitComplaint(Complaint complaint);

    /**
     * 处理投诉（核心：更新处理状态 + 诚信分扣分逻辑）
     */
    void handleComplaint(Long complaintId, String handleUser, String handleResult, String status);

    /**
     * 条件查询投诉列表
     */
    List<Complaint> listComplaints(String status, Long agencyId, Long guideId);

    /**
     * 查询单个投诉详情
     */
    Complaint getComplaintById(Long id);
    void deleteComplaint(Long id);
    GuideCredit getGuideCredit(Long guideId);
    AgencyCredit getAgencyCredit(Long agencyId);
}