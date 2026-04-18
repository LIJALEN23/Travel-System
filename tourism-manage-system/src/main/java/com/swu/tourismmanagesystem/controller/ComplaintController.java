package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.utils.Result;
import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import com.swu.tourismmanagesystem.service.ComplaintService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/complaint")
public class ComplaintController {

    @Autowired
    private ComplaintService complaintService;

    // ================================
    // 1. 提交投诉
    // ================================
    @PostMapping("/submit")
    public Result submitComplaint(@RequestBody Complaint complaint) {
        try {
            complaintService.submitComplaint(complaint);
            return Result.success("投诉提交成功", null);
        } catch (Exception e) {
            return Result.error("提交失败：" + e.getMessage());
        }
    }

    // ================================
    // 2. 处理投诉（办结/驳回）
    // ================================
    @PostMapping("/handle")
    public Result handleComplaint(
            @RequestParam Long complaintId,
            @RequestParam String handleUser,
            @RequestParam String handleResult,
            @RequestParam String status) {

        try {
            complaintService.handleComplaint(complaintId, handleUser, handleResult, status);
            return Result.success("投诉处理成功", null);
        } catch (Exception e) {
            return Result.error("处理失败：" + e.getMessage());
        }
    }

    // ================================
    // 3. 删除投诉
    // ================================
    @DeleteMapping("/{id}")
    public Result deleteComplaint(@PathVariable Long id) {
        try {
            complaintService.deleteComplaint(id);
            return Result.success("删除成功", null);
        } catch (Exception e) {
            return Result.error("删除失败：" + e.getMessage());
        }
    }

    // ================================
    // 4. 投诉列表（多条件）
    // ================================
    @GetMapping("/list")
    public Result listComplaints(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long agencyId,
            @RequestParam(required = false) Long guideId) {

        return Result.success("查询成功", complaintService.listComplaints(status, agencyId, guideId));
    }

    // ================================
    // 5. 查询单个投诉
    // ================================
    @GetMapping("/{id}")
    public Result getComplaint(@PathVariable Long id) {
        Complaint complaint = complaintService.getComplaintById(id);
        if (complaint == null) {
            return Result.error("投诉不存在");
        }
        return Result.success("查询成功", complaint);
    }

    // ================================
    // 6. 查询导游诚信信息
    // ================================
    @GetMapping("/guide/credit/{guideId}")
    public Result getGuideCredit(@PathVariable Long guideId) {
        try {
            return Result.success("查询成功", complaintService.getGuideCredit(guideId));
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    // ================================
    // 7. 查询旅行社诚信信息
    // ================================
    @GetMapping("/agency/credit/{agencyId}")
    public Result getAgencyCredit(@PathVariable Long agencyId) {
        try {
            return Result.success("查询成功", complaintService.getAgencyCredit(agencyId));
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }
}