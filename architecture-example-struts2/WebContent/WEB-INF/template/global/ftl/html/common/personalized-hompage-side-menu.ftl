		<!-- ================================================== -->
		<!-- Personalized Homepage Side Menu                                                     -->
		<!-- ================================================== -->
		<section class="cbp-spmenu cbp-spmenu-vertical cbp-spmenu-right" id="cbp-spmenu-s2">
			<div class="blank-top-50"></div>
			<div class="panel panel-default">
				<div class="panel-heading"><i class="fa fa-bars"></i>&nbsp;<button  id="hide-right-slide" type="button" class="close">&times;</button></div>
				<div class="panel-body clearfix">		
						<ul class="nav nav-tabs" id="myTab">
							<li class="active">
								<a href="#my-message-announces" tabindex="-1" data-toggle="tab">공지 & 이벤트</a>
							</li>
							<li>
								<a href="#my-streams" tabindex="-1" data-toggle="tab"><i class="fa fa-th"></i>    쇼셜</a>
							</li>							
							<#if !action.user.anonymous >	
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
							</#if>						
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
								<div class="panel panel-default" style="margin-bottom:0px;">
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
							<!-- start social -->		
							<div class="tab-pane" id="my-streams">							
								<div class="blank-top-5" ></div>		
											<table id="my-social-streams-grid">
												<colgroup>
													<col/>
												</colgroup>
												<thead>
													<tr>
													<th>
													미디어
													</th>															
													</tr>
												</thead>
												<tbody>
													<tr>
														<td></td>
													</tr>
												</tbody>
											</table>	
											
								<div class="blank-top-5" ></div>				
								<div class="alert alert-warning fade in">
									<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
									<p><i class="fa fa-info"></i>쇼셜 미디어를 선택하시면, 해당 미디어의 최신 뉴스를 볼수 있습니다.  미디어 추가는 프로파일의 쇼셜네크워크에서 제공합니다. </p>
								</div>		
							</div>					
							<!-- end social -->				
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
								<div class="panel panel-default" style="margin-bottom:0px;">
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
								<div class="panel panel-default" style="margin-bottom:0px;">								
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
		</section>	