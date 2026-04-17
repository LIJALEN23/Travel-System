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
}