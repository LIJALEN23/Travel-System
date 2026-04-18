package com.swu.tourismmanagesystem.mapper;

import com.swu.tourismmanagesystem.entity.complaint.Complaint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;
@Mapper
public interface ComplaintMapper {

    // 新增投诉
    int insertComplaint(Complaint complaint);

    // 根据ID查询单条投诉
    Complaint getComplaintById(Long id);

    // 查询所有投诉（可按 状态、旅行社ID、导游ID 筛选）
    List<Complaint> listComplaint(
            @Param("status") String status,
            @Param("agencyId") Long agencyId,
            @Param("guideId") Long guideId
    );

    // 修改投诉（处理投诉用）
    int updateComplaint(Complaint complaint);

    // 删除投诉
    int deleteComplaint(Long id);
    // ------------------------ 统一投诉数统计方法 ------------------------
    // 1. 统计旅行社有效投诉数（排除驳回状态）
    int countAgencyValidComplaints(@Param("agencyId") Long agencyId);

    // 2. 统计旅行社不良投诉数（已办结 + 较重/严重等级）
    int countAgencyBadComplaints(@Param("agencyId") Long agencyId);

    // 3. 统计导游有效投诉数（排除驳回状态）
    int countGuideValidComplaints(@Param("guideId") Long guideId);

    // 4. 统计导游不良投诉数（已办结 + 较重/严重等级）
    int countGuideBadComplaints(@Param("guideId") Long guideId);

    // 5. 统计旅行社指定状态的投诉数（灵活扩展）
    int countAgencyComplaintsByStatus(
            @Param("agencyId") Long agencyId,
            @Param("status") String status
    );

    // 6. 统计导游指定状态的投诉数（灵活扩展）
    int countGuideComplaintsByStatus(
            @Param("guideId") Long guideId,
            @Param("status") String status
    );
}