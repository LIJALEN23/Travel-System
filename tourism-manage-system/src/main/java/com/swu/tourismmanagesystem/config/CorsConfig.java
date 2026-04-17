package com.swu.tourismmanagesystem.config;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.annotation.Resource;
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Resource
    private LoginConfig loginConfig;

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                // 开发阶段：允许所有域名；生产阶段替换为具体前端域名
                .allowedOriginPatterns("*")
                // 允许携带Token/Cookie（登录态必备）
                .allowCredentials(true)
                // 允许的请求方法
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                // 允许所有请求头
                .allowedHeaders("*")
                // 暴露JWT Token响应头，让前端能获取
                .exposedHeaders(loginConfig.getJwt().getTokenHeader());
    }
}
