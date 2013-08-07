<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator" prefix="decorator"%>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/page" prefix="page"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
<title>
	<decorator:title default="..." />
</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">
<link  rel="stylesheet" type="text/css"  href="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/bootstrap/3.0.0/bootstrap.css" />
<link  rel="stylesheet" type="text/css"  href="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/kendo/kendo.common.min.css" />
<link  rel="stylesheet" type="text/css"  href="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/kendo/kendo.metro.min.css" />
<link  rel="stylesheet" type="text/css"  href="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/common/common.ui.css" />

<script src="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/yepnope/1.5.4/yepnope.min.js"></script>
<decorator:head />
<style>

	.k-splitter {
		border: 0px;
	}		
	
	@media only screen and (min-width: 768px) {
		body{
			font-size: 11pt;
		}		
		#splitter {				
			height : 650px;
		}	
	}	
		
	@media only screen and (min-width: 1280px) {
		body{
			font-size: 12pt;
		}
		#splitter {				
			height : 740px;
		}			
	}
	
	@media only screen and (min-width: 1440px) {
		body{
			font-size: 12pt;
		}		
		#splitter {				
			height : 900px;
		}			
	}
	
	
	#list_pane {
		background-color : #cccccc;
	}	
		
	#datail_pane {
		background-color : #FFFFFF;
	}
	
	.k-menu.k-header, .k-menu .k-item {
		border-color :#dadada;
	}
			
	.container {
		max-width:100% ;
		overflow-x:hidden ;
		overflow-y:hidden ;
	}
	
</style>
</head>
<body onload="<decorator:getProperty property="body.onload" />" class="<decorator:getProperty property="body.class" />">
	<decorator:body />
</body>
</html>