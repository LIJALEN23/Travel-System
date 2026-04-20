package com.swu.tourismmanagesystem.controller;

import com.swu.tourismmanagesystem.entity.agency.*;
import com.swu.tourismmanagesystem.service.AgencyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/agency")
public class AgencyController {

    @Autowired
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
        res.put("msg", "查询旅行社列表成功");
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
        res.put("msg", "查询旅行社信息成功");
        res.put("data", agency);
        return res;
    }

    // ==========================
    // 3. 该旅行社所有管理员
    // ==========================
    @GetMapping("/manager/{agencyId}")
    public Map<String, Object> manager(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<AgencyManager> list = agencyService.getManagerByAgency(agencyId);
        res.put("code", 200);
        res.put("msg", "查询管理人员成功");
        res.put("data", list);
        return res;
    }

    // ==========================
    // 4. 该旅行社所有驾驶员
    // ==========================
    @GetMapping("/driver/{agencyId}")
    public Map<String, Object> driver(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<VehicleDriver> list = agencyService.getDriverByAgency(agencyId);
        res.put("code", 200);
        res.put("msg", "查询驾驶员列表成功");
        res.put("data", list);
        return res;
    }

    // ==========================
    // 5. 该旅行社所有车辆
    // ==========================
    @GetMapping("/vehicle/{agencyId}")
    public Map<String, Object> vehicle(@PathVariable Long agencyId) {
        Map<String, Object> res = new HashMap<>();
        List<TourismVehicle> list = agencyService.getVehicleByAgency(agencyId);
        res.put("code", 200);
        res.put("msg", "查询车辆列表成功");
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
        res.put("msg", "查询应急救援信息成功");
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
        res.put("msg", "查询实时数据成功");
        res.put("data", data);
        return res;
    }

    // ==========================
    // 8. 该旅行社所有电子行程单
    // ==========================
    @GetMapping("/order/list")
    public Map<String, Object> orderList(
            @RequestParam Long agencyId,  // 必传：旅行社ID
            @RequestParam(required = false) String orderStatus,  // 可选：行程状态
            @RequestParam(required = false) String teamName,     // 可选：团队名称（模糊）
            @RequestParam(required = false) String startTime      // 可选：出发时间
    ) {
        Map<String, Object> res = new HashMap<>();
        List<TravelOrder> list = agencyService.getOrderByCondition(agencyId, orderStatus, teamName, startTime);
        res.put("code", 200);
        res.put("msg", "筛选行程单成功");
        res.put("data", list);
        return res;
    }
    //========添加行程单========
    @PostMapping("/order/add")
    public Map<String, Object> addOrder(@RequestBody TravelOrder order) {
        Map<String, Object> res = new HashMap<>();

        // 必填参数校验
        if (order.getAgencyId() == null || order.getVehicleId() == null || order.getDriverId() == null) {
            res.put("code", 400);
            res.put("msg", "新增失败：旅行社ID、车辆ID、司机ID不能为空");
            return res;
        }

        // 默认状态：待确定（贴合你的业务）
        if (order.getOrderStatus() == null) {
            order.setOrderStatus("待确定");
        }

        int rows = agencyService.addOrder(order);
        if (rows > 0) {
            res.put("code", 200);
            res.put("msg", "新增行程单成功");
            res.put("data", order.getId()); // 返回新增的ID
        } else {
            res.put("code", 500);
            res.put("msg", "新增行程单失败");
        }
        return res;
    }
    // ==========================
    // 9. 单个行程单详情（含司机+车辆）
    // ==========================
    @GetMapping("/order/detail/{orderId}")
    public Map<String, Object> orderDetail(@PathVariable Long orderId) {
        Map<String, Object> res = new HashMap<>();
        TravelOrder order = agencyService.getOrderById(orderId);

        if (order == null) {
            res.put("code", 404);
            res.put("msg", "该行程单不存在");
            return res;
        }

        VehicleDriver driver = agencyService.getDriverById(order.getDriverId());
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
    public Map<String, Object> abroadList(
            @PathVariable Long agencyId,
            @RequestParam(required = false) String visaStatus  // 筛选条件：待审核/通过/驳回
    ) {
        Map<String, Object> res = new HashMap<>();
        List<AbroadTravel> list = agencyService.getAbroadByAgency(agencyId, visaStatus);
        res.put("code", 200);
        res.put("msg", "查询出境游列表成功");
        res.put("data", list);
        return res;
    }

    // ==========================
    // 11. 出境游审核
    // ==========================
    @PostMapping("/abroad/audit")
    public Map<String, Object> audit(@RequestBody AbroadTravel abroad) {
        Map<String, Object> res = new HashMap<>();

        // 前端只需要传 id + visaStatus
        if (abroad.getId() == null || abroad.getVisaStatus() == null) {
            res.put("code", 400);
            res.put("msg", "审核失败：id 和签证状态不能为空");
            return res;
        }

        int rows = agencyService.updateVisa(abroad);
        if (rows > 0) {
            res.put("code", 200);
            res.put("msg", "审核成功");
        } else {
            res.put("code", 404);
            res.put("msg", "审核失败：记录不存在");
        }
        return res;
    }
    // 12. 新增出境游申请
    @PostMapping("/abroad/add")
    public Map<String, Object> addAbroad(@RequestBody AbroadTravel abroad) {
        Map<String, Object> res = new HashMap<>();
        int rows = agencyService.addAbroad(abroad);

        if (rows > 0) {
            res.put("code", 200);
            res.put("msg", "新增出境游申请成功");
        } else {
            res.put("code", 500);
            res.put("msg", "新增失败");
        }
        return res;
    }
}