package com.swu.tourismmanagesystem.service;

import com.swu.tourismmanagesystem.entity.guide.*;
import java.util.List;

public interface GuideService {

    // ====================== 导游基础信息 ======================
    int addGuide(Guide guide);
    int updateGuide(Guide guide);
    int deleteGuide(Long id);
    Guide getGuideById(Long id);
    List<Guide> getAllGuides();
    // 模糊查询
    List<Guide> getGuideListByLike(String name, String phone, String idCard);

    // ====================== 导游资格审核 ======================
    int addQualification(GuideQualification q);
    int updateQualification(GuideQualification q);
    GuideQualification getQualificationByGuideId(Long guideId);

    // ====================== 导游实时状态 ======================
    int addRealTime(GuideRealTime rt);
    int updateRealTime(GuideRealTime rt);
    GuideRealTime getRealTimeByGuideId(Long guideId);

    // ====================== 导游求职申请 ======================
    int addJobApply(GuideJobApply apply);
    int updateJobApply(GuideJobApply apply);
    List<GuideJobApply> getJobAppliesByAgencyId(Long agencyId);

    // ====================== 导游行程单申领 ======================
    int addOrderApply(GuideOrderApply apply);
    int updateOrderApply(GuideOrderApply apply);
    List<GuideOrderApply> getOrderAppliesByAgencyId(Long agencyId);
}