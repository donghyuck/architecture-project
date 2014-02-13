<%@ page pageEncoding="UTF-8"%>
<%@ page import="architecture.common.user.*"%>
<html decorator="homepage">
<head>
<title>로그인</title>
<%
	User user = SecurityHelper.getUser();
	Company company = user.getCompany();
%>
<script type="text/javascript">
	yepnope([{
		load: [ 
			'css!<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/font-awesome/4.0.3/font-awesome.min.css',
			'css!<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/codedrop/fullscreenOverlay.css',
			'css!<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/common/common.ui.modaleffects.css',			
			'css!<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/styles/common/common.ui.animatedcheckbox.css',			
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/jquery/1.9.1/jquery.min.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/jgrowl/jquery.jgrowl.min.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/kendo/kendo.web.min.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/kendo/kendo.ko_KR.js',			
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/bootstrap/3.0.3/bootstrap.min.js',	
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/common/common.cbpBGSlideshow.min.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/jquery.imagesloaded/imagesloaded.min.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/common/common.modernizr.custom.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/common/common.api.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/common/common.models.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/common/common.ui.svgcheckbox.js',
			'<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/js/common/common.ui.js'],
		complete: function() {        	              		              		  

			cbpBGSlideshow.init();
			$("#login").click( function() {           		    	
				doLogin();
			});
			
			$('#login-window').modal({show:true, backdrop:false});
			
			$('#login-window').on('hidden.bs.modal', function () {
				//$("form[name='fm1']")[0].reset();               	   
				//$("form[name='fm1']").attr("action", "/main.do").submit();
			});
			
			
			$("#password").keypress(function(event){
				var keycode = (event.keyCode ? event.keyCode : event.which);
				if(keycode == '13'){
					doLogin();
				}				
			});
						
			$("#login-window .custom-external-login-groups button").each(function( index ) {
				var external_login_button = $(this);
				external_login_button.click(function (e){																												
					var target_media = external_login_button.attr("data-target");
					$.ajax({
						type : 'POST',
						url : "<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/community/get-socialnetwork.do?output=json",
						data: { media: target_media },
						success : function(response){
							if( response.error ){
								// 연결실패.
							} else {	
								window.open( response.authorizationUrl + '&display=popup' ,'popUpWindow','height=500,width=600,left=10,top=10,resizable=yes,scrollbars=yes,toolbar=yes,menubar=no,location=no,directories=no,status=yes')
							}
						},
						error:handleKendoAjaxError												
					});	
				});								
			});
			
			
			// fullscreen overlay !!
			$( 'button.overlay-close' ).click( function(e){ 				
				toggleOverlay();
			} );			
		}		
	}]);
	
	function handleCallbackResult( media, code, exists ){		
		if(exists){
			if( code != null && code != ''  ){						
				var onetime_url =  "<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/community/" + media + "-callback.do?output=json";			
				common.api.signin({
					url : onetime_url,
					onetime:  code,
					success : function(response){
						$("form[name='fm1']").attr("action", "/main.do").submit();
					}
				}); 
			}else{
				alert( media +  "인증에 실패하였습니다." );
			}
		}else{
			if( code != null && code != ''  ){			
				$('#login-window').modal('hide')
				toggleOverlay();
			}else{
				$("form[name='fm1']")[0].reset();               	                            
				$("form[name='fm1']").attr("action", "signup.do").submit();			
			}
		}
	}
	
	function toggleOverlay(){
		
		var overlay = $('.overlay');
				
		if( overlay.hasClass("open") ){
			overlay.removeClass("open");
			overlay.addClass("close");	
			overlay.bind('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(ev){
				overlay.removeClass("close");
				$('#login-window').modal('show')
			});
		}
		else if ( !overlay.hasClass("close") ){
			overlay.addClass("open");	
		}
	}
	
	function doLogin(){
		var templateContent = $("#alert-template").html();
		var template = kendo.template(templateContent);	              
		var validator = $("#login-window").kendoValidator().data("kendoValidator");     
		$("#status").html("");
		if( validator.validate() ){        				
			$.ajax({
				type: "POST",
				url: "/login",
				dataType: 'json',
				data: $("form[name=fm1]").serialize(),
				success : function( response ) {   
					if( response.error ){ 
						$("#status").html(  template({ message: "입력한 사용자 이름 또는 비밀번호가 잘못되었습니다." })  );
						$("#login").kendoAnimate("slideIn:up");          
						$("#password").val("").focus();
					} else {
						$("form[name='fm1']")[0].reset();               	                            
						$("form[name='fm1']").attr("action", "/main.do").submit();
					}                                 
				},
				error: function( xhr, ajaxOptions, thrownError){         				        
					$("form[name='fm1']")[0].reset();                    
					var status = $(".status");
					status.text(  "잘못된 접근입니다."  ).addClass("error") ;    
					$("#login").kendoAnimate("slideIn:up");
				}
			});
		}else{        			      
			//$("#login").kendoAnimate("slideIn:up"); 
		}		
	}
