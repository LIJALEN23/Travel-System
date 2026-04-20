package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.hotel.*;
import com.swu.tourismmanagesystem.service.HotelService;
import com.swu.tourismmanagesystem.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;


import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/hotel")
public class HotelController {

    @Autowired
    HotelService hotelService;

    // ==================== 【整合版】酒店列表（支持：全部 + 景区 + 模糊 + 星级）====================
    @GetMapping("/list")
    public Result list(
            @RequestParam(required = false) String hotelName,
            @RequestParam(required = false) Integer starLevel,
            @RequestParam(required = false) String scenicName
    ) {
        List<HotelBase> list;

        // 1. 优先：按景区查询
        if (scenicName != null) {
            list = hotelService.findHotelByScenicSpotName(scenicName);

            if (StringUtils.hasText(hotelName)) {
                list = list.stream()
                        .filter(h -> h.getHotelName().contains(hotelName))
                        .collect(Collectors.toList());
            }
            if (starLevel != null) {
                list = list.stream()
                        .filter(h -> starLevel.equals(h.getStarLevel()))
                        .collect(Collectors.toList());
            }
        }
        // 2. 名称/星级筛选
        else if (StringUtils.hasText(hotelName) || starLevel != null) {
            list = hotelService.getHotelListByName(hotelName, starLevel);
        }
        // 3. 全部
        else {
            list = hotelService.findAllHotel();
        }

        return Result.success("获取酒店列表成功", list);
    }

    // ==================== 详情 ====================
    @GetMapping("/detail")
    public Result detail(@RequestParam Long id) {
        if (id == null) {
            return Result.error("酒店ID不能为空");
        }
        Map<String, Object> detail = hotelService.getHotelDetailById(id);
        return Result.success("获取详情成功", detail);
    }

    // ==================== 酒店名称列表（修复版） ====================
    @GetMapping("/nameList")
    public Result nameList(
            @RequestParam(required = false) String hotelName,
            @RequestParam(required = false) Integer starLevel,
            @RequestParam(required = false) String scenicName
    ) {
        List<HotelBase> list;

        // 完全复用 list 的查询逻辑
        if (scenicName != null) {
            list = hotelService.findHotelByScenicSpotName(scenicName);

            if (StringUtils.hasText(hotelName)) {
                list = list.stream().filter(h -> h.getHotelName().contains(hotelName)).collect(Collectors.toList());
            }
            if (starLevel != null) {
                list = list.stream().filter(h -> starLevel.equals(h.getStarLevel())).collect(Collectors.toList());
            }
        } else if (StringUtils.hasText(hotelName) || starLevel != null) {
            list = hotelService.getHotelListByName(hotelName, starLevel);
        } else {
            list = hotelService.findAllHotel();
        }

        // 只抽取名称
        List<String> names = list.stream()
                .map(HotelBase::getHotelName)
                .collect(Collectors.toList());

        return Result.success("获取酒店名称成功", names);
    }
    @PostMapping("/realTime/upload")
    public Result uploadRealTime(@RequestBody HotelRealTimeData data) {
        if (data.getHotelId() == null) {
            return Result.error("酒店ID不能为空");
        }
        if (data.getCurrentVisitors() == null) { // 新增：校验当前游客数
            return Result.error("当前游客数不能为空");
        }
        try {
            hotelService.saveOrUpdateRealTime(data);
            return Result.success("实时数据上传成功", null);
        } catch (Exception e) {
            return Result.error("上传失败：" + e.getMessage());
        }
    }

    // ===================== 查询酒店实时数据 =====================
    @GetMapping("/realTime")
    public Result getRealTime(@RequestParam Long hotelId) {
        HotelRealTimeData data = hotelService.getRealTimeByHotelId(hotelId);
        return Result.success("获取实时数据成功", data);
    }
}