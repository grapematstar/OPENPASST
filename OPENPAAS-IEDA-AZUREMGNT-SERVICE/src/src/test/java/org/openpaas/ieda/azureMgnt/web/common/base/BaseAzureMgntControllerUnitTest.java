package org.openpaas.ieda.azureMgnt.web.common.base;

import java.nio.charset.Charset;
import java.security.Principal;

import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

public class BaseAzureMgntControllerUnitTest {
	public static final MediaType APPLICATION_JSON_UTF8 = new MediaType(MediaType.APPLICATION_JSON.getType(), 
            MediaType.APPLICATION_JSON.getSubtype(), Charset.forName("utf8"));

    /****************************************************************
     * @project : Paas 플랫폼 설치 자동화
     * @description : 로그인
     * @title : getLoggined
     * @return : Principal
    *****************************************************************/
    public Principal getLoggined() throws Exception {
        Authentication auth = new UsernamePasswordAuthenticationToken("admin", "admin");
        SecurityContext securityContext = SecurityContextHolder.getContext();
        securityContext.setAuthentication(auth);
        securityContext.getAuthentication().getPrincipal();
        
        return auth;
    }
}