</script>
<style scoped="scoped">
	#login-window .modal-dialog {
		width : 550px;
	}

	/* Effects */
	.overlay-scale {
		visibility: hidden;
		opacity: 0;
		-webkit-transform: scale(0.9);
		transform: scale(0.9);
		-webkit-transition: -webkit-transform 0.2s, opacity 0.2s, visibility 0s 0.2s;
		transition: transform 0.2s, opacity 0.2s, visibility 0s 0.2s;
	}
	
	.overlay-scale.open {
		visibility: visible;
		opacity: 1;
		-webkit-transform: scale(1);
		transform: scale(1);	
		-webkit-transition: -webkit-transform 0.4s, opacity 0.4s;
		transition: transform 0.4s, opacity 0.4s;
	}
	
	#signup-modal.modal  {
		display: block;
	}
	
</style>
</head>
<body class="color1">
	<!-- Main Page Content  -->

		<div class="main">
				<ul id="cbp-bislideshow" class="cbp-bislideshow">
					<li><img src="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/community/download-image.do?imageId=175" alt="image01"/></li>
					<li><img src="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/community/download-image.do?imageId=808" alt="image02"/></li>
					<li><img src="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/community/download-image.do?imageId=810" alt="image03"/></li>
				</ul>
				<!-- 
				<div id="cbp-bicontrols" class="cbp-bicontrols">
					<span class="fa cbp-biprev"></span>
					<span class="fa cbp-bipause"></span>
					<span class="fa cbp-binext"></span>
				</div>
				 -->
			</div>
	
	
	<!-- Modal -->
	<div class="modal fade" id="login-window" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<!-- <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>-->
					<h4 class="modal-title">로그인</h4>
				</div>
			<div class="modal-body">
				<div class="container custom-external-login-groups" style="width:100%;">
					<div class="row blank-top-5 ">
						<div class="col-sm-6">
							<button class="btn btn-block btn-primary btn-lg "  data-target="facebook"><i class="fa fa-facebook"></i> | 페이스북으로 로그인</button>
						</div>
						<div class="col-sm-6">
							<button class="btn btn-block btn-info btn-lg " data-target="twitter"><i class="fa fa-twitter"></i> | 트위터로 로그인</button>
						</div>
					</div>							
				</div>
				<div class="container" style="width:100%;">					
					<div class="row blank-top-15">
						<div class="col-lg-12">
							<form name="fm1" class="form-horizontal" role="form" method="POST" accept-charset="utf-8">
								<input type="hidden" id="output" name="output" value="json" />		    
								<div class="form-group">
									<label for="username" class="col-lg-3 control-label">아이디</label>
									<div class="col-lg-9">
										<input type="text" class="form-control"  id="username" name="username"  pattern="[^0-9][A-Za-z]{2,20}" placeholder="아이디" required validationMessage="아이디를 입력하여 주세요.">
									</div>
								</div>
								<div class="form-group">
									<label for="password" class="col-lg-3 control-label">비밀번호</label>
									<div class="col-lg-9">
										<input type="password" class="form-control" id="password" name="password"  placeholder="비밀번호" required validationMessage="비밀번호를 입력하여 주세요." >
									</div>
								</div>
								<div class="form-group">
									<div class="col-lg-offset-3 col-lg-9">
										<div class="checkbox">
											<label>
												<input type="checkbox">로그인 상태유지  
											</label>
										</div>
									</div>
								</div>
								<div class="col-lg-12">
									<div id="status">
									<span class="label label-primary">접속 IP</span>&nbsp;<%= request.getRemoteAddr() %><br/>
									<% if ( !user.isAnonymous() ) { %>
									<span class="label label-warning"><%= user.getUsername() %> 로그인됨</span>&nbsp; <button type="button" class="btn btn-danger btn-sm">로그아웃</button><br/>
									<% } %>									
									</div>
								</div>
							</form>						
						</div>
						<div class="col-lg-12"></div>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				<div class="btn-group ">
					<button type="button" class="btn btn-info" >아이디/비밀번호찾기</button>
					<a id="signup"  href="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/accounts/signup.do"  class="btn btn-info">회원가입</a>
				</div>
					<button id="login" type="button" class="btn btn-info">로그인</button>
				</div>
			</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /.modal -->

	<div class="overlay overlay-scale">
		<button type="button" class="overlay-close">Close</button>
		
		<div id="signup-modal" class="modal">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<div class="modal-header">
						<h4 class="modal-title">회원가입</h4>
					</div>
					<div class="modal-body" style="background-color: #428bca;">
						<form class="ac-custom ac-radio ac-fill">
							<p class="bg-primary">
							연결되어 있지 않은 회원입니다. 회원가입을 위해서 서비스 <a href="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/content.do?contentId=1" target="_blank" class="btn btn-info">이용약관</a> 과  
							<a href="<%= architecture.ee.web.util.ServletUtils.getContextPath(request) %>/content.do?contentId=2"  target="_blank" class="btn btn-info"> 개인정보 취급방침</a> 에 동의해 주세요.
							</p>
							<ul>
								<li><input id="r1" name="r1" type="radio"><label for="r1" >네, 모두 동의합니다.</label></li>
							</ul>
						</form>
						<form name="fm2" class="form-horizontal" role="form" method="POST" accept-charset="utf-8">	
							<div class="form-group">
									<label for="input-email" class="col-lg-3 control-label">메일</label>
									<div class="col-lg-9">
										<input type="text" class="form-control"  id="input-email" name="input-email" placeholder="메일">
									</div>
							</div>						
						</form>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
						<button type="button" class="btn btn-primary">Save changes</button>
					</div>
				</div><!-- /.modal-content -->
			</div><!-- /.modal-dialog -->
		</div><!-- /.modal -->
		
	</div>
		
	<script type="text/x-kendo-template" id="alert-template">
	<div class="alert alert-danger">
		<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
          #=message#
    </div>
    </script>
    
	<STYLE type="text/css">	    

                span.k-tooltip {
                     margin-top: 3px;
                     margin-left: 0px;
                     -moz-border-radius: 15px;
					 border-radius: 15px;
					vertical-align:middle ;
                }
                
				html .k-textbox
				{
				    -moz-box-sizing: border-box;
				    -webkit-box-sizing: border-box;
				    box-sizing: border-box;
				    height: 2.12em;
				    line-height: 2.12em;
				    padding: 2px .3em;
				    text-indent: 0;
				    width: 230px;
				}
		.k-widget.k-tooltip-validation {
			background-color: transparent ;
			color: #a94442;
			border-width: 0;
		}
		
		.k-tooltip {
			-webkit-box-shadow : 0 0 0 0 ;
			box-shadow : 0 0 0 0;
		}
		
						
	</STYLE>
	<!-- End Main Content and Sidebar -->
	<!-- Start Breadcrumbs -->	    
	<!-- End Breadcrumbs -->	    	
</body>
</html>