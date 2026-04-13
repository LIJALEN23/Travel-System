package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.scenic.ScenicSpot;
import com.swu.tourismmanagesystem.service.ScenicService;
import com.swu.tourismmanagesystem.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

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
}