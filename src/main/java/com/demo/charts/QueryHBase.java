package com.demo.charts;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.codehaus.jackson.map.ObjectMapper;
import java.util.LinkedHashMap;

/**
 * Servlet implementation class QueryHBase
 */
public class QueryHBase extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static ObjectMapper objectMapper = new ObjectMapper();
	private HBaseUtils hbUtil;

    public QueryHBase() {
        super();
        hbUtil = new HBaseUtils();
    }

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String tName, cfName, cName;
		tName = request.getParameter("tName");
		cfName = request.getParameter("cfName");
		cName = request.getParameter("cName");
		
		PrintWriter resWriter = response.getWriter();
		
		if (tName == null || cfName == null || cName == null) {
			resWriter.println("Missing Request Parameters!");
			return;
		}
		
		LinkedHashMap<String, String> vals = new LinkedHashMap<String, String>();
		vals = hbUtil.scanTable(tName, cfName, cName);
		String resStr = "";

		try {
			resStr = objectMapper.writeValueAsString(vals);
		} catch (Exception e) {
			resWriter.println(e.toString());
			return;
		}

		response.setContentType("application/json");
		resWriter.print(resStr);
	}


	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}
