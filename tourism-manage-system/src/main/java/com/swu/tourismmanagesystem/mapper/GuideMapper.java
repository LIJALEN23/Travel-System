package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.guide.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface GuideMapper {

    // ==========================================
    // 导游基础信息 Guide
    // ==========================================
    int insertGuide(Guide guide);

    int updateGuide(Guide guide);

    int deleteGuide(Long id);

    Guide getGuideById(Long id);

    List<Guide> listGuides();

    // 按姓名/电话/身份证 模糊查询
    List<Guide> listGuidesByLike(@Param("name") String name,
                                 @Param("phone") String phone,
                                 @Param("idCard") String idCard);

    // ==========================================
    // 导游资格审核 GuideQualification
    // ==========================================
    int insertQualification(GuideQualification qualification);

    int updateQualification(GuideQualification qualification);

    GuideQualification getQualificationByGuideId(Long guideId);

    // ==========================================
    // 导游实时状态 GuideRealTime
    // ==========================================
    int insertRealTime(GuideRealTime guideRealTime);

    int updateRealTime(GuideRealTime guideRealTime);

    GuideRealTime getRealTimeByGuideId(Long guideId);

    // ==========================================
    // 导游求职申请 GuideJobApply
    // ==========================================
    int insertJobApply(GuideJobApply guideJobApply);

    int updateJobApply(GuideJobApply guideJobApply);

    List<GuideJobApply> listJobAppliesByAgencyId(Long agencyId);

    // ==========================================
    // 导游行程单申领 GuideOrderApply
    // ==========================================
    int insertOrderApply(GuideOrderApply guideOrderApply);

    GuideOrderApply getOrderApplyById(Long id);

    int updateOrderApply(GuideOrderApply guideOrderApply);

    List<GuideOrderApply> listOrderAppliesByAgencyId(Long agencyId);

    // ==========================================
    // 导游诚信档案 GuideCredit
    // ==========================================
    // 根据导游ID查询诚信档案
    GuideCredit getGuideCreditByGuideId(Long guideId);

    // 新增诚信档案（第一次投诉时创建）
    int insertGuideCredit(GuideCredit guideCredit);

    // 更新诚信分数、投诉统计
    int updateGuideCredit(GuideCredit guideCredit);
}