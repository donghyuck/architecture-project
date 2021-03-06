<#ftl encoding="UTF-8"/>
<html decorator="secure-metro">
	<head>
		<title>시스템 정보</title>
		<script type="text/javascript"> 
		yepnope([{
			load: [ 
			'css!${request.contextPath}/styles/font-awesome/4.0.3/font-awesome.min.css',
			'${request.contextPath}/js/jquery/1.10.2/jquery.min.js',
			'${request.contextPath}/js/bootstrap/3.0.3/bootstrap.min.js',
			'${request.contextPath}/js/jgrowl/jquery.jgrowl.min.js',
			'${request.contextPath}/js/kendo/kendo.web.min.js',
			'${request.contextPath}/js/kendo/kendo.ko_KR.js',       	   
			'${request.contextPath}/js/kendo/cultures/kendo.culture.ko-KR.min.js', 
			'${request.contextPath}/js/common/common.models.js',
			'${request.contextPath}/js/common/common.api.js',
			'${request.contextPath}/js/common/common.ui.js'],        	   
			complete: function() {               
				
				// 1.  한글 지원을 위한 로케일 설정
				kendo.culture("ko-KR");
										
				// 2. ACCOUNTS LOAD		
				var currentUser = new User({});
				var accounts = $("#account-panel").kendoAccounts({
					visible : false,
					authenticate : function( e ){
						currentUser = e.token;						
					}
				});
				var selectedCompany = new Company();
				var selectedSocial = {};			
										
				// 3.MENU LOAD
				var currentPageName = "MENU_1_2";
				var topBar = $("#navbar").extTopBar({ 
					template : kendo.template($("#topbar-template").html() ),
					data : currentUser,
					menuName: "SYSTEM_MENU",
					items: {
						id:"companyDropDownList", 
						type: "dropDownList",
						dataTextField: "displayName",
						dataValueField: "companyId",
						value: ${action.companyId},
						enabled : false,
						dataSource: {
							transport: {
								read: {
									dataType: "json",
									url: '${request.contextPath}/secure/list-company.do?output=json',
									type:'POST'
								}
							},
							schema: { 
								data: "companies",
								model : Company
							}
						},
						change : function(data){
							selectedCompany = data ;
							kendo.bind($("#site-info"), selectedCompany );   
						}
					},
					doAfter : function(that){
						var menu = that.getMenuItem(currentPageName);
						kendo.bind($(".page-header"), menu );   
					}
				 });					 
				 
				 // 4. PAGE MAIN		
				$("button.btn-control-group ").each(function (index) {					
					var btn_control = $(this);
					var btn_control_action = btn_control.attr("data-action");
					if (btn_control_action == "user"){
						btn_control.click( function(e){			
							$("form[name='fm1'] input").val(selectedCompany.companyId);		
							$("form[name='fm1']").attr("action", "main-user.do" ).submit(); 
						} );						
					}else if (btn_control_action == "layout"){
						btn_control.click(function (e) {										
							$(".body-group").each(function( index ) {
								var panel_body = $(this);
								var is_detail_body = false;
								if (panel_body.attr("id") == "group-details"){
									is_detail_body = true;
								}else{
									is_detail_body = false;
								}								
								if( panel_body.hasClass("col-sm-6" )){
									panel_body.removeClass("col-sm-6");
									panel_body.addClass("col-sm-12");	
									if( is_detail_body ){
										panel_body.css('padding', '5px 0 0 0');
									}													
								}else{
									panel_body.removeClass("col-sm-12");
									panel_body.addClass("col-sm-6");		
									if( is_detail_body ){
										panel_body.css('padding', '0 0 0 5px');
									}				
								}
							});
						});
					}	
				});	
								 			 								
				$('#myTab a').click(function (e) {
					e.preventDefault();
					if(  $(this).attr('href') == '#site-info' ){
					
					}else if(  $(this).attr('href') == '#template-mgmt' ){
						if( ! $("#template-grid").data("kendoGrid") ){	
							$("#template-grid").kendoGrid({
								dataSource: {
									dataType: 'json',
									transport: {
										read: { url:'${request.contextPath}/secure/list-template.do?output=json', type: 'POST' },
										parameterMap: function (options, operation){
											if (operation != "read" && options) {										                        								                       	 	
												return { objectType: 1, objectId : selectedCompany.companyId , item: kendo.stringify(options)};									                            	
											}else{
												return { startIndex: options.skip, pageSize: options.pageSize, objectType: 1, objectId: selectedCompany.companyId }
											}
										} 
									},
									schema: {
										total: "totalTargetTemplateCount",
										data: "targetTemplates",
										model : Template
									},
									pageSize: 15,
									serverPaging: true,
									serverFiltering: false,
									serverSorting: false,                        
									error: handleKendoAjaxError
								},
								toolbar: [ { text: "템플릿 파일 추가", css:"createTemplateCustom" } ],   
								columns:[
									{ field: "templateId", title: "ID",  width: 50, filterable: false, sortable: false },
									{ field: "title", title: "타이틀", width: 150 },
									{ field: "location", title: "템플릿 이름", width: 150 },
									{ field: "templateType", title: "유형",  width: 100 },
									{ field: "modifiedDate", title: "수정일", width: 80, format: "{0:yyyy/MM/dd}" },
									{ command: [ { name: "destroy", text: "삭제" } , { name: "customEditTemplateClass", text: "수정" }], title: " ", width: "160px"  }
								],
								filterable: true,
								sortable: true,
								pageable: { refresh:true, pageSizes:false,  messages: { display: ' {1} / {2}' }  },
								//selectable: 'row',
								dataBound: function(e) {
								
								},
								change: function(e) {          
									var selectedCells = this.select();       
									this.expandRow(selectedCells);
								}
							});
						}					
					}else if(  $(this).attr('href') == '#image-mgmt' ){
						// IMAGE MGMT
						if( ! $("#image-upload").data("kendoUpload") ){	
							$("#image-upload").kendoUpload({
								multiple : false,
								showFileList : true,
								localization : { 
									select: '이미지 업로드', remove:'삭제', dropFilesHere : '업로드할 이미지 파일을 이곳에 끌어 놓으세요.' , 
									uploadSelectedFiles : '이미지 업로드',
									cancel: '취소' 
								},
								async: {
									saveUrl:  '${request.contextPath}/secure/update-image.do?output=json',							   
									autoUpload: true
								},
								upload:  function (e) {		
									e.data = { objectType: 1, objectId : selectedCompany.companyId, imageId:'-1' };		
								},
								success : function(e) {	
									$('#image-grid').data('kendoGrid').dataSource.read(); 
								}
							}).css('min-width','300');
						}				
						
						if( ! $("#image-grid").data("kendoGrid") ){	
							$("#image-grid").kendoGrid({
								dataSource: {
									dataType: 'json',
									transport: {
										read: { url:'${request.contextPath}/secure/list-image.do?output=json', type: 'POST' },
										parameterMap: function (options, operation){
											if (operation != "read" && options) {										                        								                       	 	
												return { objectType: 1, objectId : selectedCompany.companyId , item: kendo.stringify(options)};									                            	
											}else{
												return { startIndex: options.skip, pageSize: options.pageSize, objectType: 1, objectId: selectedCompany.companyId }
											}
										} 
									},
									schema: {
										total: "totalTargetImageCount",
										data: "targetImages",
										model : Image
									},
									pageSize: 15,
									serverPaging: true,
									serverFiltering: false,
									serverSorting: false,                        
									error: handleKendoAjaxError
								},
								columns:[
									{ field: "imageId", title: "ID",  width: 50, filterable: false, sortable: false },
									{ field: "name", title: "파일", width: 150 },
									{ field: "contentType", title: "이미지 유형",  width: 100 },
									{ field: "size", title: "파일크기",  width: 100 },
									{ field: "creationDate", title: "생성일", width: 80, format: "{0:yyyy/MM/dd}" },
									{ field: "modifiedDate", title: "수정일", width: 80, format: "{0:yyyy/MM/dd}" },
									{ command: [ { name: "destroy", text: "삭제" } ], title: " ", width: "160px"  }
								],
								filterable: true,
								sortable: true,
								pageable: { refresh:true, pageSizes:false,  messages: { display: ' {1} / {2}' }  },
								selectable: 'row',
								//height: 400,
								detailTemplate: kendo.template( $("#image-details-template").html() ),
								detailInit : function(e){
									//var detailRow = e.detailRow;
								},		
								dataBound: function(e) {
								
								},
								change: function(e) {          
									var selectedCells = this.select();       
									this.expandRow(selectedCells);
								}
							});
						}							
					}else if(  $(this).attr('href') == '#social-mgmt' ){ 
						if( ! $("#social-grid").data("kendoGrid") ){	
							$("#social-grid").kendoGrid({
								dataSource: {
									dataType: 'json',
									transport: {
										read: { url:'${request.contextPath}/secure/list-social-account.do?output=json', type: 'POST' },
										update: { url:'${request.contextPath}/secure/update-social-account.do?output=json', type:'POST' },
										parameterMap: function (options, operation){
											if (operation != "read" && options) {										                        								                       	 	
												return { objectType: 1, objectId : selectedCompany.companyId , item: kendo.stringify(options)};									                            	
											}else{
												return { startIndex: options.skip, pageSize: options.pageSize, objectType: 1, objectId: selectedCompany.companyId }
											}
										} 
									},
									schema: {
										data: "targetSocialAccounts",
										model : SocialAccount
									},
									pageSize: 15,
									serverPaging: false,
									serverFiltering: false,
									serverSorting: false,                        
									error: handleKendoAjaxError
								},
								toolbar: [ { text: "쇼셜 연결 추가", css:"createSocialCustom" } ],   
								columns:[
									{ field: "socialAccountId", title: "ID",  width: 50, filterable: false, sortable: false },
									{ field: "serviceProviderName", title: "쇼셜", width: 100 },
									{ field: "signedIn", title: "로그인",  width: 80 },
									{ field: "accessSecret", title: "Access Secret", sortable: false },
									{ field: "accessToken", title: "Access Token", sortable: false },
									{ field: "creationDate", title: "생성일", width: 100, format: "{0:yyyy/MM/dd}" },
									{ field: "modifiedDate", title: "수정일", width: 100, format: "{0:yyyy/MM/dd}" },
									{ command: [ {  text: "상세" , click: function(e){										
										e.preventDefault();										
										selectedSocial =  this.dataItem($(e.currentTarget).closest("tr"));											
										if(! $("#social-detail-window").data("kendoWindow")){       
											// WINDOW 생성
											$("#social-detail-window").kendoWindow({
												actions: ["Close"],
												resizable: false,
												modal: true,
												visible: false,
												minWidth: 300,
												minHeight: 300
											});
										}																				
										// load social template ...										
										var socialWindow = $("#social-detail-window").data("kendoWindow");
										var socialMediaName = selectedSocial.serviceProviderName ;										
										var template = kendo.template($('#social-details-template').html());											
										socialWindow.title( socialMediaName + ' 연결정보' );
										socialWindow.content(template({ 'socialAccount' : selectedSocial }));
										$.ajax({
											type : 'POST',
											url : '${request.contextPath}/social/get-' + socialMediaName + '-profile.do?output=json',
											data: { socialAccountId: selectedSocial.socialAccountId },
											beforeSend: function(){																					
												socialWindow.center();
												socialWindow.open();
												kendo.ui.progress($("#social-detail-window"), true);												
											},
											success : function(response){
												if( response.error ){
													// 오류 발생..
													socialWindow.content( template( { 'socialAccount' : selectedSocial, 'error': response.error } ) );
												} else {														
													socialWindow.content( template(response) );
												}										
												$('#connect-social-btn').click( function(e){
													socialWindow.close();													
													var w = window.open(
														selectedSocial.authorizationUrl, 
														"_blank",
														"toolbar=yes, location=yes, directories=no, status=no, menubar=yes, scrollbars=yes, resizable=no, copyhistory=yes, width=500, height=400"
													);
													w.focus();
												});		
											},
											error: function(){
												socialWindow.close();
												handleKendoAjaxError();
											},
											dataType : 'json'
										});	
										
									}}, { name: "destroy", text: "삭제" } ], title: " ", width: "230px"  }
								],
								filterable: true,
								editable: "inline",
								sortable: true,
								pageable: { refresh:true, pageSizes:false,  messages: { display: ' {1} / {2}' }  },
								//height: 500,
								dataBound: function(e) {								
								},
								change: function(e) {          
									var selectedCells = this.select();     
								}
							});
						}	
																
					}else if(  $(this).attr('href') == '#attachment-mgmt' ){ 					
						// IMAGE MGMT
						if( ! $("#attach-upload").data("kendoUpload") ){	
							$("#attach-upload").kendoUpload({
								multiple : false,
								showFileList : true,
								localization : { 
									select: '첨부파일 업로드', remove:'삭제', dropFilesHere : '업로드할 첨부 파일을 이곳에 끌어 놓으세요.' , 
									uploadSelectedFiles : '이미지 업로드',
									cancel: '취소' 
								},
								async: {
									saveUrl:  '${request.contextPath}/secure/save-attachments.do?output=json',							   
									autoUpload: true
								},
								upload:  function (e) {		
									e.data = { objectType: 1, objectId : selectedCompany.companyId, attachmentId:'-1' };		
								},
								success : function(e) {	
									$('#image-grid').data('kendoGrid').dataSource.read(); 
								}
							}).css('min-width','300');
						}				
						
						if( ! $("#attach-grid").data("kendoGrid") ){	
							$("#attach-grid").kendoGrid({
								dataSource: {
									type: 'json',
									transport: {
										read: { url:'${request.contextPath}/secure/get-attachements.do?output=json', type: 'POST' },
										parameterMap: function (options, operation){
											if (operation != "read" && options) {										                        								                       	 	
												return { objectType: 1, objectId : selectedCompany.companyId , item: kendo.stringify(options)};									                            	
											}else{
												return { startIndex: options.skip, pageSize: options.pageSize, objectType: 1, objectId: selectedCompany.companyId }
											}
										} 
									},
									schema: {
										total: "totalTargetAttachmentCount",
										data: "targetAttachments",
										model : Attachment
									},
									pageSize: 15,
									serverPaging: true,
									serverFiltering: false,
									serverSorting: false,                        
									error: handleKendoAjaxError
								},
								columns:[
									{ field: "attachmentId", title: "ID",  width: 50, filterable: false, sortable: false },
									{ field: "name", title: "파일", width: 150 },
									{ field: "contentType", title: "파일 유형",  width: 100 },
									{ field: "size", title: "파일크기",  width: 100 },
									{ field: "creationDate", title: "생성일", width: 80, format: "{0:yyyy/MM/dd}" },
									{ field: "modifiedDate", title: "수정일", width: 80, format: "{0:yyyy/MM/dd}" },
									{ command: [ { name: "destroy", text: "삭제" } ], title: " ", width: "160px"  }
								],
								filterable: true,
								sortable: true,
								pageable: { refresh:true, pageSizes:false,  messages: { display: ' {1} / {2}' }  },
								//selectable: 'row',
								//height: 500,
								detailTemplate: kendo.template( $("#attach-details-template").html() ),
								detailInit : function(e){
									//var detailRow = e.detailRow;
								},		
								dataBound: function(e) {
								
								},
								change: function(e) {          
									var selectedCells = this.select();       
									this.expandRow(selectedCells);
								}
							});
						}	
											
					}
					$(this).tab('show');
				});
			}	
		}]);
		</script>
		<style>					
		.k-grid-content{
			height:400px;
		}			
		</style>
	</head>
	<body>
		<!-- START HEADER -->
		<section id="navbar"></section>
		<!-- END HEADER -->
		<!-- START MAIN CONTNET -->
		
		<div class="container full-width-container">		
			<div class="row">			
				<div class="page-header">
					<h1><span data-bind="text: title"></span>     <small><i class="fa fa-quote-left"></i>&nbsp;<span data-bind="text: description"></span>&nbsp;<i class="fa fa-quote-right"></i></small></h1>
				</div>			
			</row>	
			<div class="row full-width-row">	
				<div class="col-lg-12">
					<div class="panel panel-default" style="min-height:300px;">
						<div class="panel-heading" style="padding:5px;">
							<div class="btn-group">
								<button type="button" class="btn btn-info btn-control-group" data-action="menu"><i class="fa fa-sitemap"></i> 메뉴</button>
							</div>
							<div class="btn-group">
								<button type="button" class="btn btn-success btn-control-group" data-action="group"><i class="fa fa-users"></i> 그룹관리</button>
								<button type="button" class="btn btn-success btn-control-group" data-action="user"><i class="fa fa-user"></i> 사용자관리</button>
							</div>
							<button type="button" class="btn btn-default btn-control-group btn-columns-expend" data-action="layout"><i class="fa fa-columns"></i></button>					
						</div>
						<div class="panel-body" style="padding:5px;">					
							<ul class="nav nav-tabs" id="myTab">
							  <li class="active"><a href="#site-info"><i class="fa fa-sitemap"></i> 사이트 정보</a></li>
							  <li><a href="#template-mgmt"><i class="fa fa-file-o"></i>	페이지 템플릿 관리</a></li>
							  <li><a href="#image-mgmt"><i class="fa fa-picture-o"></i> 이미지 관리</a></li>
							  <li><a href="#attachment-mgmt"><i class="fa fa-paperclip"></i> 첨부파일 관리</a></li>
							  <li><a href="#social-mgmt">쇼셜 관리</a></li>
							  <li><a href="#rss-info"><i class="fa fa-rss"></i> RSS 관리</a></li>
							</ul>
							<div class="tab-content">
								<div class="blank-top-5" ></div>	
								<div class="tab-pane active" id="site-info">
										<table class="table table-hover">
										<tbody>						
											<tr>
												<th>사이트</th>								
												<td><span data-bind="text: displayName"></span></td>
											</tr>	
											<tr>
												<th>도메인</th>								
												<td><span data-bind="text: domainName"></span></td>
											</tr>										
											<tr>
												<th>등록 아이디</th>
												<td><span class="label label-info"><span data-bind="text: name"></span></span><code><span data-bind="text: companyId"></span></code></td>
											</tr>			
											<tr>
												<th>등록 이름</th>
												<td><span data-bind="text: description"></span></td>
											</tr>	
											<tr>
												<th>등록일</th>
												<td><span data-bind="text: creationDate"></span></td>
											</tr>				
											<tr>
												<th>마지막 정보 수정일</th>
												<td><span data-bind="text: modifiedDate"></span></td>
											</tr>												
									 	</tbody>
										</table>
								</div>
								<div class="tab-pane" id="template-mgmt">
									<div id="template-grid" ></div>
								</div>
								<div class="tab-pane" id="system-info">
								</div>
								<div class="tab-pane" id="image-mgmt">
									<input name="image-upload" id="image-upload" type="file" />
									<div id="image-grid"></div>	
								</div>								
								<div class="tab-pane" id="attachment-mgmt">
									<input name="attach-upload" id="attach-upload" type="file" />
									<div id="attach-grid"></div>
								</div>
								<div class="tab-pane" id="social-mgmt">
									<div id="social-grid"></div>
								</div>								
							</div>
						</div>
					</div>	
				</div>
			</div>
		</div>				
		<div id="account-panel" ></div>
  
	<!-- Modal -->
	<div id="social-detail-window" style="display:none;">		
	</div>
	<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
						<h4 class="modal-title">Modal title</h4>
				</div>
				<div class="modal-body">
				...
				</div>
			<div class="modal-footer">
			<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
			<button type="button" class="btn btn-primary">Save changes</button>
		</div>
      </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
  </div><!-- /.modal -->
  		
		<!-- END MAIN CONTNET -->
		<!-- START FOOTER -->
		<footer>  		
		</footer>
		<!-- END FOOTER -->

		<script id="social-details-template" type="text/x-kendo-template">				
				#if ( typeof (twitterProfile)  == "object" ){ #
				<div class="media">
					<a class="pull-left" href="\\#"><img class="media-object" src="#=twitterProfile.profileImageUrl#" alt="프로파일 이미지" class="img-rounded"></a>
					<div class="media-body">
						<h4 class="media-heading">#=twitterProfile.screenName# (#=twitterProfile.name#)</h4>
						#=twitterProfile.description#</br>
						</br>
						트위터 URL : #=twitterProfile.profileUrl#</br>
						표준시간대: #=twitterProfile.timeZone#</br>	
						웹 사이트: #=twitterProfile.url#</br>	
						언어: #=twitterProfile.language#</br>	
						위치: #=twitterProfile.location#</br>	
					</div>			
				</div>
				</br>
				<ul class="list-group">
					<li class="list-group-item">
					<span class="badge">#=twitterProfile.statusesCount#</span>
					트윗
					</li>
					<li class="list-group-item">
					<span class="badge">#=twitterProfile.friendsCount#</span>
					팔로잉
					</li>
					<li class="list-group-item">
					<span class="badge">#=twitterProfile.followersCount#</span>
					팔로워
					</li>		
				</ul>			
				# } else if ( typeof (facebookProfile)  == "object" ) { #
				<div class="media">
					<a class="pull-left" href="\\#"><img class="media-object" src="http://graph.facebook.com/#=facebookProfile.id#/picture" alt="프로파일 이미지" class="img-rounded"></a>
					<div class="media-body">
						<h4 class="media-heading">#=facebookProfile.name# (#=facebookProfile.firstName#, #=facebookProfile.lastName#)</h4>
						</br>
						URL : #=facebookProfile.link#</br>
						로케일 : #=facebookProfile.locale#</br>
						위치 : #=facebookProfile.location.name#</br>
					</div>		
				</div>
								
				# } else if ( typeof (error)  == "object" ) { #
				<div class="alert alert-danger">
					#=socialAccount.serviceProviderName# 쇼셜계정에 접근할 수 없습니다. <BR/>
					연결하기 버튼을 클릭하여	<BR/>
					다시 연결하여 주십시오.	<BR/>					
					<img src="${request.contextPath}/images/common/twitter-bird-dark-bgs.png" alt="Twitter Logo" class="img-rounded">					
				</div>
				<input id="connect-social-id" type="hidden" value="#=socialAccount.socialAccountId #" />
				<div style="margin-top:-50px;">
				<button id="connect-social-btn" type="button" class="btn btn-primary btn-block">#=socialAccount.serviceProviderName#  연결하기</button>
				</div>
				# } else { #	
					# if ( socialAccount.serviceProviderName == "facebook" ) { #
					<img src="${request.contextPath}/images/common/FB-f-Logo__blue_512.png" alt="Facebook Logo" class="img-rounded">	
					# } else{ #
					<img src="${request.contextPath}/images/common/twitter-bird-light-bgs.png" alt="Twitter Logo" class="img-rounded">	
					# } #	
				# } #					
		</script>		

		<#include "/html/common/common-templates.ftl" >		
	</body>
</html>