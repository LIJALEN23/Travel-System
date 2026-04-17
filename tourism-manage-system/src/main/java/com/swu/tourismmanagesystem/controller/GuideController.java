package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.guide.*;
import com.swu.tourismmanagesystem.service.GuideService;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.swu.tourismmanagesystem.entity.complaint.Complaint;
@RestController
@RequestMapping("/guide")
public class GuideController {

    @Resource
    private GuideService guideService;

    // ==============================
    // 1. 导游基础信息管理
    // ==============================

    @PostMapping("/add")
    public Map<String, Object> addGuide(@RequestBody Guide guide) {
        Map<String, Object> res = new HashMap<>();
        int rows = guideService.addGuide(guide);
        res.put("code", rows > 0 ? 200 : 500);
        res.put("msg", rows > 0 ? "导游信息登记成功" : "登记失败");
        return res;
    }

    @PostMapping("/update")
    public Map<String, Object> updateGuide(@RequestBody Guide guide) {
        Map<String, Object> res = new HashMap<>();
        int rows = guideService.updateGuide(guide);
        res.put("code", rows > 0 ? 200 : 500);
        res.put("msg", rows > 0 ? "更新成功" : "更新失败");
        return res;
    }

    @GetMapping("/delete/{id}")
    public Map<String, Object> deleteGuide(@PathVariable Long id) {
        Map<String, Object> res = new HashMap<>();
        int rows = guideService.deleteGuide(id);
        res.put("code", rows > 0 ? 200 : 500);
        res.put("msg", rows > 0 ? "删除成功" : "删除失败");
        return res;
    }

    @GetMapping("/info/{id}")
    public Map<String, Object> getGuideInfo(@PathVariable Long id) {
        Map<String, Object> res = new HashMap<>();
        Guide guide = guideService.getGuideById(id);
        if (guide == null) {
            res.put("code", 404);
            res.put("msg", "导游不存在");
            return res;
        }
        // 同步查询诚信档案
        GuideCredit credit = guideService.getGuideCreditByGuideId(id);
        Map<String, Object> data = new HashMap<>();
        data.put("guideInfo", guide);
        data.put("creditInfo", credit);

        res.put("code", 200);
        res.put("msg", "查询成功");
        res.put("data", data);
        return res;
    }

