package com.swu.tourismmanagesystem.interceptor;

import com.swu.tourismmanagesystem.config.LoginConfig;
import com.swu.tourismmanagesystem.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Component // 让Spring管理
@Slf4j    // 日志
public class LoginInterceptor implements HandlerInterceptor {

    private final LoginConfig loginConfig;
    private final JwtUtil jwtUtil;

    public LoginInterceptor(LoginConfig loginConfig, JwtUtil jwtUtil) {
        this.loginConfig = loginConfig;
        this.jwtUtil = jwtUtil;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String requestURI = request.getRequestURI();
        String method = request.getMethod();

        // ====================== 修复1：放行 OPTIONS 预检请求（跨域必须）======================
        if ("OPTIONS".equalsIgnoreCase(method)) {
            response.setStatus(HttpServletResponse.SC_OK);
            return true;
        }

        // ====================== 获取Token ======================
        String headerName = loginConfig.getJwt().getTokenHeader();
        String token = request.getHeader(headerName);

        // 无Token
        if (token == null || token.isEmpty()) {
            log.warn("登录拦截：请求地址 {}，未携带Token", requestURI);
            response.setStatus(401);
            return false;
        }

        // 去掉 Bearer 前缀
        String prefix = loginConfig.getJwt().getTokenPrefix() + " ";
        if (token.startsWith(prefix)) {
            token = token.substring(prefix.length());
        }

        // ====================== 修复2：验证Token（包含过期校验）======================
        if (!jwtUtil.validateToken(token)) {
            log.warn("登录拦截：Token无效或已过期，地址：{}", requestURI);
            response.setStatus(401);
            return false;
        }

        log.info("登录校验通过：{}", requestURI);
        return true;
    }
}