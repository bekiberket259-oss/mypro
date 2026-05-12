package com.busbooking.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    public static String hashPassword(String plainTextPassword) {
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(12));
    }

    public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
        if (hashedPassword == null) {
            return false;
        }
        return BCrypt.checkpw(plainTextPassword, hashedPassword);
    }
}