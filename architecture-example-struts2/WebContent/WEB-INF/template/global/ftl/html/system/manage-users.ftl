<#ftl encoding="UTF-8"/>
<html decorator="secure-metro">
    <head>
        <title>사용자 관리</title>
        <script type="text/javascript">                
        yepnope([{
            load: [ 
			'css!${request.contextPath}/styles/font-awesome/4.0.3/font-awesome.min.css',			
			'${request.contextPath}/js/jquery/1.10.2/jquery.min.js',
       	    '${request.contextPath}/js/kendo/kendo.web.min.js',
			'${request.contextPath}/js/jgrowl/jquery.jgrowl.min.js',      	    
       	    '${request.contextPath}/js/kendo/kendo.ko_KR.js',
			'${request.contextPath}/js/bootstrap/3.0.3/bootstrap.min.js',       	    
       	    '${request.contextPath}/js/common/common.models.js',
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
				var selectedCompany = new Company({companyId:${action.companyId}});			
								
				// 3.MENU LOAD
			
				var currentPageName = "MENU_1_4";
				
				var topBar = $("#navbar").extTopBar({ 
					template : kendo.template($("#topbar-template").html()),
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
									type: "json",
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
							kendo.bind($("#company-info-panel"), selectedCompany );   
						}
					},
					doAfter : function(that){
						var menu = that.getMenuItem(currentPageName);
						kendo.bind($(".page-header"), menu );   
					}
				 });	
		
				// 4. CONTENT MAIN		

                // SPLITTER LAYOUT
				$("button.btn-control-group ").each(function (index) {					
					var btn_control = $(this);
					var btn_control_action = btn_control.attr("data-action");
					if (btn_control_action == "group"){
						btn_control.click( function(e){			
							$("form[name='fm1'] input").val(selectedCompany.companyId);		
							$("form[name='fm1']").attr("action", "main-group.do" ).submit(); 
						} );						
					}else if (btn_control_action == "layout"){
						btn_control.click(function (e) {										
							$(".body-group").each(function( index ) {
								var panel_body = $(this);
								var is_detail_body = false;
								if (panel_body.attr("id") == "user-details"){
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
												
	            var selectedUser = new User ({});	
		        // 1. USER GRID 		        
				var user_grid = $("#user-grid").kendoGrid({
                    dataSource: {
                    	serverFiltering: true,
                        transport: { 
                            read: { url:'${request.contextPath}/secure/list-user.do?output=json', type: 'POST' },
	                        parameterMap: function (options, type){
	                            return { startIndex: options.skip, pageSize: options.pageSize,  companyId: selectedCompany.companyId }
	                        }
                        },
                        schema: {
                            total: "totalUserCount",
                            data: "users",
                            model: User
                        },
                        error:handleKendoAjaxError,
                        batch: false,
                        pageSize: 15,
                        serverPaging: true,
                        serverFiltering: false,
                        serverSorting: false
                    },
                    columns: [
                        { field: "userId", title: "ID", width:50,  filterable: false, sortable: false , headerAttributes: { "class": "table-header-cell", style: "text-align: center" } }, 
                        { field: "username", title: "아이디", width: 100, headerAttributes: { "class": "table-header-cell", style: "text-align: center" } }, 
                        { field: "name", title: "이름", width: 100 , headerAttributes: { "class": "table-header-cell", style: "text-align: center" }}, 
                        { field: "email", title: "메일", headerAttributes: { "class": "table-header-cell", style: "text-align: center" } },
                        { field: "enabled", title: "사용여부", width: 90, headerAttributes: { "class": "table-header-cell", style: "text-align: center" } },
                        { field: "creationDate",  title: "생성일", width: 120,  format:"{0:yyyy/MM/dd}", headerAttributes: { "class": "table-header-cell", style: "text-align: center" } },
                        { field: "modifiedDate", title: "수정일", width: 120,  format:"{0:yyyy/MM/dd}", headerAttributes: { "class": "table-header-cell", style: "text-align: center" } } ],         
                    filterable: true,
                    sortable: true,
                    pageable: { refresh:true, pageSizes:false,  messages: { display: ' {1} / {2}' }  },
                    selectable: 'row',
                    height: '100%',
                    toolbar: [
					 	{ name: "create-user", text: "새로운 사용자 생성하기", className: "createUserCustomClass" } ],
                    change: function(e) {                    
                        var selectedCells = this.select();                        
  						if( selectedCells.length == 1){ 
                            var selectedCell = this.dataItem( selectedCells ); 
                            selectedUser.userId = selectedCell.userId ; 
							selectedUser.username = selectedCell.username ;             
							selectedUser.name = selectedCell.name ;
							selectedUser.email = selectedCell.email ;
							selectedUser.creationDate = selectedCell.creationDate ;
							selectedUser.lastLoggedIn = selectedCell.lastLoggedIn ;         							 
							selectedUser.formattedLastLoggedIn =  kendo.format("{0:yyyy.MM.dd}",  selectedUser.lastLoggedIn  );							 
							selectedUser.lastProfileUpdate = selectedCell.lastProfileUpdate ;                 
							selectedUser.formattedLastProfileUpdate =  kendo.format("{0:yyyy.MM.dd}",  selectedUser.lastProfileUpdate  );                   
							selectedUser.enabled = selectedCell.enabled ;              
							selectedUser.nameVisible = selectedCell.nameVisible ;          
							selectedUser.emailVisible = selectedCell.emailVisible ;
							selectedUser.properties = selectedCell.properties;							 							 
							selectedUser.company = selectedCompany;
							var observable = new kendo.data.ObservableObject( selectedUser ); 
							
							 if( selectedUser.userId > 0 ){						
							 	 	
							 	// 2. USER DETAILS
							 	// $("#splitter").data("kendoSplitter").expand("#datail_pane");
							 	 
							 	// 3. USER TABS 	
							 	$('#user-details').show().html(kendo.template($('#user-details-template').html()));							 	
								kendo.bind($(".details"), selectedUser ); 
							
							 	if( selectedUser.properties.imageId ){
							 		var photoUrl = '${request.contextPath}/secure/view-image.do?width=150&height=200&imageId=' + selectedUser.properties.imageId ;
							 	 	$('#user-photo').attr( 'src', photoUrl );
							 	}								
								$("#files").kendoUpload({
								 	multiple : false,
								 	showFileList : false,
								    localization:{ select : '사진변경' , dropFilesHere : '업로드할 이미지를 이곳에 끌어 놓으세요.' },
								    async: {
									    saveUrl:  '${request.contextPath}/secure/save-user-image.do?output=json',							   
									    autoUpload: true
								    },
								    upload: function (e) {								         
								         var imageId = -1;
								         if( selectedUser.properties.imageId ){
								         	imageId = selectedUser.properties.imageId
								         }
								    	 e.data = { userId: selectedUser.userId , imageId:imageId  };									    								    	 		    	 
								    },
								    success : function(e) {								    
								    	if( e.response.targetUserImage ){
								    		selectedUser.properties.imageId = e.response.targetUserImage.imageId;
								    		var photoUrl = '${request.contextPath}/secure/view-image.do?width=150&height=200&imageId=' + selectedUser.properties.imageId ;
							 	 			$('#user-photo').attr( 'src', photoUrl );
								    	}				
								    }					   
								});	                    
					            $('#change-password-btn').bind( 'click', function(){
					                $('#change-password-window').kendoWindow({
				                            width: "400px",
				                            minWidth: "300px",
				                            minHeight: "250px",
				                            title: "패스워드 변경",
				                            modal: true,
				                            visible: false
				                        });
				                    $('#change-password-window').data("kendoWindow").center();        
				                    $('#password2').focus();                
					            	$('#change-password-window').data("kendoWindow").open();	            	
					            });					            
					            $('#do-change-password-btn').bind( 'click', function(){	            	
					            	var doChangePassword = true ;	            	
					            	if( $('#password2').val().length < 6 ){
					            		alert ('패스워드는 최소 6 자리 이상으로 입력하여 주십시오.') ;	     
					            		doChangePassword = false ;
					            		$('#password2').val("");        
					            		$('#password3').val("");           		
					            		$('#password2').focus();   
					            		return false;
					            	}					            
				                   	if( doChangePassword && $('#password2').val() != $('#password3').val() ){
				                   		doChangePassword = false;
				                   	    alert( '패스워드가 같지 않습니다. 다시 입력하여 주십시오.' );      
				                   	    $('#password3').val("");
				                   	    $('#password3').focus();               
				                   	    return false; 	   
				                   	} 				
									if(doChangePassword) {
				                   	    selectedUser.password = $('#password2').val();                   	    
										$.ajax({
												type : 'POST',
												url : "${request.contextPath}/secure/update-user.do?output=json",
												data : { userId:selectedUser.userId, item: kendo.stringify( selectedUser ) },
												success : function( response ){	
												    $('#user-grid').data('kendoGrid').dataSource.read();	
												},
												error:handleKendoAjaxError,
												dataType : "json"
											});	
										selectedUser.password = '' ;                   	    	
				                   	}            	                   	
					            } ); 
				                $('#update-user-btn').bind('click' , function(){
									$.ajax({
										type : 'POST',
										url : "${request.contextPath}/secure/update-user.do?output=json",
										data : { userId:selectedUser.userId, item: kendo.stringify( selectedUser ) },
										success : function( response ){									
										    $('#user-grid').data('kendoGrid').dataSource.read();	
										},
										error: handleKendoAjaxError,
										dataType : "json"
									});										
									if(visible){
										slide.reverse();						
										visible = false;		
										$("#detail-panel").hide();				
									}
				                }); 	                							 	
							 	//kendo.bind($(".tabular"), selectedUser );							 					
							 	var user_tabs = $('#user-details').find(".tabstrip").kendoTabStrip({
									animation: {
								    	close: {  duration: 200, effects: "fadeOut" },
								       	open: { duration: 200, effects: "fadeIn" }
				                    },
									select : function(e){			
										
										// TAB - ATTACHMENT TAB
										if( $( e.contentElement ).find('div').hasClass('attachments') ){					   
											if( ! $("#attach-upload").data("kendoUpload") ){	
												$("#attach-upload").kendoUpload({
					                      			multiple : true,
					                      			showFileList : true,
					                      			localization : { select: '파일 선택', remove:'삭제', dropFilesHere : '업로드할 파일을 이곳에 끌어 놓으세요.' , 
					                      				uploadSelectedFiles : '파일 업로드',
					                      				cancel: '취소' 
					                      			 },
					                      			 async: {
													    saveUrl:  '${request.contextPath}/secure/save-user-attachments.do?output=json',							   
													    autoUpload: false
												    },
												    upload:  function (e) {		
												    	e.data = { userId: selectedUser.userId };		
												    },
												    success : function(e) {	
												    	$('#attach-grid').data('kendoGrid').dataSource.read(); 
												    }
					                      		});				
											}				                   
											   		         
											if( ! $("#attach-grid").data("kendoGrid") ){	
												$("#attach-grid").kendoGrid({
							                        dataSource: {
							                        	autoSync: true,
							                            type: 'json',
							                            transport: {
							                                read: { url:'${request.contextPath}/secure/get-user-attachements.do?output=json', type: 'POST' },		
							                                destroy: { url:'${request.contextPath}/secure/delete-user-attachment.do?output=json', type:'POST' },						                                
									                        parameterMap: function (options, operation){
									                        	 if (operation != "read" && options) {										                        								                       	 	
									                        	 	return { userId: selectedUser.userId, attachmentId :options.attachmentId };									                            	
									                            }else{
									                            	return { userId: selectedUser.userId };
									                            }
									                        }								                         
							                            },
							                            error:handleKendoAjaxError,
							                            schema: {
							                            	model: Attachment,
							                            	data : "targetUserAttachments"
							                            }
							                        },
							                        height:300,
							                        scrollable:  true,
							                        sortable: true,
							                        editable: {
									                	update: false,
									                	destroy: true,
									                	confirmation: "선택하신 첨부파일을 삭제하겠습니까?"
									                },
							                        columns: [{
							                        		title: "ID",
							                        		width: 50,
							                                field:"attachmentId",
							                                filterable: false
							                            },
							                            {
							                                field: "name",
							                                title: "이름",
							                                template: '#= name  #',
							                                width: 150
							                            },
							                             {
							                                field: "contentType",
							                                title: "유형",
							                                width: 80 /**
							                            }, {
							                                field: "modifiedDate",
							                                title: "수정일",
							                                width: 80,
							                                format: "{0:yyyy/MM/dd}" **/
							                            },
							                            { command: [ { name: "download", text: "미리보기" ,click: function(e)  {
									                            	var tr = $(e.target).closest("tr"); 
														          	var item = this.dataItem(tr);
							                            			if(! $("#download-window").data("kendoWindow")){
							                            				$("#download-window").kendoWindow({
							                            					actions: ["Close"],
							                            					minHeight : 500,
							                            					minWidth :  400,
							                            					maxHeight : 700,
							                            					maxWidth :  600,
							                            					modal: true,
							                            					visible: false
							                            				});
							                            			}
							                            			
							                            			var downloadWindow = $("#download-window").data("kendoWindow");
							                            			downloadWindow.title( item.name );							                            			
							                            		 	var template = kendo.template($("#download-window-template").html());
							                            			downloadWindow.content( template(item) );
							                            			$("#download-window").closest(".k-window").css({
																	     top: 5,
																	     left: 5,
																	 });						                            			
							                            			downloadWindow.open();
							                            		}
							                            	}, 
							                            	{ name: "destroy", text: "삭제" } ],  title: "&nbsp;", width: 160  }					                            
							                        ],
							                        dataBound: function(e) {
							                        }
							                    });
							                    $("#attach-grid").attr('style', '');
											}
				                    	}
				                    	
										// TAB - GROUP TAB --------------------------------------------------------------------------
										if( $( e.contentElement ).find('div').hasClass('groups') ){
				                          	if( ! user_tabs.find(".groups").data("kendoGrid") ){	
												// 3-1 USER GROUP GRID
											    user_tabs.find(".groups").kendoGrid({
				   										dataSource: {
													    	type: "json",
										                    transport: {
										                        read: { url:'${request.contextPath}/secure/list-user-groups.do?output=json', type:'post' },
																destroy: { url:'${request.contextPath}/secure/remove-group-members.do?output=json', type:'post' },
																parameterMap: function (options, operation){
												                    if (operation !== "read" && options.models) {
																 	    return { userId: selectedUser.userId, items: kendo.stringify(options.models)};
										                            }
												                    return { userId: selectedUser.userId };
												                }
										                    },
										                    schema: {
										                    	data: "userGroups",
										                    	model: Group
										                    },
										                    error:handleKendoAjaxError
					                                     },
													    scrollable: true,
													    height:200,
													    editable: false,
										                columns: [
									                        { field: "groupId", title: "ID", width:40,  filterable: false, sortable: false }, 
									                        { field: "displayName",    title: "이름",   filterable: true, sortable: true,  width: 100 },
									                        { command:  { text: "삭제", click : function(e){									                       		
									                       		if( confirm("정말로 삭제하시겠습니까?") ){
																	var selectedGroup = this.dataItem($(e.currentTarget).closest("tr"));									                       		
										                       		$.ajax({
																		type : 'POST',
																		url : "/secure/remove-group-members.do?output=json",
																		data : { groupId:selectedGroup.groupId, items: '[' + kendo.stringify( selectedUser ) + ']'  },
																		success : function( response ){									
																	        $('#user-group-grid').data('kendoGrid').dataSource.read();
																	        $('#group-role-selected').data("kendoMultiSelect").dataSource.read();
																		},
																		error:handleKendoAjaxError,
																		dataType : "json"
																	});								                       		
									                       		}
									                       }},  title: "&nbsp;", width: 100 }	
										                ],
										                dataBound:function(e){										                
										                }
											    });  											    
											    $("#user-group-grid").attr('style','');	    
				                          	}	
				                        // TAB 3 - PROPS  											
										} else if( $( e.contentElement ).find('div').hasClass('props') ){
											if( !user_tabs.find(".props").data("kendoGrid") ){	
				                          					                          	
											}	
										// TAB - ROLES --------------------------------------------------------------		                          	
										} else if( $( e.contentElement ).find('div').hasClass('roles') ){										
											// SELECTED GROUP ROLES
											if( !$('#group-role-selected').data('kendoMultiSelect') ){
												$('#group-role-selected').kendoMultiSelect({
				                                    placeholder: "NONE",
									                dataTextField: "name",
									                dataValueField: "roleId",
									                dataSource: {
									                    transport: {
									                        read: {
							                                    url: '${request.contextPath}/secure/get-user-group-roles.do?output=json',
																dataType: "json",
																type: "POST",
																data: { userId: selectedUser.userId }
									                        }
									                    },
									                    schema: { 
						                            		data: "userGroupRoles",
						                            		model: Role
						                        		}
									                },
						                        	error:handleKendoAjaxError,
						                        	dataBound: function(e) {
						                        		var multiSelect = $("#group-role-selected").data("kendoMultiSelect");
						                        		var selectedRoleIDs = "";
						                        		$.each(  multiSelect.dataSource.data(), function(index, row){  
						                        			if( selectedRoleIDs == "" ){
						                        			    selectedRoleIDs =  selectedRoleIDs + row.roleId ;
						                        			}else{
						                        				selectedRoleIDs = selectedRoleIDs + "," + row.roleId;
						                        			}
						                        		} );			                        		
						                        		multiSelect.value( selectedRoleIDs.split( "," ) );
						                        		multiSelect.readonly();		
						                        	}
									            });	
											}									    
											// SELECT USER ROLES
											if( !$('#user-role-select').data('kendoMultiSelect') ){											
												var selectedRoleDataSource = new kendo.data.DataSource({
													transport: {
										            	read: { 
										            		url:'${request.contextPath}/secure/get-user-roles.do?output=json', 
										            		dataType: "json", 
										            		type:'POST',
										            		data: { userId: selectedUser.userId }
												        }  
												    },
												    schema: {
									                	data: "userRoles",
									                    model: Role
									                },
									                error:handleKendoAjaxError,
									                change: function(e) {                
						                        		var multiSelect = $("#user-role-select").data("kendoMultiSelect");
						                        		var selectedRoleIDs = "";			                        		
						                        		$.each(  selectedRoleDataSource.data(), function(index, row){  
						                        			if( selectedRoleIDs == "" ){
						                        			    selectedRoleIDs =  selectedRoleIDs + row.roleId ;
						                        			}else{
						                        				selectedRoleIDs = selectedRoleIDs + "," + row.roleId;
						                        			}
						                        		} );			                        		
						                        		multiSelect.value( selectedRoleIDs.split( "," ) );	 
									                }	                               
				                               	});	
				                               												
												$('#user-role-select').kendoMultiSelect({
				                                    placeholder: "롤 선택",
									                dataTextField: "name",
									                dataValueField: "roleId",
									                dataSource: {
									                    transport: {
									                        read: {
							                                    url: '${request.contextPath}/secure/list-role.do?output=json',
																dataType: "json",
																type: "POST"
									                        }
									                    },
									                    schema: { 
						                            		data: "roles",
						                            		model: Role
						                        		}
									                },
						                        	error:handleKendoAjaxError,
						                        	dataBound: function(e) {
						                        		 selectedRoleDataSource.read();   	
						                        	},			                        	
						                        	change: function(e){
						                        		var multiSelect = $("#user-role-select").data("kendoMultiSelect");			                        		
						                        		var list = new Array();			                        		                  		
						                        		$.each(multiSelect.value(), function(index, row){  
						                        			var item =  multiSelect.dataSource.get(row);
						                        			list.push(item);			                        			
						                        		});			                        		
						                        		multiSelect.readonly();						                        		
							 							$.ajax({
												            dataType : "json",
															type : 'POST',
															url : "${request.contextPath}/secure/update-user-roles.do?output=json",
															data : { userId: selectedUser.userId, items: kendo.stringify( list ) },
															success : function( response ){		
																// need refresh ..
															},
															error:handleKendoAjaxError
														});												
														multiSelect.readonly(false);
						                        	}
									            });
											}										
										}
									} 
				                });
				                
				                // GROUP SELECT COMBO BOX
								var company_combo = $("#company-combo").kendoComboBox({
									autoBind: false,
									placeholder: "회사 선택",
			                        dataTextField: "displayName",
			                        dataValueField: "companyId",
								    dataSource: topBar.items[0].dataSource // $("#company").data("kendoDropDownList").dataSource 
								});			
													
								$("#company-combo").data("kendoComboBox").value( 
								 	selectedCompany.companyId //$("#company").data("kendoDropDownList").value() 
								 );	
								 
								$("#company-combo").data("kendoComboBox").readonly();
																
								$("#group-combo").kendoComboBox({
									autoBind: false,
									placeholder: "그룹 선택",
			                        dataTextField: "displayName",
			                        dataValueField: "groupId",
			                        cascadeFrom: "company-combo",			                       
								    dataSource:  {
										type: "json",
									 	serverFiltering: true,
										transport: {
											read: { url:'${request.contextPath}/secure/list-company-group.do?output=json', type:'post' },
											parameterMap: function (options, operation){											 	
											 	return { companyId:  options.filter.filters[0].value };
											}
										},
										schema: {
											data: "companyGroups",
											model: Group
										},
										error:handleKendoAjaxError
									}
								});	
								
								// ADD USER TO SELECTED GROUP 
								$("#add-to-member-btn").click( function ( e ) {
									 $.ajax({
							            dataType : "json",
										type : 'POST',
										url : "${request.contextPath}/secure/add-group-member.do?output=json",
										data : { groupId:  $("#group-combo").data("kendoComboBox").value(), item: kendo.stringify( selectedUser ) },
										success : function( response ){																		    
											 $("#user-group-grid").data("kendoGrid").dataSource.read();
											 $('#group-role-selected').data("kendoMultiSelect").dataSource.read();
										},
										error:handleKendoAjaxError
									});	
								} );
																				                
				                // 3-1 USER PROPERTY GRID				         
				                user_tabs.find(".props").kendoGrid({
								     dataSource: {
										transport: { 
											read: { url:'${request.contextPath}/secure/get-user-property.do?output=json', type:'post' },
										    create: { url:'${request.contextPath}/secure/update-user-property.do?output=json', type:'post' },
										    update: { url:'${request.contextPath}/secure/update-user-property.do?output=json', type:'post'  },
										    destroy: { url:'${request.contextPath}/secure/delete-user-property.do?output=json', type:'post' },
										 	parameterMap: function (options, operation){
										 		if (operation !== "read" && options.models) {
				                                	return { userId: selectedUser.userId, items: kendo.stringify(options.models)};
				                                } 
						                        return { userId: selectedUser.userId }
						                    }
										 },						
										 batch: true, 
										 schema: {
					                            data: "targetUserProperty",
					                            model: Property
					                     },
					                     error:handleKendoAjaxError
								     },
								     columns: [
								         { title: "속성", field: "name" },
								         { title: "값",   field: "value" },
								         { command:  { name: "destroy", text:"삭제" },  title: "&nbsp;", width: 100 }
								     ],
								     autoBind: true, 
								     pageable: false,
								     scrollable: true,
								     height: 200,
						             editable: {
						                	update: true,
						                	destroy: true,
						                	confirmation: "선택하신 프로퍼티를 삭제하겠습니까?"	
						             },
								     toolbar: [
								         { name: "create", text: "추가" },
				                         { name: "save", text: "저장" },
				                         { name: "cancel", text: "취소" }
									 ],				     
								     change: function(e) {  
								     }
							    });								    
							    $("#user-props-grid").attr('style','');	    
							 }			     
                        }else{
                            selectedUser = new User ({});
                        }                       
					},
					dataBound: function(e){		
						 var selectedCells = this.select();
						 if(selectedCells.length == 0 ){								      
						     selectedUser = new User ({});
						     kendo.bind($(".tabular"), selectedUser );	
							$("#user-details").hide(); 	 					     
						 }
					}
                }).data('kendoGrid');
            }	
        }]);      
        
        </script>
		<style>			
		.k-grid-content{
			height:300px;
		}		
		</style>
    </head>
	<body>
		<!-- START HEADER -->
		<section id="navbar" class="layout"></section>
		<!-- END HEADER -->
		<!-- START MAIN CONTNET -->
		<div class="container full-width-container">	
			<div class="row">			
				<div class="col-12 col-lg-12">					
					<div class="page-header">
						<h1><span data-bind="text: title"></span>     <small><i class="fa fa-quote-left"></i>&nbsp;<span data-bind="text: description"></span>&nbsp;<i class="fa fa-quote-right"></i></small></h1>
					</div>			
				</div>		
			</div>
			<div class="row full-width-row">		
				<div class="col-sm-12">
					<div class="panel panel-default" style="min-height:300px;" >
						<div class="panel-heading selected-company-info" style="padding:5px;">
							<div class="btn-group">
								<button type="button" class="btn btn-success btn-control-group" data-action="user"><i class="fa fa-users"></i>&nbsp;<span data-bind="text: displayName"></span>&nbsp;그룹관리</button>
								<button type="button" class="btn btn-default btn-control-group btn-columns-expend" data-action="layout"><i class="fa fa-columns"></i></button>
							</div>
						</div>
						<div class="panel-body" style="padding:5px;">
							<div class="row marginless paddingless">
								<div class="col-sm-12 body-group marginless paddingless"><div id="user-grid"></div></div>
								<div id="user-details" class="col-sm-12 body-group marginless paddingless" style="display:none; padding-top:5px;"></div>
							</div>
						</div>
					
					</div>				
				</div>			
			</div>				
						<!--
			<div class="row">
				<div class="col-12 col-lg-12">		
					<div id="splitter">
						<div id="list_pane">
							
						</div>
						<div id="datail_pane">
							<div id="user-details"></div>
						</div>
					</div>				
				</div>	
			</div>				
			-->
			<form name="fm1" method="POST" accept-charset="utf-8">
				<input type="hidden" name="companyId"  value="${action.companyId}" />
			</form>	
		</div>	
		<div id="change-password-window" style="display:none;">
		<div class="container layout">	
			<div class="row">
				<div class="col-12 col-lg-12">
					<p>
					    	6~16자의 영문 대소문자, 숫자, 특수문자를 조합하여
							사용하실 수 있습니다.
							생년월일, 전화번호 등 개인정보와 관련된 숫자,
							연속된 숫자와 같이 쉬운 비밀번호는 다른 사람이 쉽게
							알아낼 수 있으니 사용을 자제해 주세요.
							이전에 사용했던 비밀번호나 타 사이트와는 다른 비밀번호를
							사용하고, 비밀번호는 주기적으로 변경해주세요.
							<div class="alert alert-danger">비밀번호에 특수문자를 추가하여 사용하시면
							기억하기도 쉽고, 비밀번호 안전도가 높아져 도용의 위험이
							줄어듭니다.	
							</div>    	
					</p>	
				</div>
			</div>
			<div class="row">
				<div class="col-12 col-lg-12">									
					<form class="form-horizontal">
						<div class="form-group">
							<label class="col-lg-5 control-label" for="password2">새 비밀번호</label>
							<div class="controls">
								<input type="password" id="password2" name="password2" class="k-textbox"  placeholder="비밀번호" required validationMessage="비밀번호를 입력하여 주세요." />
							</div>
						</div>	
						<div class="form-group">
							<label class="col-lg-5 control-label" for="password3">새 비밀번호 확인</label>
							<div class="controls">
								<input type="password" id="password3" name="password3" class="k-textbox"  placeholder="비밀번호" required validationMessage="비밀번호를 입력하여 주세요." />
							</div>
						</div>		
						<div class="form-group">	
							<div class="col-lg-4"></div>
							<div class="col-lg-8">
							<button id="do-change-password-btn" class="k-button">확인</button>
							<button class="k-button" type="reset">다시입력</button></div>
							</div>
						</div>
					</form>
				</div>
			</div>	
		</div>
		</div>
		  
  		<div id="download-window"></div>    
		
		<div id="pageslide" style="left: -300px; right: auto; display: none;">	
			<div id="accounts-panel"></div>
		</div>
						  
  		<!-- END MAIN CONTNET -->
		<!--
		<footer>  
		</footer>    
		-->
		<script id="download-window-template" type="text/x-kendo-template">				
			#if (contentType.match("^image") ) {#
				<img src="${request.contextPath}/secure/view-attachment.do?attachmentId=#= attachmentId #" class="img-responsive" alt="#= name #" />
			# } else { #
			
			# } #  		
			<table class="table table-bordered blank-top-5">
			  <thead>
			    <tr>
			      <th>이름</th>
			      <th>유형</th>
			      <th>크기</th>
			      <th>&nbsp;</th>
			    </tr>
			  </thead>
			  <tbody>
			    <tr>
			      <td  width="300">#= name #</td>
			      <td  width="150">#= contentType #</td>
			      <td  width="200">#= size # 바이트</td>
			      <td  width="150"><a class="k-button" href="${request.contextPath}/secure/download-attachment.do?attachmentId=#= attachmentId #" >다운로드</a></td>
			    </tr>
			  </tbody>
			</table>				
		</script>	
		
		<script type="text/x-kendo-template" id="user-details-template">			
			<div class="panel panel-primary marginless details" >
				<div class="panel-heading" >
					<span data-bind="text: name"></span>
					<button type="button" class="close" aria-hidden="true">&times;</button>
				</div>				
				<div class="panel-body" style="padding:5px;">		
					<div class="media">
						<a class="pull-left" href="#">
							<img id="user-photo" class="img-thumbnail media-object" src="http://placehold.it/100x150" border="0" />
						</a>
						<div class="media-body">
							<h4 class="media-heading">Media heading</h4>

						</div>
					</div>								
					<div class="row">
						<div class="col-lg-2">
																
							<input name="uploadImage" id="files" type="file" />
						</div>
						<div class="col-lg-10 details">									
							<div class="form-horizontal">
											<div class="form-group">
	 											<label class="col-lg-3 control-label">이름</label>
												<div class="col-lg-9">
													<input type="text" class="k-textbox" placeholder="아이디" data-bind="value:username"/>
												</div>	
											</div>
											<div class="form-group">
	 											<label class="col-lg-3 control-label">메일</label>
												<div class="col-lg-9">
													<input type="text" class="k-textbox" placeholder="메일주소" data-bind="value:email"/>
												</div>	
											</div>
											<div class="form-group">
	 											<label class="col-lg-3 control-label">옵션</label>
												<div class="col-lg-9">
													<div class="checkbox">
														<label>
															<input type="checkbox" name="nameVisible"  data-bind="checked: nameVisible" />	이름공개
														</label>
													</div>		
													<div class="checkbox">
														<label>
															<input type="checkbox"  name="emailVisible"  data-bind="checked: emailVisible" />	메일공개
														</label>
													</div>	
													<div class="checkbox">
														<label>
															<input type="checkbox"  name="enabled"  data-bind="checked: enabled" />계정사용여부
														</label>
													</div>																																			
												</div>
											</div>										
										</div>
							<table class="table table-striped">
											<thead>
												<tr>
													<td>최근 수정일자</td>
													<td>최근 로그인 일자</td>
												</tr>
											</thead>
											<tbody>
												<tr class="active">
													<td><span data-bind="text: formattedLastProfileUpdate"></span></td>
													<td><span data-bind="text: formattedLastLoggedIn"></span></td>
												</tr>                                                                    
											</tbody>
										</table>									
						</div>					
					</div>
					<div class="row">
						<div class="col-12 col-xs-12">		
							<ul id="myTab" class="nav nav-tabs">
								<li class="active"><a href="\\#props" data-toggle="tab">프로퍼티</a></li>
								<li><a href="\\#groups" data-toggle="tab">그룹</a></li>
								<li><a href="\\#roles" data-toggle="tab">롤</a></li>
								<li><a href="\\#files" data-toggle="tab">첨부파일</a></li>
							</ul>			
							<div class="tab-content">
								<div class="tab-pane active" id="props">
									<div class="blank-top-5"></div>
									<div class="alert alert-danger margin-buttom-5">
										<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
										프로퍼티는 수정 후 저장 버튼을 클릭하여야 최종 반영됩니다.
									</div>						
									<div id="group-prop-grid" class="props"></div>
								</div>
								<div class="tab-pane" id="groups"></div>
								<div class="tab-pane" id="roles"></div>
								<div class="tab-pane" id="files"></div>						
							</div>
						</div>
					</div>
				</div>
			</div>			
		</div>
		
		<script type="text/x-kendo-template" id="template">

				<div class="big-box">
					<div class="tabstrip">
						<ul>
							<li class="k-state-active">
							기본정보
							</li>	                	
							<li>
							프로퍼티
							</li>
							<li>
							그룹
							</li>
							<li>
							권한
							</li>	                   
							<li>
							첨부파일
							</li>	   
						</ul>	          
						<div>
							<!-- USER INFO TAB =============================== -->
							<div class="container layout" >
							<div class="row blank-top-5">
								<div class="col-lg-4">
									<img id="user-photo" class="img-thumbnail" src="http://placehold.it/100x150" border="0" /></a>									
									<input name="uploadImage" id="files" type="file" />
								</div>
								<div class="col-lg-8 details">									
										<div class="form-horizontal">
											<div class="form-group">
	 											<label class="col-lg-3 control-label">이름</label>
												<div class="col-lg-9">
													<input type="text" class="k-textbox" placeholder="이름" data-bind="value:name"/>
												</div>	
											</div>
											<div class="form-group">
	 											<label class="col-lg-3 control-label">메일</label>
												<div class="col-lg-9">
													<input type="text" class="k-textbox" placeholder="메일주소" data-bind="value:email"/>
												</div>	
											</div>
											<div class="form-group">
	 											<label class="col-lg-3 control-label">옵션</label>
												<div class="col-lg-9">
													<div class="checkbox">
														<label>
															<input type="checkbox" name="nameVisible"  data-bind="checked: nameVisible" />	이름공개
														</label>
													</div>		
													<div class="checkbox">
														<label>
															<input type="checkbox"  name="emailVisible"  data-bind="checked: emailVisible" />	메일공개
														</label>
													</div>	
													<div class="checkbox">
														<label>
															<input type="checkbox"  name="enabled"  data-bind="checked: enabled" />계정사용여부
														</label>
													</div>																																			
												</div>
											</div>										
										</div>
										<table class="table table-striped">
											<thead>
												<tr>
													<td>최근 수정일자</td>
													<td>최근 로그인 일자</td>
												</tr>
											</thead>
											<tbody>
												<tr class="active">
													<td><span data-bind="text: formattedLastProfileUpdate"></span></td>
													<td><span data-bind="text: formattedLastLoggedIn"></span></td>
												</tr>                                                                    
											</tbody>
										</table>									
								</div>
							</div>
							
							
							
							<div class="row">
								<div class="col-lg-12">
									<button id="update-user-btn" class="k-button">정보 변경</button>
									<button id="change-password-btn" class="k-button right">비밀번호변경</button>												
								</div>
							</div>							
							</div>
						</div>
						<div>
	        			<!-- USER PROPS TAB =============================== -->
        				<div id="user-props-grid" class="props" style="height:0px;"/>
        				<div class="box leftless rightless bottomless">
	                		<div class="alert alert-info">프로퍼티는 저장 버튼을 클릭하여야 최종 반영됩니다.</div>
	                	</div>
	                </div>
	                <div>	                
	                	<div class="row-fluid">
	                		<div class="span12">
	                			<div class="alert alert-info">
			                    	멤버로 추가하려면 리스트 박스에서 그룹을 선택후 "그룹 멤버로 추가" 버튼을 클릭하세요.
									<div class="form-inline">
										<input id="company-combo" style="width: 180px" />
										<input id="group-combo" style="width: 180px" />
										<button id="add-to-member-btn" class="k-button">그룹 맴버로 추가</button>
				                    </div>	
								</div>
	                		</div>
	                	</div>	
	                	<div class="row-fluid">
	                		<div class="span12">
			                    <div id="user-group-grid" class="groups"></div>                		
	                		</div>
	                	</div>	                	
	                </div>			
	                <div>
	                	<div class="roles">
	                		<div class="row-fluid">
	                			<div class="span12">
	                				<div class="alert alert-info">다음은 그룹에 부여된 롤입니다. 그룹에서 부여된 롤은 그룹 관리에서 변경할 수 있습니다.</div>
	                				<div id="group-role-selected"></div>
	                			</div>
	                		</div>
	                		<div class="row-fluid">
	                			<div class="span12 space-top">
                					<div class="alert alert-info">다음은 사용자에게 직접 부여된 롤입니다. 그룹에서 부여된 롤을 제외한 롤들만 아래의 선택박스에서 사용자에게 부여 또는 제거하세요.</div>	                				
	                			</div>
	                		</div>	  
	                		<div class="row-fluid">
	                			<div class="span12">
                					<div id="user-role-select"></div>                				
	                			</div>
	                		</div>	
						</div>	
	                </div>			
	                <div>	                	    
	                    <div class="alert alert-info">
		                    <input id="attach-upload" name="uploadFile" type="file" />
		                    <p/>
		                    업로드할 파일을 "선택" 버튼에  이곳에 끌어 놓거나,  "선택" 버튼을 클릭하여 업로드할 파일들을 선택한 다음 "업로드" 버튼을 클릭하세요.
	                    </div>
	                	<div id="attach-grid" class="attachments"></div>
	                </div>	
				</div>
		</script>
		<!-- 공용 템플릿 -->
		<div id="account-panel"></div>	
		<#include "/html/common/common-templates.ftl" >		
		<!-- END MAIN CONTENT  -->
    </body>
</html>