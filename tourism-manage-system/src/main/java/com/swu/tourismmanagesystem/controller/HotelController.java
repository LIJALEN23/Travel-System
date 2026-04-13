package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.hotel.HotelBase;
import com.swu.tourismmanagesystem.service.HotelService;
import com.swu.tourismmanagesystem.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/hotel")
public class HotelController {

    @Autowired
    HotelService hotelService;

    // ==================== 1. 酒店列表（支持模糊搜索 + 星级筛选）====================
    // 进入页面 / 搜索时调用
    @GetMapping("/list")
    public Result list(
            @RequestParam(required = false) String hotelName,
            @RequestParam(required = false) Integer starLevel) {

        List<HotelBase> list;

        // 如果有名称 或 有星级 → 条件查询
        if (StringUtils.hasText(hotelName) || starLevel != null) {
            list = hotelService.getHotelListByName(hotelName, starLevel);
        } else {
            // 无搜索 → 查询全部
            list = hotelService.findAllHotel();
        }
        return Result.success("获取酒店列表成功", list);
    }

    // ==================== 2. 根据ID查询详情（点击列表项时调用）====================
    @GetMapping("/detail")
    public Result detail(@RequestParam Long id) {
        if (id == null) {
            return Result.error("酒店ID不能为空");
        }
        Map<String, Object> detail = hotelService.getHotelDetailById(id);
        return Result.success("获取详情成功", detail);
    }

    // ==================== 3. 酒店名称列表 ====================
    @GetMapping("/nameList")
    public Result getNameList() {
        List<HotelBase> allHotel = hotelService.findAllHotel();
        List<String> nameList = hotelService.getHotelNameList(allHotel);
        return Result.success("获取成功", nameList);
    }
}