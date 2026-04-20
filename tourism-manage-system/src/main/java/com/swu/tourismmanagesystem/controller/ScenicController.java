package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.scenic.*;
import com.swu.tourismmanagesystem.service.ScenicService;
import com.swu.tourismmanagesystem.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/spot")
public class ScenicController {

    @Autowired
    ScenicService scenicService;

    // ==================== 1. 景区列表（支持模糊搜索）====================
    // 进入页面 / 搜索时调用
    @GetMapping("/list")
    public Result list(@RequestParam(required = false) String spotName) {
        List<ScenicSpot> list;

        // 如果有搜索名称 → 模糊查询
        if (StringUtils.hasText(spotName)) {
            list = scenicService.getSpotListByName(spotName);
        } else {
            // 无搜索 → 查询全部
            list = scenicService.findAllSpot();
        }
        return Result.success("获取景区列表成功", list);
    }

    // ==================== 2. 根据ID查询详情（点击列表项时调用）====================
    @GetMapping("/detail")
    public Result detail(@RequestParam Long id) {
        if (id == null) {
            return Result.error("景区ID不能为空");
        }
        Map<String, Object> detail = scenicService.getSpotDetailById(id);
        return Result.success("获取详情成功", detail);
    }

    // ==================== 3. 景区名称列表====================
    @GetMapping("/nameList")
    public Result getNameList() {
        List<ScenicSpot> allSpot = scenicService.findAllSpot();
        List<String> nameList = scenicService.getSpotNameList(allSpot);
        return Result.success("获取成功", nameList);
    }
    //===================景区实时数据上传===========
    @PostMapping("/realTime/upload")
    public Result uploadScenicRealTime(@RequestBody ScenicRealTimeData rt) {
        // 1. 非空校验
        if (rt.getSpotId() == null) {
            return Result.error("景区ID不能为空");
        }
        if (rt.getCurrentVisitors() == null) {
            return Result.error("当前游客数不能为空");
        }

        try {
            ScenicRealTimeData exist = scenicService.getRealTimeByScenicId(rt.getSpotId());
            int rows;
            if (exist == null) {
                rows = scenicService.insertRealTime(rt);
            } else {
                rows = scenicService.updateRealTime(rt);
            }
            if (rows > 0) {
                return Result.success("景区实时数据上传成功", null);
            } else {
                return Result.error("景区实时数据上传失败");
            }
        } catch (Exception e) {
            // 捕获异常，返回友好提示
            e.printStackTrace();
            return Result.error("上传失败：" + e.getMessage());
        }
    }

    // ==================== 查询单个景区实时数据====================
    @GetMapping("/realTime")
    public Result getScenicRealTime(@RequestParam Long spotId) {
        if (spotId == null) {
            return Result.error("景区ID不能为空");
        }
        ScenicRealTimeData data = scenicService.getRealTimeByScenicId(spotId);
        return Result.success("查询景区实时数据成功", data);
    }

}