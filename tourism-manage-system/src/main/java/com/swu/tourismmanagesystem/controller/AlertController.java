package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.utils.Result;
import com.swu.tourismmanagesystem.entity.alertmessage.*;
import com.swu.tourismmanagesystem.service.AlertService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/alert")
public class AlertController {

    @Resource
    private AlertService alertService;

    // ========================== 1. 查询所有告警/提示 ==========================
    @GetMapping("/list")
    public Result list() {
        return Result.success("查询成功", alertService.getMessageList());
    }

    // ========================== 2. 根据ID查看详情 ==========================
    @GetMapping("/get/{id}")
    public Result getById(@PathVariable Long id) {
        return Result.success("查询成功", alertService.getMessageById(id));
    }

    // ========================== 3. 系统自动生成告警/提示（内部调用） ==========================
    @GetMapping("/autoCheck")
    public Map<String, Object> autoCheck() {
        Map<String, Object> result = new HashMap<>();
        try {
            alertService.autoCheckAndGenerateMessage();
            result.put("code", 200);
            result.put("msg", "自动检测完成，已生成异常告警信息");
        } catch (Exception e) {
            result.put("code", 500);
            result.put("msg", "检测失败：" + e.getMessage());
        }
        return result;
    }

    // ========================== 4. 值班员审核通过 → 改为待发布 ==========================
    @PostMapping("/checkPass")
    public Result checkPass(@RequestParam Long id,
                            @RequestParam String operator) {
        int rows = alertService.checkPass(id, operator);
        return rows > 0 ? Result.success("审核通过，待领导审批发布", null) : Result.error("审核失败");
    }

    // ========================== 5. 领导审批并发布 ==========================
    @PostMapping("/publish")
    public Result publish(@RequestParam Long id,
                          @RequestParam String leader) {
        int rows = alertService.publish(id, leader);
        return rows > 0 ? Result.success("已发布至信息发布系统", null) : Result.error("发布失败");
    }

    // ========================== 6. 无需发布 → 直接处置并登记 ==========================
    @PostMapping("/handle")
    public Result handle(@RequestParam Long id,
                         @RequestParam String handleResult,
                         @RequestParam String handler) {
        int rows = alertService.handle(id, handleResult, handler);
        return rows > 0 ? Result.success("处置完成，已登记备查", null) : Result.error("处置失败");
    }

    // ========================== 7. 查询处置记录 ==========================
    @GetMapping("/handleList/{alertId}")
    public Result handleList(@PathVariable Long alertId) {
        return Result.success("查询成功", alertService.getHandleList(alertId));
    }
}