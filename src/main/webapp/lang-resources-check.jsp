<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.smartcalendar.utils.DatabaseUtil" %>
<%
response.setHeader("Cache-Control", "no-store");
String[] langs = {"ar","zh","fr"};
try(Connection conn = DatabaseUtil.getConnection()){
    out.println("language_resources counts:");
    for(String l: langs){
        try(PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM language_resources WHERE language_code = ?")){
            ps.setString(1,l);
            try(ResultSet rs = ps.executeQuery()){
                rs.next();
                out.println(l+":"+rs.getInt(1));
            }
        }
    }
    out.println("sample keys:");
    try(PreparedStatement ps = conn.prepareStatement("SELECT language_code, resource_key FROM language_resources WHERE resource_key IN ('app.title','event.save','admin.face.add') ORDER BY language_code, resource_key")){
        try(ResultSet rs = ps.executeQuery()){
            while(rs.next()){ out.println(rs.getString(1)+"|"+rs.getString(2)); }
        }
    }
} catch(Exception e){ out.println("ERROR:"+e.getMessage()); }
%>