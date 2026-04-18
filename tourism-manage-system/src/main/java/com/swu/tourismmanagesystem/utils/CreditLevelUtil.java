package com.swu.tourismmanagesystem.utils;

public class CreditLevelUtil {

    /**
     * 根据诚信分数 自动计算等级
     * 100~75 → A
     * 74~50 → B
     * 49~25 → C
     * 24~0 → D
     */
    public static String getLevelByScore(int score) {
        if (score < 0) score = 0;
        if (score > 100) score = 100;

        if (score >= 75) {
            return "A";
        } else if (score >= 50) {
            return "B";
        } else if (score >= 25) {
            return "C";
        } else {
            return "D";
        }
    }
}