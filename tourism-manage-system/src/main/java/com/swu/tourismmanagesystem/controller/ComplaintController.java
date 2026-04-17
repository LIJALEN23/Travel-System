package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import com.swu.tourismmanagesystem.service.ComplaintService;
import com.swu.tourismmanagesystem.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 投诉管理控制器
 * 接口前缀：/api/complaint
 * 适配全局跨域配置 + 自定义Result工具类 + 登录拦截器规则
 */
@RestController
@RequestMapping("/complaint")
public class ComplaintController {

    // 注入投诉服务（确保Spring已扫描并注册ComplaintService Bean）
    @Autowired
    private ComplaintService complaintService;

    /**
     * 提交投诉（游客/用户提交投诉，自动生成投诉单号）
     * 请求方式：POST
     * 请求地址：/api/complaint/submit
     * 请求体：Complaint实体JSON（visitorName/visitorPhone/level/content为必填）
     * 返回值：统一响应结果（包含投诉单号）
     */
    @PostMapping("/submit")
    public Result submitComplaint(@RequestBody Complaint complaint) {
        try {
            // 基础参数校验（避免空值提交）
            if (complaint.getVisitorName() == null || complaint.getVisitorName().trim().isEmpty()) {
                return Result.error("游客姓名不能为空");
            }
            if (complaint.getVisitorPhone() == null || complaint.getVisitorPhone().trim().isEmpty()) {
                return Result.error("游客联系电话不能为空");
            }
            if (complaint.getContent() == null || complaint.getContent().trim().isEmpty()) {
                return Result.error("投诉内容不能为空");
            }
            if (complaint.getLevel() == null || complaint.getLevel().trim().isEmpty()) {
                return Result.error("投诉等级不能为空（一般/较重/严重）");
            }

            // 调用Service提交投诉（自动生成单号+初始化状态）
            complaintService.submitComplaint(complaint);

            // 返回成功结果（包含投诉单号）
            return Result.success("投诉提交成功", complaint.getComplaintNo());
        } catch (Exception e) {
            // 捕获异常并返回友好提示
            return Result.error("投诉提交失败：" + e.getMessage());
        }
    }

    /**
     * 处理投诉（管理员操作：更新状态+扣诚信分）
     * 请求方式：PUT
     * 请求地址：/api/complaint/handle/{id}
     * 路径参数：id - 投诉ID
     * 请求参数：handleUser（处理人）、handleResult（处理结果）、status（处理状态：已办结/驳回）
     * 返回值：统一响应结果
     */
    @PutMapping("/handle/{id}")
    public Result handleComplaint(
            @PathVariable("id") Long complaintId,
            @RequestParam String handleUser,
            @RequestParam String handleResult,
            @RequestParam String status) {
        try {
            // 参数校验
            if (complaintId == null || complaintId <= 0) {
                return Result.error("投诉ID必须为正整数");
            }
            if (handleUser == null || handleUser.trim().isEmpty()) {
                return Result.error("处理人不能为空");
            }
            if (handleResult == null || handleResult.trim().isEmpty()) {
                return Result.error("处理结果不能为空");
            }
            if (status == null || status.trim().isEmpty()) {
                return Result.error("处理状态不能为空（已办结/驳回）");
            }

            // 调用Service处理投诉
            complaintService.handleComplaint(complaintId, handleUser, handleResult, status);

            return Result.success("投诉处理成功", null);
        } catch (Exception e) {
            return Result.error("投诉处理失败：" + e.getMessage());
        }
    }

    /**
     * 条件查询投诉列表
     * 请求方式：GET
     * 请求地址：/api/complaint/list
     * 请求参数：status（可选）、agencyId（可选）、guideId（可选）
     * 返回值：投诉列表数据
     */
    @GetMapping("/list")
    public Result listComplaints(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long agencyId,
            @RequestParam(required = false) Long guideId) {
        try {
            // 调用Service查询列表（参数为空时查询所有）
            List<Complaint> complaintList = complaintService.listComplaints(status, agencyId, guideId);

            return Result.success("查询投诉列表成功", complaintList);
        } catch (Exception e) {
            return Result.error("查询投诉列表失败：" + e.getMessage());
        }
    }

    /**
     * 根据ID查询投诉详情
     * 请求方式：GET
     * 请求地址：/api/complaint/{id}
     * 路径参数：id - 投诉ID
     * 返回值：单个投诉详情
     */
    @GetMapping("/{id}")
    public Result getComplaintById(@PathVariable Long id) {
        try {
            // 参数校验
            if (id == null || id <= 0) {
                return Result.error("投诉ID必须为正整数");
            }

            // 调用Service查询详情
            Complaint complaint = complaintService.getComplaintById(id);

            return Result.success("查询投诉详情成功", complaint);
        } catch (Exception e) {
            return Result.error("查询投诉详情失败：" + e.getMessage());
        }
    }

    /**
     * 删除投诉（物理删除）
     * 请求方式：DELETE
     * 请求地址：/api/complaint/{id}
     * 路径参数：id - 投诉ID
     * 返回值：统一响应结果
     */
    @DeleteMapping("/{id}")
    public Result deleteComplaint(@PathVariable Long id) {
        try {
            // 调用Service删除投诉
            complaintService.deleteComplaint(id);

            return Result.success("投诉删除成功", null);
        } catch (Exception e) {
            return Result.error("投诉删除失败：" + e.getMessage());
        }
    }
}