package com.swu.tourismmanagesystem.service.impl;

import com.swu.tourismmanagesystem.entity.guide.*;
import com.swu.tourismmanagesystem.mapper.GuideMapper;
import com.swu.tourismmanagesystem.service.GuideService;
import org.springframework.stereotype.Service;
import javax.annotation.Resource;
import java.util.List;

@Service
public class GuideServiceImpl implements GuideService {

    @Resource
    private GuideMapper guideMapper;

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
        return guideMapper.insertOrderApply(apply);
    }

    @Override
    public int updateOrderApply(GuideOrderApply apply) {
        return guideMapper.updateOrderApply(apply);
    }

    @Override
    public List<GuideOrderApply> getOrderAppliesByAgencyId(Long agencyId) {
        return guideMapper.listOrderAppliesByAgencyId(agencyId);
    }
}