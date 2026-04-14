package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.agency.*;
import com.swu.tourismmanagesystem.service.AgencyService;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/agency")
public class AgencyController {

    @Resource
    private AgencyService agencyService;

    // ==========================
    // 1. 旅行社列表 + 模糊查询
    // ==========================
    @GetMapping("/list")
    public Map<String, Object> list(
            @RequestParam(required = false) String agencyName,
            @RequestParam(required = false) String licenseNo) {
        Map<String, Object> res = new HashMap<>();
        List<TravelAgency> list = agencyService.getAgencyByLike(agencyName, licenseNo);
        res.put("code", 200);
        res.put("msg", "查询成功");
        res.put("data", list);
        return res;
    }

    // ==========================
    // 2. 旅行社基础信息
    // ==========================
    @GetMapping("/baseInfo/{agencyId}")
    public Map<String, Object> baseInfo(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        TravelAgency agency = agencyService.getAgencyById(agencyId);
        res.put("code", 200);
        res.put("data", agency);
        return res;
    }

    // ==========================
    // 3. 该旅行社所有管理员（多个）
    // ==========================
    @GetMapping("/manager/{agencyId}")
    public Map<String, Object> manager(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<AgencyManager> list = agencyService.getManagerByAgency(agencyId);
        res.put("code", 200);
        res.put("data", list);
        return res;
    }

    // ==========================
    // 4. 该旅行社所有驾驶员（多个）
    // ==========================
    @GetMapping("/driver/{agencyId}")
    public Map<String, Object> driver(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<VehicleDriver> list = agencyService.getDriverByAgency(agencyId);
        res.put("code", 200);
        res.put("data", list);
        return res;
    }

    // ==========================
    // 5. 该旅行社所有车辆（多个）
    // ==========================
    @GetMapping("/vehicle/{agencyId}")
    public Map<String, Object> vehicle(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<TourismVehicle> list = agencyService.getVehicleByAgency(agencyId);
        res.put("code", 200);
        res.put("data", list);
        return res;
    }

    // ==========================
    // 6. 应急救援
    // ==========================
    @GetMapping("/emergency/{agencyId}")
    public Map<String, Object> emergency(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<AgencyEmergency> list = agencyService.getEmergencyByAgency(agencyId);
        res.put("code", 200);
        res.put("data", list);
        return res;
    }

    // ==========================
    // 7. 实时运行数据
    // ==========================
    @GetMapping("/realData/{agencyId}")
    public Map<String, Object> realData(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        AgencyRealTimeData data = agencyService.getRealTimeData(agencyId);
        res.put("code", 200);
        res.put("data", data);
        return res;
    }

    // ==========================
    // 8. 该旅行社所有电子行程单
    // ==========================
    @GetMapping("/order/list/{agencyId}")
    public Map<String, Object> orderList(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<TravelOrder> list = agencyService.getOrderByAgency(agencyId);
        res.put("code", 200);
        res.put("data", list);
        return res;
    }

    // ==========================
    // 9. 单个行程单详情
    // → 只显示当前司机 + 当前车辆
    // ==========================
    @GetMapping("/order/detail/{orderId}")
    public Map<String, Object> orderDetail(@PathVariable Long orderId) {
        Map<String, Object> res = new HashMap<>();
        TravelOrder order = agencyService.getOrderById(orderId);
        // 判断订单是否为空 —
        if (order == null) {
            res.put("code", 404);
            res.put("msg", "该行程单不存在");
            return res;
        }
        // 行程单 → 绑定的单个司机
        VehicleDriver driver = agencyService.getDriverById(order.getDriverId());
        // 行程单 → 绑定的单个车辆
        TourismVehicle vehicle = agencyService.getVehicleById(order.getVehicleId());

        Map<String, Object> data = new HashMap<>();
        data.put("order", order);
        data.put("driver", driver);
        data.put("vehicle", vehicle);

        res.put("code", 200);
        res.put("msg", "获取行程单详情成功");
        res.put("data", data);
        return res;
    }

    // ==========================
    // 10. 该旅行社出境游列表
    // ==========================
    @GetMapping("/abroad/list/{agencyId}")
    public Map<String, Object> abroadList(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<AbroadTravel> list = agencyService.getAbroadByAgency(agencyId);
        res.put("code", 200);
        res.put("data", list);
        return res;
    }

    // ==========================
    // 11. 出境游审核
    // ==========================
    @PostMapping("/abroad/audit")
    public Map<String, Object> audit(@RequestBody AbroadTravel abroad) {
        Map<String, Object> res = new HashMap<>();

        // 这里会返回更新了几行
        int rows = agencyService.updateVisa(abroad);

        if (rows > 0) {
            res.put("code", 200);
            res.put("msg", "审核成功");
        } else {
            res.put("code", 404);
            res.put("msg", "审核失败：该出境游记录不存在");
        }

        return res;
    }
}