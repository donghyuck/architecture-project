<#ftl encoding="UTF-8"/>
<html decorator="homepage">
<head>
		<title><#if action.user.company ?? >${action.user.company.displayName }<#else>::</#if></title>
		<script type="text/javascript">
		<!--
		yepnope([{
			load: [
			'css!${request.contextPath}/styles/font-awesome/4.0.3/font-awesome.min.css',
			'${request.contextPath}/js/jquery/1.9.1/jquery.min.js',
			'${request.contextPath}/js/jgrowl/jquery.jgrowl.min.js',
			'${request.contextPath}/js/kendo/kendo.web.min.js',
			'${request.contextPath}/js/kendo/kendo.ko_KR.js',			
			'${request.contextPath}/js/kendo/cultures/kendo.culture.ko-KR.min.js',			
			'${request.contextPath}/js/bootstrap/3.0.0/bootstrap.min.js',
			'${request.contextPath}/js/bootstrap/3.0.0/tooltip.js',			
			'${request.contextPath}/js/common/holder.js',
			'${request.contextPath}/js/common/common.models.js',
			'${request.contextPath}/js/common/common.ui.js'],
			complete: function() {
			
				// 1.  한글 지원을 위한 로케일 설정
				kendo.culture("ko-KR");
				// START SCRIPT	
				$("#top-menu").kendoMenu();
				$("#top-menu").show();
				var currentUser = new User({});			
				// ACCOUNTS LOAD	
				var accounts = $("#account-panel").kendoAccounts({
					dropdown : false,
					authenticate : function( e ){
						currentUser = e.token;
						$("#account-panel").data("currentUser", currentUser );
					},
					<#if CompanyUtils.isallowedSignIn(action.company) ||  !action.user.anonymous  || action.view! == "personalized" >
					template : kendo.template($("#account-template").html()),
					</#if>
					afterAuthenticate : function(){
						$('.dropdown-toggle').dropdown();
						if( currentUser.anonymous ){
							var validator = $("#login-panel").kendoValidator({validateOnBlur:false}).data("kendoValidator");
							$("#login-btn").click(function() { 
								$("#login-status").html("");
								if( validator.validate() )
								{								
									accounts.login({
										data: $("form[name=login-form]").serialize(),
										success : function( response ) {
											var refererUrl = "/main.do";
											if( response.item.referer ){
												refererUrl = response.item.referer;
											}
											$("form[name='login-form']")[0].reset();    
											$("form[name='login-form']").attr("action", refererUrl ).submit();						
										},
										fail : function( response ) {  
											$("#login-password").val("").focus();												
											$("#login-status").kendoAlert({ 
												data : { message: "입력한 사용자 이름 또는 비밀번호가 잘못되었습니다." },
												close : function(){	
													$("#login-password").focus();										
												 }
											}); 										
										},		
										error : function( thrownError ) {
											$("form[name='login-form']")[0].reset();                    
											$("#login-status").kendoAlert({ data : { message: "잘못된 접근입니다." } }); 									
										}																
									});															
								}else{	}
							});	
						}
					}
				});	
				
				
				$("#announce-panel").data( "announcePlaceHolder", new Announce () );
				// 1. Announces 								
				$("#announce-grid").kendoGrid({
					dataSource : new kendo.data.DataSource({
						transport: {
							read: {
								type : 'POST',
								dataType : "json", 
								url : '${request.contextPath}/community/list-announce.do?output=json'
							},
							parameterMap: function(options, operation) {
								if (operation != "read" && options.models) {
									return {models: kendo.stringify(options.models)};
								}
							} 
						},
						pageSize: 10,
						error:handleKendoAjaxError,
					//	serverPaging: true,
						schema: {
							data : "targetAnnounces",
							model : Announce
						}
					}),
					sortable: true,
					//pageable: {
					//	refresh: true,
					//	buttonCount: 5
					//},
					height: 300,
					columns: [ 
						{field:"announceId", title: "ID", width: 50, attributes: { "class": "table-cell", style: "text-align: center " }} ,
						{field:"subject", title: "주제"}
					],
					selectable: "row",
					change: function(e) { 
						var selectedCells = this.select();
						if( selectedCells.length > 0){
							var selectedCell = this.dataItem( selectedCells );	    							
							var announcePlaceHolder = $("#announce-panel").data( "announcePlaceHolder" );
							announcePlaceHolder.announceId = selectedCell.announceId;
							announcePlaceHolder.subject = selectedCell.subject;
							announcePlaceHolder.body = selectedCell.body;
							announcePlaceHolder.startDate = selectedCell.startDate ;
							announcePlaceHolder.endDate = selectedCell.endDate;
							announcePlaceHolder.modifiedDate = selectedCell.modifiedDate;
							announcePlaceHolder.creationDate = selectedCell.creationDate;
							announcePlaceHolder.user = selectedCell.user;							
							if( announcePlaceHolder.user.userId == $("#account-panel").data("currentUser").userId ){
								announcePlaceHolder.editable = true;
							}else{
								announcePlaceHolder.editable = false;
							}
							$("#announce-panel").data( "announcePlaceHolder", announcePlaceHolder );							 
							showAnnouncePanel();	
						}
					},
					dataBound: function(e) {					
						var selectedCells = this.select();
						this.select("tr:eq(1)");
					}
				});
				$("#announce-panel .panel-header-actions a").each(function( index ) {
						var panel_header_action = $(this);		
						panel_header_action.click(function (e) {
							e.preventDefault();
							if( panel_header_action.text() == "Minimize" ){
								$("#announce-panel .panel-body").toggleClass("hide");								
								var panel_header_action_icon = panel_header_action.find('span');
								if( panel_header_action_icon.hasClass("k-i-minimize") ){
									panel_header_action.find('span').removeClass("k-i-minimize");
									panel_header_action.find('span').addClass("k-i-maximize");
								}else{
									panel_header_action.find('span').removeClass("k-i-maximize");
									panel_header_action.find('span').addClass("k-i-minimize");
								}							
							}else if (panel_header_action.text() == "Close"){	
								$("#announce-panel" ).hide();
							}
						});
				});						
											
											
				// 4. Right Tabs
				$("#attach-view-panel").data( "attachPlaceHolder", new Attachment () );	
				$("#photo-view-panel").data( "photoPlaceHolder", new Image () );	

											
				$('#myTab a').click(function (e) {
					e.preventDefault();					
					if(  $(this).attr('href') == '#my-message-notes' ){						
					
					} else if(  $(this).attr('href') == '#my-streams-mgmt' ){
						
					} else if(  $(this).attr('href') == '#my-streams' ){					
						if( $("#social-view-panels").data( "providers") == null ){			
							$("#social-view-panels").data( "providers", new kendo.data.ObservableObject({}) );
							<#list action.companySocials as item >
								<#assign elementId = "'#" + item.serviceProviderName + "-streams'"  />					
								$("#social-view-panels").data( "providers").set( "${item.serviceProviderName}" ,  {
									<#if  item.serviceProviderName == "twitter" >
									template : kendo.template($("#twitter-timeline-template").html())	,			
									<#elseif item.serviceProviderName == "facebook" >
									template : kendo.template($("#facebook-homefeed-template").html()),
									</#if>		
									dataSource : new kendo.data.DataSource({
										transport: {
											read: {
												type : 'POST',
												type: "json",
												<#if  item.serviceProviderName == "twitter" >
												url : '${request.contextPath}/social/get-twitter-hometimeline.do?output=json',			
												<#elseif item.serviceProviderName == "facebook" >
												url : '${request.contextPath}/social/get-facebook-homefeed.do?output=json',
												</#if>	
											},
											parameterMap: function (options, operation){
												if (operation == "read" && options) {										                        								                       	 	
													return { socialAccountId: ${ item.socialAccountId } };									                            	
												}
											} 
										},
										requestStart: function() {
											kendo.ui.progress($(${elementId}), true);
										},
										requestEnd: function() {
											kendo.ui.progress($(${elementId}), false);
										},
										change: function() {
											$(${elementId}).html(kendo.render( $("#social-view-panels").data( "providers").get( "${item.serviceProviderName}" ).template, this.view()));
										},
										error:handleKendoAjaxError,
										schema: {
										<#if  item.serviceProviderName == "twitter" >
											data : "homeTimeline"
										<#elseif item.serviceProviderName == "facebook" >
											data : "homeFeed"
										</#if>	
										}						
									})
							});							
							</#list>
							$.each( $('#my-streams').find( '.social-connect-btn button' ) , function ( i, item ){					
								$(item).click( function(){ 
									var socialProvider = $(item).attr('data-provider');
									if( typeof (socialProvider) == 'string' ){
					 					showSocialPanel( socialProvider );	
					 				}
					 			});	
							});											
						}		
					} else if(  $(this).attr('href') == '#my-file-upload' ){
						if( !$('#attachment-files').data('kendoUpload') ){		
							$("#attachment-files").kendoUpload({
								 	multiple : false,
								 	width: 300,
								 	showFileList : false,
								    localization:{ select : '파일 선택' , dropFilesHere : '업로드할 파일을 이곳에 끌어 놓으세요.' },
								    async: {
										saveUrl:  '${request.contextPath}/community/save-my-attachments.do?output=json',							   
										autoUpload: true
								    },
								    upload: function (e) {								         
								    	 e.data = {};														    								    	 		    	 
								    },
								    success : function(e) {								    
										if( e.response.targetAttachment ){
											e.response.targetAttachment.attachmentId;
											// LIST VIEW REFRESH...
											$('#attachment-list-view').data('kendoListView').dataSource.read(); 
										}				
									}
							});						
						}
					} else if(  $(this).attr('href') == '#my-files' ){
						if( !$('#attachment-list-view').data('kendoListView') ){		
							var attachementTotalModle = kendo.observable({ 
								totalAttachCount : "0",
								totalImageCount : "0",
								totalFileCount : "0"							
							});
							kendo.bind($("#attachment-list-view-filter"), attachementTotalModle );						
							$("#attachment-list-view").kendoListView({
								dataSource: {
									type: 'json',
									transport: {
										read: { url:'${request.contextPath}/community/list-my-attachement.do?output=json', type: 'POST' },		
										destroy: { url:'${request.contextPath}/community/delete-my-attachment.do?output=json', type:'POST' },                                
										parameterMap: function (options, operation){
											if (operation != "read" && options) {										                        								                       	 	
												return { attachmentId :options.attachmentId };									                            	
											}else{
												return { };
											}
										}
									},
									pageSize: 12,
									error:handleKendoAjaxError,
									schema: {
										model: Attachment,
										data : "targetAttachments",
										total : "totalTargetAttachmentCount"
									},
									sort: { field: "attachmentId", dir: "desc" },
									filter :  { field: "contentType", operator: "neq", value: "" }
								},
								selectable: "single",									
								change: function(e) {									
									var data = this.dataSource.view() ;
									var item = data[this.select().index()];		
									$("#attach-view-panel").data( "attachPlaceHolder", item );														
									openPreviewWindow( ) ;	
								},
								navigatable: false,
								template: kendo.template($("#attachment-list-view-template").html()),								
								dataBound: function(e) {
									var attachment_list_view = $('#attachment-list-view').data('kendoListView');
									var filter =  attachment_list_view.dataSource.filter().filters[0].value;
									var totalCount = attachment_list_view.dataSource.total();
									if( filter == "image" ) 
									{
										attachementTotalModle.set("totalImageCount", totalCount);
									} else if ( filter == "application" ) {
										attachementTotalModle.set("totalFileCount", totalCount);
									} else {
										attachementTotalModle.set("totalAttachCount", totalCount);
									}
								}
							});														
							$("#attachment-list-view").on("mouseenter",  ".attach", function(e) {
									kendo.fx($(e.currentTarget).find(".attach-description")).expand("vertical").stop().play();
								}).on("mouseleave", ".attach", function(e) {
									kendo.fx($(e.currentTarget).find(".attach-description")).expand("vertical").stop().reverse();
							});								
							// ListView Filter 									
							$("ul#attachment-list-view-filter li").find("a").click(function(){					
								var attachment_list_view = $('#attachment-list-view').data('kendoListView');
								$("ul#attachment-list-view-filter li.active").removeClass("active");
								$(this).parent().addClass("active");
								var filter_id =  $(this).attr('id') ;
								switch(filter_id){
									case "attachment-list-view-filter-1" :
										attachment_list_view.dataSource.filter(  { field: "contentType", operator: "neq", value: "" } ) ; 
										break;
									case "attachment-list-view-filter-2":
										attachment_list_view.dataSource.filter( { field: "contentType", operator: "startswith", value: "image" }) ; 
										break;
									case "attachment-list-view-filter-3":
										attachment_list_view.dataSource.filter( { field: "contentType", operator: "startswith", value: "application" }) ; 
										break;											
								}
							});							
							// Attachment Pager
							$("#pager").kendoPager({
								refresh : true,
								buttonCount : 5,
								dataSource : $('#attachment-list-view').data('kendoListView').dataSource
							});			
						}
					} else if( $(this).attr('href') == '#my-photo-stream' ){							
						if( !$('#photo-list-view').data('kendoListView') ){
							$("#photo-list-view").kendoListView({
								dataSource: {
									type: 'json',
									transport: {
										read: { url:'${request.contextPath}/community/list-my-image.do?output=json', type: 'POST' }
									},
									pageSize: 12,
									error:handleKendoAjaxError,
									schema: {
										model: Image,
										data : "targetImages",
										total : "totalTargetImageCount"
									},
									sort: { field: "imageId", dir: "desc" }
								},
								selectable: "single",									
								change: function(e) {									
									var data = this.dataSource.view() ;
									var item = data[this.select().index()];									
									item.index = this.select().index();			
									item.page = $("#photo-list-pager").data("kendoPager").page();													
									$("#photo-view-panel").data( "photoPlaceHolder", item );														
									showPhotoPanel( ) ;										
								},
								navigatable: false,
								template: kendo.template($("#photo-list-view-template").html()),								
								dataBound: function(e) {
								}
							});														
							$("#photo-list-view").on("mouseenter",  ".attach", function(e) {
									kendo.fx($(e.currentTarget).find(".attach-description")).expand("vertical").stop().play();
								}).on("mouseleave", ".attach", function(e) {
									kendo.fx($(e.currentTarget).find(".attach-description")).expand("vertical").stop().reverse();
							});											
							// Pager							
							$("#photo-list-pager").kendoPager({
								refresh : true,
								buttonCount : 5,
								dataSource : $('#photo-list-view').data('kendoListView').dataSource
							});	
						}
					} else if( $(this).attr('href') == '#my-photo-upload' ){							
						// New Photo Upload			
						if( !$("#photo-files").data("kendoUpload")	){						
							$("#photo-files").kendoUpload({
								 	multiple : true,
								 	width: 300,
								 	showFileList : false,
								    localization:{ select : '사진 선택' , dropFilesHere : '업로드할 사진들을 이곳에 끌어 놓으세요.' },
								    async: {
										saveUrl:  '${request.contextPath}/community/update-my-image.do?output=json',							   
										autoUpload: true
								    },
								    upload: function (e) {				
								    	 e.data = {};							
								    },
								    success : function(e) {								    
										if( e.response.targetImage ){
											e.response.targetImage.imageId;
											// LIST VIEW REFRESH...
											$('#photo-list-view').data('kendoListView').dataSource.read();
										}				
									}
							});		
						}
					} 
					$(this).tab('show')
				});				
				// END SCRIPT 
			}
		}]);	

		/** Announce View Panel */		
		function editAnnouncePanel (){
			var announcePlaceHolder = $("#announce-panel").data( "announcePlaceHolder" );	
			if( announcePlaceHolder.editable ){		
						
				var observable = new kendo.data.ObservableObject(announcePlaceHolder);
				
				observable.bind("change", function(e) {				
					e.preventDefault();			
						alert("s");		
					//	$("#announce-view button[class*=custom-update]").removeAttr("disabled");
				});				

				//announcePlaceHolder.body = "" ;
				

				var template = kendo.template($('#announcement-edit-template').html());
				$("#announce-view").html( template(announcePlaceHolder) );	
				kendo.bind($("#announce-view"), announcePlaceHolder );					
				
				$("#announce-view div button").each(function( index ) {			
					var panel_button = $(this);			
					if( panel_button.hasClass( 'custom-update') ){
						panel_button.click(function (e) { 
							e.preventDefault();					
							var data = $("#announce-panel").data( "announcePlaceHolder" );	
							alert(  kendo.stringify( data ) );
							/*
							$.ajax({
									dataType : "json",
									type : 'POST',
									url : '${request.contextPath}/community/update-announce.do?output=json',
									data : { announceId: data.announceId, item: kendo.stringify( data ) },
									success : function( response ){		
										$('#announce-grid').data('kendoGrid').dataSource.read();	
									},
									error:handleKendoAjaxError
							});	
							*/
						} );
					}else if ( panel_button.hasClass('custom-delete') ){
						panel_button.click(function (e) { 
							e.preventDefault();
							if( confirm("삭제하시겠습니까 ?") ) {
							}
						} );
					}			
				} );							
			}
		}
		
		function showAnnouncePanel (){			
			var announcePlaceHolder = $("#announce-panel").data( "announcePlaceHolder" );						
			var template = kendo.template($('#announcement-view-template').html());
			$("#announce-view").html( template(announcePlaceHolder) );	
			kendo.bind($("#announce-view"), announcePlaceHolder );				
			if( announcePlaceHolder.editable ){
				$("#announce-view button[class*=custom-edit]").click( function (e){
					editAnnouncePanel();
				} );
			}
			$("#announce-panel" ).show();
		}	
								
		function showSocialPanel ( provider ){			
			var elementId =  provider + "-panel";			
			if( $("#" + elementId ).length == 0  ){						
				// create new social panel 
				var template = kendo.template($("#social-view-panel-template").html());				
				$("#social-view-panels").append( template( { provider:provider} ) );												
				// get dataSource
				var dataSource = $("#social-view-panels").data( "providers").get( provider ).dataSource;
				if( dataSource.total() == 0 )
				{
					dataSource.read();
				} 								
				$( '#'+ elementId + ' .panel-header-actions a').each(function( index ) {
					var social_header_action = $(this);
					social_header_action.click(function (e){
						e.preventDefault();		
						var social_header_action_icon = social_header_action.find('span');
						if (social_header_action.text() == "Minimize"){
							$( "#"+ elementId +" .panel-body").toggleClass("hide");				
							if( social_header_action_icon.hasClass("k-i-maximize") ){
								social_header_action_icon.removeClass("k-i-maximize");
								social_header_action_icon.addClass("k-i-minimize");
							}else{
								social_header_action_icon.removeClass("k-i-minimize");
								social_header_action_icon.addClass("k-i-maximize");
							}
						} else if (social_header_action.text() == "Refresh"){	
							socialServiceProviders[ provider ].dataSource.read();
						} else if (social_header_action.text() == "Close"){	
							$("#" + elementId ).hide();
						}
					});			
				} );			
			} else {
				$("#" + elementId ).show();
			} 
		}		
				
		/** Photo View Panel */
		function showPhotoPanel(){					
			if( !$("#photo-view-panel").data("extPanel") ){					
				$("#photo-view-panel").data("extPanel", 
					$("#photo-view-panel").extPanel({
						title : "포토",
						template : kendo.template($("#photo-panel-template").html())
					})
				 );						 
				$("#photo-view-panel").find(".custom-photo-delete").click(function (e) { 
					e.preventDefault();			
					$.ajax({
						dataType : "json",
						type : 'POST',
						url : '${request.contextPath}/community/delete-my-image.do?output=json',
						data : { imageId: $("#photo-view-panel").data( "photoPlaceHolder").imageId },
						success : function( response ){
							$('#photo-view-panel').hide();
						},
						error:handleKendoAjaxError
					});	
				});
				$("#update-photo-file").kendoUpload({
						multiple: false,
						async: {
							saveUrl:  '${request.contextPath}/community/update-my-image.do?output=json',
							autoUpload: true
						},
						localization:{ select : '사진 선택' , dropFilesHere : '새로운 사진파일을 이곳에 끌어 놓으세요.' },	
						upload: function (e) {				
							e.data = { imageId: $("#photo-view-panel").data( "photoPlaceHolder").imageId };
						},
						success: function (e) {				
							if( e.response.targetImage ){
								
								$('#photo-list-view').data('kendoListView').dataSource.read();
								
								var item = e.response.targetImage;
								item.index = $("#photo-view-panel").data( "photoPlaceHolder" ).index;			
								item.page = $("#photo-view-panel").data( "photoPlaceHolder" ).page				
								$("#photo-view-panel").data( "photoPlaceHolder",  item );
								showPhotoPanel();
							}
						} 
				});	
			}
			
			var photoPlaceHolder = $("#photo-view-panel").data( "photoPlaceHolder");		
			var panel = $("#photo-view-panel").data("extPanel");
			var editable = $("#account-panel").data("currentUser" ).userId == photoPlaceHolder.objectId ;
			
			panel.title( photoPlaceHolder.name ) ;
			panel.data().set("imageId", photoPlaceHolder.imageId );
			panel.data().set("editable", editable );
			
			var template = kendo.template($('#photo-view-template').html());
			$("#photo-view-panel").find(".panel-body").html( template(photoPlaceHolder) );

			$( '#photo-view-panel .pager li').each(function( index ) { 
				var panel_pager = $(this);				
				if( panel_pager.hasClass('previous') ){
					panel_pager.click(function (e) { 
						e.preventDefault();						
						var current_index = $("#photo-view-panel").data( "photoPlaceHolder").index;				
						var previous_index = current_index-1;	
						var listView =  $('#photo-list-view').data('kendoListView');	
						var list_view_pager = $("#photo-list-pager").data("kendoPager");
						var current_page = list_view_pager.page();						
						if( current_index > 0 ){							
							var item = listView.dataSource.view()[previous_index];
							item.index = previous_index;		
							item.page = current_page ;					
							$("#photo-view-panel").data( "photoPlaceHolder", item );														
							showPhotoPanel( );
						} else {
							if( current_page > 1 ){
								list_view_pager.page(current_page - 1);
								listView.select(listView.element.children().last());
							}
						}
					});
				}else if ( panel_pager.hasClass('next') ){ 
					panel_pager.click(function (e) { 
						e.preventDefault();
						var current_index = $("#photo-view-panel").data( "photoPlaceHolder").index;				
						var next_index = current_index + 1;				
						var listView =  $('#photo-list-view').data('kendoListView');
						var total_index = listView.dataSource.view().length -1 ;
						var list_view_pager = $("#photo-list-pager").data("kendoPager");
						var current_page = list_view_pager.page();												
						if( current_index < total_index  ){
							var item = listView.dataSource.view()[next_index];
							item.index = next_index;
							item.page = current_page ;							
							$("#photo-view-panel").data( "photoPlaceHolder", item );
							showPhotoPanel( );						
						}else {
							if( current_page <  list_view_pager.totalPages() ){
								list_view_pager.page(current_page+1);
								listView.select(listView.element.children().first());
							}
						}						
					});				
				}
			} );													
			panel.show();			
		}
		
		function openPreviewWindow(){	
		
			var attachPlaceHolder = $("#attach-view-panel").data( "attachPlaceHolder");
			var template = kendo.template($('#image-view-template').html());
			$('#attach-view-panel').html( template(attachPlaceHolder) );				
			kendo.bind($("#attach-view-panel"), attachPlaceHolder );		
			$("#attach-view-panel button").each(function( index ) {		
				var panel_button = $(this);
				panel_button.click(function (e) { 
					e.preventDefault();					
					if( panel_button.hasClass( 'custom-attachment-delete') ){
						$.ajax({
							dataType : "json",
							type : 'POST',
							url : '${request.contextPath}/community/delete-my-attachment.do?output=json',
							data : { attachmentId: attachPlaceHolder.attachmentId },
							success : function( response ){		
								$('#announce-panel').show();
								$('#attach-view-panel').hide();
							},
							error:handleKendoAjaxError
						});	
					}
					if( panel_button.hasClass( 'close') ){
						$("div .custom-panels-group").hide();
						//$('#announce-panel').show();						
					}					
				});
			});				
			$("#update-attach-file").kendoUpload({
				multiple: false,
				async: {
					saveUrl:  '${request.contextPath}/community/update-my-attachment.do?output=json',							   
					autoUpload: true
				},
				localization:{ select : '파일 변경하기' , dropFilesHere : '새로운 파일을 이곳에 끌어 놓으세요.' },	
				upload: function (e) {				
					e.data = { attachmentId: $("#attach-view-panel").data( "attachPlaceHolder").attachmentId };														    								    	 		    	 
				},
				success: function (e) {				
					if( e.response.targetAttachment ){
						 $("#attach-view-panel").data( "attachPlaceHolder",  e.response.targetAttachment  );
						kendo.bind($("#attach-view-panel"), e.response.targetAttachment );
					}
				} 
			});		
			
			$("div .custom-panels-group").hide();
			$('#attach-view-panel').show();			
		}	
				
		-->
		</script> 		   
		
		<style scoped="scoped">

		.k-dropzone {
		#	width: 808px;
		#	height: 219px;
			border: 5px dashed #c0dcf2;
			background: 0;
			text-align: center;
			padding: 34px 10px 10px;
			-webkit-border-radius: 18px;
			-moz-border-radius: 18px;
			border-radius: 18px;
			margin: 0 0 10px;
			position: relative;
			z-index: 2000;
		}
		
		.k-grid table tr.k-state-selected{
			background: #428bca;
			color: #ffffff; 
		}

		.media, .media .media {
			margin-top: 5px;
		}
	
		.popover {
			font-family: "나눔 고딕", "BM_NANUMGOTHIC";
			width: 90%;
			margin-top: 5px;
			margin-right: 20px;
			margin-bottom: 10px;
			margin-left: 20px;
			float: left;
			display: block;
			position: relative;
			z-index: 1;
			min-width: 200px;
			max-width: 500px;
			-webkit-box-shadow: none;
			box-shadow: none;
			background-clip: none;			
		 }
		  .popover.left {
		  	float: right;
		  
		  }
		  
		  .popover.right {

		  }		  
		 
		 .popover-title {
			font-family: "나눔 고딕", "BM_NANUMGOTHIC";
		 }

		.k-callout-n {
		border-bottom-color: #787878;
		}	
				
		.k-callout-w {
			border-right-color: #787878;
		}
		
		.k-callout-e {
		border-left-color: #787878;
		}	
		
		#attachment-list-view, #photo-list-view, #photo-gallery-view {
			min-height: 320px;
			min-width: 320px;
			padding: 0px;
			border: 0px;
			margin-bottom: -1px;
		}
        		                		
		.attach
		{
			float: left;
            position: relative;
            width: 160px;
            height: 160px;
            padding: 0;
			cursor: pointer;
			overflow: hidden;
		}
		
		.attach img
		{
			width: 160px;
			height: 160px;
		}
		
		.attach-description {
			position: absolute;
			top: 0;
			width: 160px	;
			height: 0;
			overflow: hidden;
			background-color: rgba(0,0,0,0.8)
		}
	
		.attach h3
		{
			margin: 0;
            padding: 10px 10px 0 10px;
            line-height: 1.1em;
            font-size : 12px;
            font-weight: normal;
            color: #ffffff;
            word-wrap: break-word;
		}

		.attach p {
			color: #ffffff;
			font-weight: normal;
			padding: 0 10px;
			font-size: 12px;
        }
        
		.k-listview:after, .attach dl:after {
			content: ".";
			display: block;
			height: 0;
			clear: both;
			visibility: hidden;
        }
        
        .k-pager-wrap {
        	border : 0px;
        	border-width: 0px;
        }

		.k-editor-inline {
			margin: 0;
			#padding: 21px 21px 11px;
			border-width: 0;
			box-shadow: none;
			background: none;
		}

		.k-editor-inline.k-state-active {
			border-width: 1px;
			#padding: 20px 20px 10px;
			#background: none;
			#border-color : red;
  			border-color: #66afe9;
			#  outline: 0;
			-webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);
			box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);
		}

		.inline-column-editor {
			display: inline-block;
			vertical-align: top;
			max-width: 600px;
			width: 100%;
		}
		
		</style>   	
	</head>
	<body id="doc">
		<!-- START HEADER -->
		<#include "/html/common/common-homepage-menu.ftl" >	
		<!-- END HEADER -->	
		<!-- START MAIN CONTENT -->
			<div class="container layout" style="min-height:350px;">							
				<div class="row">					
					<div class="col-sm-12 col-md-8">						
						<!-- start announce panel -->						
						<div id="announce-panel" class="custom-panels-group" style="display:none;">	
							<div class="panel panel-default">
								<div class="panel-heading">알림
									<div class="k-window-actions panel-header-actions">
										<a role="button" href="#" class="k-window-action k-link hide"><span role="presentation" class="k-icon k-i-refresh">Refresh</span></a>
										<a role="button" href="#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-minimize">Minimize</span></a>
										<a role="button" href="#" class="k-window-action k-link hide"><span role="presentation" class="k-icon k-i-maximize">Maximize</span></a>
										<a role="button" href="#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-close">Close</span></a>
									</div>
								</div>
								<div class="panel-body layout">					
									<div  id="announce-view"></div>
								</div>
							</div>		
						</div>						
						<!-- end announce panel -->		
						<div id="demo-view-panel" class="custom-panels-group"></div>								
						<!-- start photo view panel -->
						<div id="photo-view-panel" class="custom-panels-group" style="display: none;"></div>	
						<div id="photo-gallery-panel" class="custom-panels-group" style="display: none;"></div>	
						<!-- end photo view panel -->												
						<!-- start attach view panel -->
						<div id="attach-view-panel" class="custom-panels-group"></div>				
						<!-- end attach view panel -->		
						<!-- start social view panels -->
						<div id="social-view-panels"></div>	
						<!-- end social view panels -->						
					</div>							
					<div class="col-sm-12 col-md-4">
					
						<ul class="nav nav-pills">
							<li><a href="#"><i class="fa fa-calendar"></i> 달력</a></li>
							<li class="active"><a href="#"><i class="fa fa-bookmark"></i> 북마크</a></li>
							<li><a href="#"><i class="fa fa-folder-open"></i> 노트</a></li>
						</ul>
						<div class="blank-top-5" ></div>	
						
						<ul class="nav nav-tabs" id="myTab">
							<li class="dropdown active">
								<a href="#" id="my-messages-drop" class="dropdown-toggle" data-toggle="dropdown">메시지 <b class="caret"></b></a>
								<ul class="dropdown-menu" role="menu" aria-labelledby="my-messages-drop">
									<li class="active"><a href="#my-message-announces" tabindex="-1" data-toggle="tab"><i class="fa fa-bell-o"></i>    알림</a></li>		
									<li><a href="#my-message-notes" tabindex="-1" data-toggle="tab"><i class="fa fa-comments-o"></i>   My 쪽지</a></li>							
								</ul>
							</li>								
							<li class="dropdown">
								<a href="#" id="my-social-drop" class="dropdown-toggle" data-toggle="dropdown">쇼셜 <b class="caret"></b></a>
								<ul class="dropdown-menu" role="menu" aria-labelledby="my-social-drop">
									<li><a href="#my-streams" tabindex="-1" data-toggle="tab"><i class="fa fa-th"></i>    My 쇼셜</a></li>		
									<li><a href="#my-streams-mgmt" tabindex="-1" data-toggle="tab"><i class="fa fa-cogs"></i>   My 쇼셜 관리</a></li>							
								</ul>
							</li>		
							<li class="dropdown">
								<a href="#" id="my-photo-drop" class="dropdown-toggle" data-toggle="dropdown">포토 <b class="caret"></b></a>
								<ul class="dropdown-menu" role="menu" aria-labelledby="my-photo-drop">
									<li><a href="#my-photo-stream" tabindex="-1" data-toggle="tab"><i class="fa fa-th"></i>    My 포토 스트림</a></li>
									<li><a href="#my-photo-upload" tabindex="-1" data-toggle="tab"><span class="glyphicon glyphicon-cloud-upload"></span>    포토 업로드</a></li>
								</ul>
							</li>
							<li class="dropdown">
								<a href="#" id="my-files-drop" class="dropdown-toggle" data-toggle="dropdown">파일 <b class="caret"></b></a>
								<ul class="dropdown-menu" role="menu" aria-labelledby="my-files-drop">
									<li><a href="#my-files" tabindex="-1" data-toggle="tab"><i class="fa fa-th"></i>    My 파일</a></li>
									<li><a href="#my-file-upload" tabindex="-1" data-toggle="tab"><i class="fa fa-upload"></i>    파일 업로드</a></li>
								</ul>
							</li>						
						</ul>								
						<!-- start  of tab content -->				
						<div class="tab-content">			
							<!-- start messages -->			
							<div class="tab-pane active" id="my-message-announces">
								<div class="blank-top-5" ></div>	
								<div id="announce-grid" ></div>
							</div>									
							<div class="tab-pane" id="my-message-notes">
								<div class="blank-top-5" ></div>		
								<div class="panel panel-default">
									<div class="panel-body">			
										<ul class="media-list">
											<li class="media">
												<a class="pull-left" href="#">
													<img class="media-object" src="${request.contextPath}/images/common/anonymous.png" alt="...">
												</a>
												<div class="media-body">
																		<div class="popover right" style="display:true;">
																			<div class="arrow"></div>
																			<!--<h3 class="popover-title">알림</h3>-->
																			<div class="popover-content">
																				<p>새로운 메시지가 없습니다.</p>
																			</div>
																		</div>	
												</div>
											</li>
											<li class="media">
												<a class="pull-right" href="#">
													<img class="media-object" src="${request.contextPath}/images/common/anonymous.png" alt="...">
												</a>
												<div class="media-body">
													<div class="popover left" style="display:true;">
														<div class="arrow"></div>
														<!--<h3 class="popover-title">알림</h3>-->
														<div class="popover-content">
															<p>새로운 메시지가 없습니다.</p>
														</div>
													</div>	
												</div>
											</li>  
									</ul>
									</div>
									<div class="panel-footer"">
									<button type="button" class="btn btn-primary"><span class="glyphicon glyphicon-pencil"></span>   메시지 작성</button>
									</div>
								</div>								
							</div>							
							<div class="tab-pane" id="my-streams">							
								<div class="blank-top-5" ></div>		
								<div class="panel panel-primary">
									<div class="panel-heading"> 쇼셜미디어 버튼을 클릭하면, 쇼셜미디어 최신 뉴스를 볼수 있습니다.</div>
									<div class="panel-body">
										<div class="btn-group social-connect-btn">
											<#list action.companySocials as item >	
											<button class="btn btn-primary" data-provider="${item.serviceProviderName}"  type="submit"><i class="fa fa-${item.serviceProviderName}"></i> &nbsp; ${item.serviceProviderName}</button>
											</#list>	
										</div>									
									</div>
								</div>					
							</div>		
							<div class="tab-pane" id="my-streams-mgmt">				
								<div class="blank-top-5" ></div>	
								<div class="panel panel-default">
									<div class="panel-heading">소셜미디어 연결 버튼을 클릭하여, 새로운 쇼셜미디어 계정을 추가할 수 있습니다.</div>
									<div class="panel-body">								
										<div class="btn-group">
											<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">쇼셜미디어 추가 <span class="caret"></span>
											</button>
											<ul class="dropdown-menu" role="menu">
												<li><a href="#"><i class="fa fa-facebook"></i> &nbsp;페이스북 연결</a></li>
												<li><a href="#"><i class="fa fa-twitter"></i> &nbsp;트위터 연결</a></li>
												<li class="divider"></li>
												<li><a href="#">쇼셜미디어 계정 관리</a></li>
											</ul>
										</div>
									</div>
								</div>								
							</div>	
							<!-- end messages -->				
							<!-- start attachement -->
							<div class="tab-pane" id="my-file-upload">
								<div class="blank-top-5" ></div>											
								<#if !action.user.anonymous >			
								<div class="alert alert-info"><strong>파일 선택</strong> 버튼을 클릭하여 직접 파일을 선택하거나, 아래의 영역에 파일을 끌어서 놓기(Drag & Drop)를 하세요.</div>
								<input name="uploadAttachment" id="attachment-files" type="file" />									
								</#if>							
							</div>
							<div class="tab-pane" id="my-files">
								<div class="blank-top-5 "></div>
								<div class="panel panel-default">								
									<div class="panel-heading">
										<ul id="attachment-list-view-filter" class="nav nav-pills">
											<li class="active">
												<a href="#"  id="attachment-list-view-filter-1" style="width:100px;"><span class="badge pull-right" data-bind="text: totalAttachCount"></span>전체</a>
											</li>
											<li>
												<a href="#"  id="attachment-list-view-filter-2"><i class="fa fa-filter"></i> 사진</a>
											</li>
											<li><a href="#"  id="attachment-list-view-filter-3"><i class="fa fa-filter"></i> 파일</a>
											</li>									  
										</ul>										
									</div>
									<div class="panel-body scrollable" style="max-height:450px;">
										<div id="attachment-list-view" ></div>
									</div>	
									<div class="panel-footer" style="padding:0px;">
										<div id="pager" class="k-pager-wrap"></div>
									</div>
								</div>																					
							</div>
							<!-- end attachements -->		
							<!-- start photos -->
							<div class="tab-pane" id="my-photo-stream">
								<div class="blank-top-5" ></div>					
								<div class="panel panel-default">								
									<div class="panel-body scrollable" style="max-height:450px;">
										<div id="photo-list-view" ></div>
									</div>	
									<div class="panel-header" style="padding:0px;">
										<div id="photo-list-pager" class="k-pager-wrap"></div>
									</div>
								</div>																				
							</div>							
							<div class="tab-pane" id="my-photo-upload">
								<div class="blank-top-5 "></div>
								<#if !action.user.anonymous >		
								<div class="alert alert-info"><strong>사진 선택</strong> 버튼을 클릭하여 사진을 직접 선택하거나, 아래의 영역에 사진를 끌어서 놓기(Drag & Drop)을 끌어서 놓기(Drag & Drop)를 하세요.</div>
								<div class="blank-top-5 "></div>	
								<input name="uploadPhotos" id="photo-files" type="file" />	
								</#if>							
							</div>
							<!-- end photos -->
						</div>
						<!-- end of tab content -->						
					</div>				
				</div>
			</div>		
		<div id="attach-window"></div>					
		<!-- END MAIN CONTENT -->		
 		<!-- START FOOTER -->
		<#include "/html/common/common-homepage-footer.ftl" >		
		<!-- END FOOTER -->	
		
		<!-- START TEMPLATE -->				
		<script type="text/x-kendo-tmpl" id="attachment-list-view-template">
			<div class="attach">			
			#if (contentType.match("^image") ) {#
				<img src="${request.contextPath}/secure/view-attachment.do?width=150&height=150&attachmentId=#:attachmentId#" alt="#:name# 이미지" class="img-responsive"/>
			# } else { #			
				<img src="http://placehold.it/146x146&amp;text=[file]"></a>
			# } #	
				<div class="attach-description">
					<h3>#:name#</h3>
					<p>#:size# 바이트</p>
				</div>
			</div>
		</script>	
		<script type="text/x-kendo-tmpl" id="photo-list-view-template">
			<div class="attach">			
			#if (contentType.match("^image") ) {#
				<img src="${request.contextPath}/community/view-my-image.do?width=150&height=150&imageId=#:imageId#" alt="#:name# 이미지" class="img-responsive"/>
			# } else { #			
				<img src="http://placehold.it/146x146&amp;text=[file]"></a>
			# } #	
				<div class="attach-description">
					<h3>#:name#</h3>
					<p>#:size# 바이트</p>
				</div>
			</div>
		</script>					
		<#include "/html/common/common-homepage-templates.ftl" >		
		<!-- END TEMPLATE -->
	</body>    
</html>