    // ==============================
    // 【核心】导游模糊查询（姓名/电话/身份证）
    // ==============================
    @GetMapping("/list")
    public Map<String, Object> list(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) String phone,
            @RequestParam(required = false) String idCard) {
        Map<String, Object> res = new HashMap<>();
        List<Guide> list = guideService.getGuideListByLike(name, phone, idCard);
        res.put("code", 200);
        res.put("msg", "查询成功");
        res.put("data", list);
        return res;
    }

    // ==============================
    // 2. 导游资格审核
    // ==============================
    @PostMapping("/qualification/submit")
    public Map<String, Object> submitQualification(@RequestBody GuideQualification q) {
        Map<String, Object> res = new HashMap<>();
        guideService.addQualification(q);
        res.put("code", 200);
        res.put("msg", "资格审核已提交");
        return res;
    }

    @PostMapping("/qualification/audit")
    public Map<String, Object> auditQualification(@RequestBody GuideQualification q) {
        Map<String, Object> res = new HashMap<>();
        int rows = guideService.updateQualification(q);
        res.put("code", rows > 0 ? 200 : 500);
        res.put("msg", rows > 0 ? "资格审核完成" : "审核失败");
        return res;
    }

    @GetMapping("/qualification/{guideId}")
    public Map<String, Object> getQualification(@PathVariable Long guideId) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", 200);
        res.put("data", guideService.getQualificationByGuideId(guideId));
        return res;
    }

    // ==============================
    // 3. 求职申请
    // ==============================
    @PostMapping("/job/apply")
    public Map<String, Object> applyJob(@RequestBody GuideJobApply apply) {
        Map<String, Object> res = new HashMap<>();
        guideService.addJobApply(apply);
        res.put("code", 200);
        res.put("msg", "求职申请已提交");
        return res;
    }

    @GetMapping("/job/applyList/{agencyId}")
    public Map<String, Object> jobApplyList(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", 200);
        res.put("data", guideService.getJobAppliesByAgencyId(agencyId));
        return res;
    }

    @PostMapping("/job/audit")
    public Map<String, Object> auditJobApply(@RequestBody GuideJobApply apply) {
        Map<String, Object> res = new HashMap<>();
        guideService.updateJobApply(apply);
        res.put("code", 200);
        res.put("msg", "处理成功");
        return res;
    }

    // ==============================
    // 4. 行程单申领
    // ==============================
    @PostMapping("/order/apply")
    public Map<String, Object> applyOrder(@RequestBody GuideOrderApply apply) {
        Map<String, Object> res = new HashMap<>();
        if (apply.getGuideId() == null || apply.getAgencyId() == null || apply.getOrderId() == null) {
            res.put("code", 400);
            res.put("msg", "申领失败：导游ID/旅行社ID/行程单ID不能为空");
            return res;
        }
        guideService.addOrderApply(apply);
        res.put("code", 200);
        res.put("msg", "申领已提交，等待审核");
        return res;
    }


    @GetMapping("/order/applyList/{agencyId}")
    public Map<String, Object> orderApplyList(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", 200);
        res.put("data", guideService.getOrderAppliesByAgencyId(agencyId));
        return res;
    }

    @PostMapping("/order/audit")
    public Map<String, Object> auditOrderApply(@RequestBody GuideOrderApply apply) {
        Map<String, Object> res = new HashMap<>();
        if (apply.getId() == null || apply.getApplyStatus() == null) {
            res.put("code", 400);
            res.put("msg", "审核失败：申领ID和状态不能为空");
            return res;
        }
        int updateRows = guideService.updateOrderApply(apply);


        // 如果更新行数=0 → 说明ID不存在，返回错误
        if (updateRows == 0) {
            res.put("code", 404);
            res.put("msg", "审核失败：未找到该申领记录！");
            return res;
        }

        // 成功逻辑
        res.put("code", 200);
        res.put("msg", apply.getApplyStatus() == 1 ? "审核通过，已分配行程单" : "审核驳回");
        return res;
    }

    // ==============================
    // 5. 实时位置上传
    // ==============================
    @PostMapping("/realTime/upload")
    public Map<String, Object> uploadRealTime(@RequestBody GuideRealTime rt) {
        Map<String, Object> res = new HashMap<>();
        GuideRealTime exist = guideService.getRealTimeByGuideId(rt.getGuideId());
        if (exist == null) guideService.addRealTime(rt);
        else guideService.updateRealTime(rt);
        res.put("code", 200);
        res.put("msg", "上传成功");
        return res;
    }

    @GetMapping("/realTime/{guideId}")
    public Map<String, Object> getRealTime(@PathVariable Long guideId) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", 200);
        res.put("data", guideService.getRealTimeByGuideId(guideId));
        return res;
    }

    // ==============================
    // 6. 游客查询（按姓名模糊查）
    // ==============================
    @GetMapping("/public/search")
    public Map<String, Object> publicSearch(
            @RequestParam(required = false) String name) {
        Map<String, Object> res = new HashMap<>();
        List<Guide> list = guideService.getGuideListByLike(name, null, null);
        res.put("code", 200);
        res.put("msg", "查询成功");
        res.put("data", list);
        return res;
    }
    // ==============================
    // 7. 查询导游的信用档案（按姓名模糊查）
    // ==============================
    @GetMapping("/credit/{guideId}")
    public Map<String, Object> getGuideCredit(@PathVariable Long guideId) {
        Map<String, Object> res = new HashMap<>();
        GuideCredit credit = guideService.getGuideCreditByGuideId(guideId);
        res.put("code", 200);
        res.put("msg", "诚信信息查询成功");
        res.put("data", credit);
        return res;
    }

    // ==============================
    // 8. 导游全部投诉记录
    // ==============================
    @GetMapping("/complaint/list/{guideId}")
    public Map<String, Object> getGuideComplaints(
            @PathVariable Long guideId,
            @RequestParam(required = false) String status) {
        Map<String, Object> res = new HashMap<>();
        List<Complaint> complaints = guideService.getGuideComplaintList(guideId, status);
        res.put("code", 200);
        res.put("msg", "投诉记录查询成功");
        res.put("data", complaints);
        return res;
    }

    // ==============================
    // 9. 仅查询导游【差评/不良投诉】
    // ==============================
    @GetMapping("/complaint/bad/{guideId}")
    public Map<String, Object> getBadComplaints(@PathVariable Long guideId) {
        Map<String, Object> res = new HashMap<>();
        // 只查较重、严重等级的投诉 = 差评
        List<Complaint> badComplaints = guideService.getGuideComplaintList(guideId, null);
        badComplaints.removeIf(c -> !("较重".equals(c.getLevel()) || "严重".equals(c.getLevel())));

        res.put("code", 200);
        res.put("msg", "导游差评查询成功");
        res.put("total", badComplaints.size());
        res.put("data", badComplaints);
        return res;
    }
}