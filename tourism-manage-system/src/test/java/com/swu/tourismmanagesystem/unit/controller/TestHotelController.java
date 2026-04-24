package com.swu.tourismmanagesystem.unit.controller;

import com.swu.tourismmanagesystem.controller.HotelController;
import com.swu.tourismmanagesystem.entity.hotel.HotelBase;
import com.swu.tourismmanagesystem.entity.hotel.HotelRealTimeData;
import com.swu.tourismmanagesystem.service.HotelService;
import com.swu.tourismmanagesystem.utils.Result;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

/**
 * HotelController 单元测试
 * 使用 Mock 模拟 HotelService 服务层，避免数据库依赖
 */
@ExtendWith(MockitoExtension.class)
class TestHotelController {

    @Mock
    private HotelService hotelService;

    private HotelController hotelController;

    @BeforeEach
    void setUp() {
        // 创建 Controller 实例
        hotelController = new HotelController();
        // 注入 Mock 的服务
        ReflectionTestUtils.setField(hotelController, "hotelService", hotelService);
    }

    // ==================== 【整合版】酒店列表 ====================

    /**
     * 测试按景区 ID 查询酒店列表（正常情况）
     */
    @Test
    @DisplayName("按景区 ID 查询酒店列表应成功")
    void testListByScenicIdSuccess() {
        Long scenicId = 1L;
        String hotelName = "测试酒店";
        Integer starLevel = 5;

        // 模拟查询结果
        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店 A");
                setStarLevel(5);
            }
        });
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店 B");
                setStarLevel(4);
            }
        });
        when(hotelService.findHotelByScenicId(scenicId)).thenReturn(hotelList);

        // 执行查询
        Result result = hotelController.list("测试酒店", starLevel, scenicId);

        // 验证
        assertEquals("获取酒店列表成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).findHotelByScenicId(scenicId);
    }

    /**
     * 测试按景区 ID 查询 + 名称筛选
     */
    @Test
    @DisplayName("按景区 ID 查询并筛选名称应成功")
    void testListByScenicIdWithNameFilter() {
        Long scenicId = 1L;
        String hotelName = "测试";
        Integer starLevel = null;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店 A");
                setStarLevel(5);
                setMapUrl("https://map.com");
            }
        });
        hotelList.add(new HotelBase() {
            {
                setHotelName("其他酒店");
                setStarLevel(4);
                setMapUrl("https://map.com");
            }
        });
        when(hotelService.findHotelByScenicId(scenicId)).thenReturn(hotelList);

        Result result = hotelController.list("测试", starLevel, scenicId);

        assertEquals("获取酒店列表成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).findHotelByScenicId(scenicId);
    }

    /**
     * 测试按景区 ID 查询 + 星级筛选
     */
    @Test
    @DisplayName("按景区 ID 查询并筛选星级应成功")
    void testListByScenicIdWithStarLevelFilter() {
        Long scenicId = 1L;
        String hotelName = null;
        Integer starLevel = 5;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店");
                setStarLevel(3);
                setMapUrl("https://map.com");
            }
        });
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店");
                setStarLevel(5);
                setMapUrl("https://map.com");
            }
        });
        when(hotelService.findHotelByScenicId(scenicId)).thenReturn(hotelList);

        Result result = hotelController.list(hotelName, starLevel, scenicId);

        assertEquals("获取酒店列表成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).findHotelByScenicId(scenicId);
    }

    /**
     * 测试按名称查询酒店列表（无景区 ID）
     */
    @Test
    @DisplayName("按名称查询酒店列表应成功")
    void testListByName() {
        String hotelName = "测试酒店";
        Integer starLevel = null;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店 A");
                setStarLevel(5);
            }
        });
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店 B");
                setStarLevel(4);
            }
        });
        when(hotelService.getHotelListByName(hotelName, starLevel)).thenReturn(hotelList);

        Result result = hotelController.list(hotelName, starLevel, null);

        assertEquals("获取酒店列表成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).getHotelListByName(hotelName, starLevel);
    }

    /**
     * 测试按星级查询酒店列表（无景区 ID）
     */
    @Test
    @DisplayName("按星级查询酒店列表应成功")
    void testListByStarLevel() {
        String hotelName = null;
        Integer starLevel = 5;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店");
                setStarLevel(3);
            }
        });
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店");
                setStarLevel(5);
            }
        });
        when(hotelService.getHotelListByName(hotelName, starLevel)).thenReturn(hotelList);

        Result result = hotelController.list(hotelName, starLevel, null);

        assertEquals("获取酒店列表成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).getHotelListByName(hotelName, starLevel);
    }

    /**
     * 测试查询全部酒店列表（无筛选条件）
     */
    @Test
    @DisplayName("查询全部酒店列表应成功")
    void testListAllHotels() {
        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店");
                setStarLevel(5);
            }
        });
        when(hotelService.findAllHotel()).thenReturn(hotelList);

        Result result = hotelController.list(null, null, null);

        assertEquals("获取酒店列表成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).findAllHotel();
    }

    /**
     * 测试查询全部酒店列表并带名称筛选
     */
    @Test
    @DisplayName("查询全部酒店列表并带名称筛选应调用 getHotelListByName")
    void testListAllWithFilter() {
        String hotelName = "测试";
        Integer starLevel = 5;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(
                new HotelBase() {
                    {
                        setHotelName("测试酒店");
                        setStarLevel(5);
                    }
                }
        );
        when(hotelService.getHotelListByName(hotelName, starLevel)).thenReturn(hotelList);

        Result result = hotelController.list(hotelName, starLevel, null);

        assertEquals("获取酒店列表成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).getHotelListByName(hotelName, starLevel);
    }

    // ==================== 详情 ====================

    /**
     * 测试查询酒店详情（正常情况）
     */
    @Test
    @DisplayName("查询酒店详情应成功")
    void testDetailSuccess() {
        Long hotelId = 1L;

        Map<String, Object> detail = new HashMap<>();
        detail.put("id", hotelId);
        detail.put("hotelName", "测试酒店");
        detail.put("starLevel", 5);
        detail.put("address", "北京市海淀区");
        when(hotelService.getHotelDetailById(hotelId)).thenReturn(detail);

        Result result = hotelController.detail(hotelId);

        assertEquals("获取详情成功", result.getMsg());
        assertEquals(200, result.getCode());
        assertNotNull(result.getData());
        verify(hotelService).getHotelDetailById(hotelId);
    }

    /**
     * 测试查询酒店详情（ID 为空）
     */
    @Test
    @DisplayName("查询酒店详情 ID 为空应返回错误")
    void testDetailWithNullId() {
        Result result = hotelController.detail(null);

        assertEquals("酒店ID不能为空", result.getMsg());
        assertEquals(500, result.getCode());
        verify(hotelService, never()).getHotelDetailById(anyLong());
    }

    // ==================== 酒店名称列表 ====================

    /**
     * 测试按景区 ID 查询酒店名称列表（正常情况）
     */
    @Test
    @DisplayName("按景区 ID 查询酒店名称列表应成功")
    void testNameListByScenicId() {
        Long scenicId = 1L;
        String hotelName = null;
        Integer starLevel = null;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(
                new HotelBase() {
                    {
                        setHotelName("测试酒店 A");
                        setStarLevel(5);
                        setMapUrl("https://map.com");
                    }
            });
        hotelList.add(
                new HotelBase() {
                    {
                        setHotelName("测试酒店 B");
                        setStarLevel(4);
                        setMapUrl("https://map.com");
                    }
                }
        );
        when(hotelService.findHotelByScenicId(scenicId)).thenReturn(hotelList);

        Result result = hotelController.nameList(hotelName, starLevel, scenicId);

        assertEquals("获取酒店名称成功", result.getMsg());
        assertNotNull(result.getData());
        assertNotNull(result.getData());
        List<String> names = (List<String>) result.getData();
        assertEquals(2, names.size());
        assertEquals(200, result.getCode());
        verify(hotelService).findHotelByScenicId(scenicId);
    }

    /**
     * 测试按名称筛选酒店名称列表
     */
    @Test
    @DisplayName("按名称筛选酒店名称列表应成功")
    void testNameListWithNameFilter() {
        String hotelName = "测试";
        Integer starLevel = null;
        Long scenicId = null;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(new HotelBase() {
            {
                setHotelName("测试酒店 A");
                setStarLevel(5);
                setMapUrl("https://map.com");
            }
        });
        hotelList.add(new HotelBase() {
            {
                setHotelName("其他酒店");
                setStarLevel(4);
                setMapUrl("https://map.com");
            }
        });
        when(hotelService.getHotelListByName(hotelName, starLevel)).thenReturn(hotelList);

        Result result = hotelController.nameList(hotelName, starLevel, scenicId);

        assertEquals("获取酒店名称成功", result.getMsg());
        assertEquals(200, result.getCode());
        List<String> names = (List<String>) result.getData();
        assertEquals("测试酒店 A", names.get(0));
        verify(hotelService).getHotelListByName(hotelName, starLevel);
    }

    /**
     * 测试按星级筛选酒店名称列表
     */
    @Test
    @DisplayName("按星级筛选酒店名称列表应成功")
    void testNameListWithStarLevelFilter() {
        String hotelName = null;
        Integer starLevel = 5;
        Long scenicId = null;

        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(
                new HotelBase() {
                    {
                        setHotelName("测试酒店");
                        setStarLevel(3);
                        setMapUrl("https://map.com");
                    }
                }
        );
        hotelList.add(
                new HotelBase() {
                    {
                        setHotelName("测试酒店");
                        setStarLevel(5);
                        setMapUrl("https://map.com");
                    }
                }
        );
        when(hotelService.getHotelListByName(hotelName, starLevel)).thenReturn(hotelList);

        Result result = hotelController.nameList(hotelName, starLevel, scenicId);

        assertEquals("获取酒店名称成功", result.getMsg());
        assertEquals(200, result.getCode());
        verify(hotelService).getHotelListByName(hotelName, starLevel);
    }

    /**
     * 测试查询全部酒店名称列表
     */
    @Test
    @DisplayName("查询全部酒店名称列表应成功")
    void testNameListAllHotels() {
        List<HotelBase> hotelList = new ArrayList<>();
        hotelList.add(
                new HotelBase() {
                    {
                        setHotelName("测试酒店");
                        setStarLevel(5);
                        setMapUrl("https://map.com");
                    }
                }
        );
        when(hotelService.findAllHotel()).thenReturn(hotelList);

        Result result = hotelController.nameList(null, null, null);

        assertEquals("获取酒店名称成功", result.getMsg());
        assertEquals(200, result.getCode());
        List<String> names = (List<String>) result.getData();
        assertEquals("测试酒店", names.get(0));
        verify(hotelService).findAllHotel();
    }

    // ==================== 实时数据上传 ====================

    /**
     * 测试上传实时数据（酒店 ID 为空）
     */
    @Test
    @DisplayName("上传实时数据酒店 ID 为空应返回错误")
    void testUploadRealTimeWithNullHotelId() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(null);
        data.setCurrentVisitors(100);

        Result result = hotelController.uploadRealTime(data);

        assertEquals("酒店ID不能为空", result.getMsg());
        assertEquals(500, result.getCode());
        verify(hotelService, never()).saveOrUpdateRealTime(any());
    }

    /**
     * 测试上传实时数据（当前游客数为空）
     */
    @Test
    @DisplayName("上传实时数据当前游客数为空应返回错误")
    void testUploadRealTimeWithNullCurrentVisitors() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(null);

        Result result = hotelController.uploadRealTime(data);

        assertEquals("当前游客数不能为空", result.getMsg());
        assertEquals(500, result.getCode());
        verify(hotelService, never()).saveOrUpdateRealTime(any());
    }

    /**
     * 测试上传实时数据（成功）
     */
    @Test
    @DisplayName("上传实时数据应成功")
    void testUploadRealTimeSuccess() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(100);
        data.setRemainingParking(100);

        Result result = hotelController.uploadRealTime(data);

        assertEquals("实时数据上传成功", result.getMsg());
        assertEquals(200, result.getCode());
        verify(hotelService).saveOrUpdateRealTime(any());
    }

    /**
     * 测试上传实时数据（异常）
     */
    @Test
    @DisplayName("上传实时数据发生异常应返回错误")
    void testUploadRealTimeWithError() {
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(1L);
        data.setCurrentVisitors(100);

        doThrow(new RuntimeException("上传失败"))
            .when(hotelService)
            .saveOrUpdateRealTime(any());

        Result result = hotelController.uploadRealTime(data);

        assertEquals("上传失败：上传失败", result.getMsg());
        assertEquals(500, result.getCode());
        verify(hotelService).saveOrUpdateRealTime(any());
    }

    // ==================== 查询实时数据 ====================

    /**
     * 测试查询酒店实时数据（正常情况）
     */
    @Test
    @DisplayName("查询酒店实时数据应成功")
    void testGetRealTimeSuccess() {
        Long hotelId = 1L;
        HotelRealTimeData data = new HotelRealTimeData();
        data.setHotelId(hotelId);
        data.setCurrentVisitors(100);
        data.setRemainingParking(200);

        when(hotelService.getRealTimeByHotelId(hotelId)).thenReturn(data);

        Result result = hotelController.getRealTime(hotelId);

        assertEquals("获取实时数据成功", result.getMsg());
        assertNotNull(result.getData());
        verify(hotelService).getRealTimeByHotelId(hotelId);
    }

    /**
     * 测试查询酒店实时数据（ID 为空）
     */
    @Test
    @DisplayName("查询酒店实时数据 ID 为空应调用服务层")
    void testGetRealTimeWithNullId() {
        when(hotelService.getRealTimeByHotelId(null)).thenReturn(null);

        Result result = hotelController.getRealTime(null);

         assertEquals(200, result.getCode());
        assertEquals(null, result.getData());
        verify(hotelService).getRealTimeByHotelId(null);
    }

    /**
     * 测试查询酒店实时数据（返回 null）
     */
    @Test
    @DisplayName("查询酒店实时数据返回 null 应成功返回 null")
    void testGetRealTimeReturnsNull() {
        when(hotelService.getRealTimeByHotelId(anyLong())).thenReturn(null);

        Result result = hotelController.getRealTime(1L);

        assertEquals(200, result.getCode());
        assertEquals(null, result.getData());
        verify(hotelService).getRealTimeByHotelId(1L);
    }
}
