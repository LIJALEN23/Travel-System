package com.swu.tourismmanagesystem.mapper;
import org.apache.ibatis.annotations.Mapper;
import com.swu.tourismmanagesystem.entity.guide.*;
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

    // ==========================================
    // 导游资格审核 GuideQualification
    // ==========================================
    int insertQualification(GuideQualification q);
    int updateQualification(GuideQualification q);
    GuideQualification getQualificationByGuideId(Long guideId);

    // ==========================================
    // 导游实时状态 GuideRealTime
    // ==========================================
    int insertRealTime(GuideRealTime rt);
    int updateRealTime(GuideRealTime rt);
    GuideRealTime getRealTimeByGuideId(Long guideId);

    // ==========================================
    // 导游求职申请 GuideJobApply
    // ==========================================
    int insertJobApply(GuideJobApply apply);
    int updateJobApply(GuideJobApply apply);
    List<GuideJobApply> listJobAppliesByAgencyId(Long agencyId);

    // ==========================================
    // 导游行程单申领 GuideOrderApply
    // ==========================================
    int insertOrderApply(GuideOrderApply apply);
    int updateOrderApply(GuideOrderApply apply);
    List<GuideOrderApply> listOrderAppliesByAgencyId(Long agencyId);
}