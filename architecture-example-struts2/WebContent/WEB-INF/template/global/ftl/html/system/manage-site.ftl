<#ftl encoding="UTF-8"/>
<html decorator="secure-metro">
    <head>
        <title>시스템 정보</title>
        <script type="text/javascript">                
        
        yepnope([{
            load: [ 
			'${request.contextPath}/js/jquery/1.9.1/jquery.min.js',
			'${request.contextPath}/js/bootstrap/3.0.0/bootstrap.min.js',
       	    '${request.contextPath}/js/kendo/kendo.web.min.js',
       	    '${request.contextPath}/js/kendo/kendo.dataviz.min.js',
       	    '${request.contextPath}/js/kendo/kendo.ko_KR.js',       	   
       	    '${request.contextPath}/js/kendo/cultures/kendo.culture.ko-KR.min.js', 
       	    '${request.contextPath}/js/common/common.models.js',
       	    '${request.contextPath}/js/common/common.apis.js',
       	    '${request.contextPath}/js/common/common.ui.js'],        	   
            complete: function() {               
				
				// 1.  한글 지원을 위한 로케일 설정
				kendo.culture("ko-KR");
		
				// ACCOUNTS LOAD		
				var currentUser = new User({});
				var accounts = $("#account-panel").kendoAccounts({
					visible : false,
					authenticate : function( e ){
						currentUser = e.token;						
					}
				});
				
				
				var companyId = ${action.companyId};
				var selectedCompany = new Company();
				common.apis.getTargetCompany({
					data : {companyId: companyId},
					success : function ( token ){
						selectedCompany = token.targetCompany;
						 kendo.bind($("#company-info-panel"), selectedCompany );   
					}
				});
								
				$('#myTab a').click(function (e) {
					e.preventDefault();
					if(  $(this).attr('href') == '#setup-info' ){
					
					}else if(  $(this).attr('href') == '#image-mgmt' ){
						// IMAGE MGMT
						if( ! $("#image-upload").data("kendoUpload") ){	
							$("#image-upload").kendoUpload({
								multiple : false,
					                      			showFileList : true,
					                      			localization : { select: '이미지 파일 선택', remove:'삭제', dropFilesHere : '업로드할 이미지 파일을 이곳에 끌어 놓으세요.' , 
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
							});		
							
						}				
						
						if( ! $("#image-grid").data("kendoGrid") ){	
							$("#image-grid").kendoGrid({
								dataSource: {
									type: 'json',
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
									{ field: "name", title: "파일", template: '#=name#', width: 150 },
									{ field: "contentType", title: "이미지 유형",  width: 100 },
									{ field: "size", title: "파일크기",  width: 100 },
									{ field: "creationDate", title: "생성일", width: 80, format: "{0:yyyy/MM/dd}" },
									{ field: "modifiedDate", title: "수정일", width: 80, format: "{0:yyyy/MM/dd}" },
									{ command: [
										{ name: "destroy", text: "삭제" } ],  title: "&nbsp;", width: 160  }
									
								],
								filterable: true,
								sortable: true,
								pageable: { refresh:true, pageSizes:false,  messages: { display: ' {1} / {2}' }  },
								selectable: 'row',
								height: 300,
								dataBound: function(e) {
								},
								change: function(e) {                    
									 var selectedCells = this.select();       
									 if( selectedCells.length == 1){ 
										var selectedCell = this.dataItem( selectedCells ); 
										$('#image-preview').attr('src' , "${request.contextPath}/secure/view-image.do?imageId=" + selectedCell.imageId  );
										$('#image-preview').show();
									}
								}
							});
						}											
					}else if(  $(this).attr('href') == '#attachment-mgmt' ){
										
					}
					$(this).tab('show');
				});
			}	
		}]);
		</script>
		<style>						
		</style>
	</head>
	<body>
		<!-- START HEADER -->
		<!-- END HEADER -->
		<!-- START MAIN CONTNET -->
		<div class="container layout">
			<div class="row blank-top-5">			
				<div class="col-6 col-lg-6">						
					<div id="company-info-panel" class="panel panel-primary">
						<div class="panel-heading layout">
							<span data-bind="text: displayName"></span>
							&nbsp;&nbsp;&nbsp;
							<div class="btn-group">
								<button type="button" class="btn btn-sm btn-warning">옵션</button>
								<button type="button" class="btn btn-sm btn-warning dropdown-toggle" data-toggle="dropdown">
								    <span class="caret"></span>
								  </button>
								  <ul class="dropdown-menu" role="menu">
								    <li><a href="#">Action</a></li>
								    <li><a href="#">Another action</a></li>
								    <li><a href="#">Something else here</a></li>
								    <li class="divider"></li>
								    <li><a href="#">Separated link</a></li>
								  </ul>
							</div>							
						</div>
						<div class="panel-body">
							<table class="table table-hover">
											<tbody>						
												<tr>
													<th>등록 아이디</th>
													<td><span class="label label-info"><span data-bind="text: name"></span></span><em>(<span data-bind="text: description"></span>)</em></td>
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
					</div>
				</div>
			</div>				
			<div class="row">			
				<div class="col-12 col-lg-12">
					<ul class="nav nav-tabs" id="myTab">
					  <li class="active"><a href="#license-info">기본 설정 정보</a></li>
					  <li><a href="#setup-info">템플릿 관리</a></li>
					  <li><a href="#image-mgmt">이미지 관리</a></li>
					  <li><a href="#attachment-mgmt">첨부파일 관리</a></li>
					  <li><a href="#mgmt-info">쇼셜 관리</a></li>
					  <li><a href="#database-info">RSS 관리</a></li>
					</ul>
					<div class="tab-content">
						<div class="tab-pane active" id="license-info">
							<div class="blank-space-5">
										<table class="table table-striped .table-hover license-details">
											<tbody>
												<tr>
													<th>도메인</th>
													<td><span data-bind="text: licenseId"></span></td>
												</tr>								
												<tr>
													<th>로고</th>
													<td><span data-bind="text: name"></span></td>
												</tr>			
												<tr>
													<th>메뉴</th>
													<td><span data-bind="text: version.versionString"></span></td>
												</tr>				
												<tr>
													<th>테마</th>
													<td><span class="label label-info"><span data-bind="text: edition"></span></span></td>
												</tr>																
												<tr>
													<th>타입</th>
													<td><span class="label label-danger"><span data-bind="text: type"></span></span></td>
												</tr>																	
												<tr>
													<th>발급일</th>
													<td><span data-bind="text: creationDate"></span></td>
												</tr>	
												<tr>
													<th>발급대상</th>
													<td><span data-bind="text: client.company"></span>(<span data-bind="text: client.name"></span>)</td>
												</tr>	
										 	</tbody>
										</table>
							</div>
						</div>
						<div class="tab-pane" id="setup-info">
							<div class="big-box">
								<div class="panel">
									<div id="setup-props-grid" ></div>
								</div>
							</div>		
						</div>
						<div class="tab-pane" id="system-info">
							<div class="big-box">
								<div class="panel">
								
								</div>
							</div>	
						</div>
						<div class="tab-pane" id="image-mgmt">
							<div class="blank-space-5">
								<div class="row">
									<div class="col-lg-7">
										<input name="image-upload" id="image-upload" type="file" />
										<div id="image-grid"></div>
									</div>
									<div class="col-lg-5">
										<div class="panel panel-default">
											<div class="panel-heading">미리보기</div>
											<div class="panel-body">
											<img id="image-preview" src="..." class="img-thumbnail" style="display:none;">
											</div>
										</div>
									</div>									
								</div>								 
							</div>
						</div>								
						<div class="tab-pane" id="attachment-mgmt">
							<div class="big-box">
								<div class="panel">
								image attachment
								</div>
							</div>
						</div>
										
					</div>
				</div>
			</div>
		</div>				
		<div id="account-panel"></div>		
		<!-- END MAIN CONTNET -->
		<!-- START FOOTER -->
		<footer>  		
		</footer>
		<!-- END FOOTER -->
	</body>
</html>