<script type="text/x-kendo-template" id="file-panel-template">
	<div class="panel panel-default">
		<div class="panel-heading">
			<span data-bind="text: name"></span>
			<div class="k-window-actions panel-header-actions">
				<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-custom">Custom</span></a>
				<a role="button" href="\\#" class="k-window-action k-link hide"><span role="presentation" class="k-icon k-i-refresh">Refresh</span></a>
				<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-minimize">Minimize</span></a>
				<a role="button" href="\\#" class="k-window-action k-link hide"><span role="presentation" class="k-icon k-i-maximize">Maximize</span></a>
				<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-close">Close</span></a>
			</div>		
		</div>
		<div class="panel-body hide grey">
			<button type="button" class="close" aria-hidden="true">&times;</button>			
			<div class="btn-group dropup">
				<a class="btn btn-info" href="${request.contextPath}/community/download-my-attachment.do?attachmentId=#= attachmentId #" ><i class="fa fa-download"></i>&nbsp; 다운로드</a>
				<button  type="button" class="btn btn-info"><i class="fa fa-share"></i>&nbsp; 공유</button>	
				<button  type="button" class="btn btn-info"><i class="fa fa-comment-o"></i>&nbsp; 댓글 추가</button>						
			</div>			
			<div class="btn-group dropup" data-bind="visible: editable">
				<button  type="button" class="btn btn-danger custom-delete"  data-for-attachmentId="#=attachmentId #" ><i class="fa fa-trash-o"></i> 삭제</button>		
				<button  type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown"><i class="fa fa-upload"></i> 파일 변경하기</button>				
				<ul class="dropdown-menu" style="min-width:300px; padding:10px;">
					<li role="presentation" class="dropdown-header">마우스로 새로운 파일을 끌어 놓으세요.</li>
					<li>
						<input name="update-attach-file" id="update-attach-file" type="file"class="pull-right" />
					</li>
				</ul>			
			</div>			
		</div>					
		<div class="panel-body">			
			#if (contentType.match("^image") ) {#			
			<img src="${request.contextPath}/community/view-my-attachment.do?attachmentId=#= attachmentId #" alt="#:name# 이미지" class="img-responsive"/>			
			# } else { #		
				#if (contentType == "application/pdf" ) {#
				<div id="pdf-view"></div>
				# } else { #	
				<div class="k-grid k-widget" style="width:100%;">
					<div style="padding-right: 17px;" class="k-grid-header">
						<div class="k-grid-header-wrap">
							<table cellSpacing="0">
								<thead>
									<tr>
										<th class="k-header">속성</th>
										<th class="k-header">값</th>
									</tr>
								</thead>
							</table>
						</div>
					</div>
					<div style="height: 199px;" class="k-grid-content">
						<table style="height: auto;" class="system-details" cellSpacing="0">
							<tbody>
								<tr>
									<td>파일</td>
									<td>#= name #</td>
								</tr>
								<tr class="k-alt">
									<td>종류</td>
									<td>#= contentType #</td>
								</tr>
								<tr>
									<td>크기(bytes)</td>
									<td>#= size #</td>
								</tr>				
								<tr>
									<td>다운수/클릭수</td>
									<td>#= downloadCount #</td>
								</tr>											
							</tbody>
						</table>	
					</div>
				</div>
				# } #
			# } #  
		</div>	
	</div>		
</script>
<!-- photo view panel -->
<script type="text/x-kendo-template" id="photo-panel-template">
	<div class="panel panel-default">
		<div class="panel-heading">
			<i class="fa fa-cloud"></i>&nbsp;사진
			<div class="k-window-actions panel-header-actions">
				<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-custom">Custom</span></a>
				<a role="button" href="\\#" class="k-window-action k-link hide"><span role="presentation" class="k-icon k-i-refresh">Refresh</span></a>
				<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-minimize">Minimize</span></a>
				<a role="button" href="\\#" class="k-window-action k-link hide"><span role="presentation" class="k-icon k-i-maximize">Maximize</span></a>
				<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-close">Close</span></a>
			</div>		
		</div>	
		<div class="panel-body hide grey">
			<button type="button" class="close" aria-hidden="true">&times;</button>					
			<div class="btn-group dropup">
				<a class="btn btn-info" href="\\#"><i class="fa fa-download"></i></a>
				<button  type="button" class="btn btn-info"><i class="fa fa-share"></i></button>	
				<button  type="button" class="btn btn-info"><i class="fa fa-comment-o"></i></button>						
			</div>						
			<div class="btn-group dropup" data-bind="visible: editable">
				<button  type="button" class="btn btn-danger custom-delete"  data-bind="enabled: editable"><i class="fa fa-trash-o"></i> 삭제</button>
				<button  type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown"><i class="fa fa-upload"></i> 사진 변경하기</button>	
				<ul class="dropdown-menu" style="min-width:300px; padding:10px;">
					<li role="presentation" class="dropdown-header">마우스로 사진을 끌어 놓으세요.</li>
					<li>
						<input name="update-photo-file" type="file" id="update-photo-file" data-bind="enabled: editable" class="pull-right" />
					</li>
				</ul>
			</div>
		</div>	
		<div class="panel-body">			
			<figure>			
				<a href="#:photoIdLink#" data-bind="attr:{href: photoIdLink }">
					<img data-bind="attr:{src: photoUrl, alt : name }" width="100%" />			
				</a>		
				<figcaption>
					<ul class="list-inline">
						<small class="text-muted" data-bind="text: modifiedDate"></small>
					</ul>
					<div class="blank-top-5 "></div>
					<ul class="pager">
						<li class="previous" data-bind="visible: previous"><a href="\\#"><i class="fa fa-chevron-left fa-2x"></i></a></li>
						<li class="next" data-bind="visible: next"><a href="\\#"><i class="fa fa-chevron-right fa-2x"></i></a></li>
					</ul>										
				</figcaption>		
			</figure>		
			<div class="lb-overlay blue" id="#:photoId#" data-bind="attr: { id: photoId }">			
				<a href="\\#page" class="lb-overlay-close">Close</a>
				<img data-bind="attr:{src: photoUrl}" />
				<div>
					<h3>pointe <span>/point/</h3>
					<p>image description....</p>
				</div>
			</div>							
		</div>				
	</div>		
</script>
<script type="text/x-kendo-template" id="photo-view-template">	
		<figure>			
			<a href="\\#photo-#:imageId#">			
			<img src="${request.contextPath}/community/view-my-image.do?imageId=#:imageId#" width="100%" alt="#:name# 이미지"/>			
			</a>
			<figcaption>
				<ul class="list-inline">
					<small class="text-muted" data-bind="text: modifiedDate"></small>
				</ul>
				<div class="blank-top-5 "></div>
				<ul class="pager">
					#if ( index > 0 || page > 1 ) { # 
						<li class="previous"><i class="fa fa-chevron-left fa-2x"></i></li>
						# } #	
						<li class="next"><i class="fa fa-chevron-right fa-2x"></i></li>
				</ul>										
			</figcaption>			
		</figure>
		<div class="lb-overlay" id="photo-#:imageId#">			
			<a href="\\#page" class="lb-overlay-close">Close</a>
			<img src="${request.contextPath}/community/view-my-image.do?imageId=#:imageId#" />
			<div>
				<h3>pointe <span>/point/</h3>
				<p>image description....</p>
			</div>
		</div>		
</script>

<script type="text/x-kendo-template" id="file-view-template">

	<div class="panel panel-default">
		<div class="panel-heading">#= name # 미리보기<button id="image-view-btn-close" type="button" class="close">&times;</button></div>
		<div class="panel-body">
			#if (contentType.match("^image") ) {#			
			<img src="${request.contextPath}/community/view-my-attachment.do?attachmentId=#= attachmentId #" alt="#:name# 이미지" class="img-responsive"/>			
			# } else { #		
				#if (contentType == "application/pdf" ) {#
				<div id="pdf-view"></div>
				# } else { #	
				<div class="k-grid k-widget" style="width:100%;">
					<div style="padding-right: 17px;" class="k-grid-header">
						<div class="k-grid-header-wrap">
							<table cellSpacing="0">
								<thead>
									<tr>
										<th class="k-header">속성</th>
										<th class="k-header">값</th>
									</tr>
								</thead>
							</table>
						</div>
					</div>
					<div style="height: 199px;" class="k-grid-content">
						<table style="height: auto;" class="system-details" cellSpacing="0">
							<tbody>
								<tr>
									<td>파일</td>
									<td>#= name #</td>
								</tr>
								<tr class="k-alt">
									<td>종류</td>
									<td>#= contentType #</td>
								</tr>
								<tr>
									<td>크기(bytes)</td>
									<td>#= size #</td>
								</tr>				
								<tr>
									<td>다운수/클릭수</td>
									<td>#= downloadCount #</td>
								</tr>											
							</tbody>
						</table>	
					</div>
				</div>
				# } #
			# } #  			
		</div>
		<div class="panel-footer">
			<a class="btn btn-default" href="${request.contextPath}/community/download-my-attachment.do?attachmentId=#= attachmentId #" ><i class="fa fa-download"></i> 다운로드</a>
			<button  type="button" class="btn btn-danger custom-attachment-delete"  data-for-attachmentId="#=attachmentId #" ><i class="fa fa-trash-o"></i> 삭제</button>		
			<button  type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown"><i class="fa fa-upload"></i> 파일 변경하기</button>				
			<ul class="dropdown-menu" style="min-width:400px; padding:10px;">
				<li role="presentation" class="dropdown-header">마우스로 새로운 파일을 끌어 놓으세요.</li>
				<li>
					<input name="update-attach-file" id="update-attach-file" type="file"class="pull-right" />
				</li>
			</ul>			
		</div>
	</div>
</script>
<!-- EVENT -->
<script type="text/x-kendo-tmpl" id="announcement-detail-panel-template">		
	<div class="panel panel-default panel-flat panel-border-thick">
		<div class="panel-heading">
			<button type="button" class="close" aria-hidden="true"><i class="fa fa-times fa-2x"></i></button>
			<h4 data-bind="html:subject"></h4>
			<small class="text-muted"><span class="label label-info">알림 기간</span> #: kendo.toString(startDate, "g") # ~  #: kendo.toString(endDate, "g") #</small>					
		</div>
		<div class="panel-body" data-bind="html:body"></div>	
	</div>
</script>

<!-- announce view panel -->
<script type="text/x-kendo-tmpl" id="announcement-view-template">		
	<h4 data-bind="html:subject"></h4>
	<small><span class="label label-primary">기간</span> #: kendo.toString(startDate, "g") # ~  #: kendo.toString(endDate, "g") #</small><br>
	<div class="media">
		<a class="pull-left" href="\\#">
		#if ( user.properties.imageId != null ) {# 
		<img src="${request.contextPath}/accounts/view-image.do?width=100&height=150&imageId=#: user.properties.imageId#" width="30" height="30" class="img-thumbnail">	
		# } else {  #	
		<img src="${request.contextPath}/images/common/anonymous.png" width="30" height="30" class="img-circle">
		# } #
		</a>
		<div class="media-body">
			<h5 class="media-heading">
				# if( user.nameVisible ){#
				#: user.name # (#: user.username #)
				# } else { #
				#: user.username #
				# } # 		
				# if( user.emailVisible ){#
				<br>(#: user.email #)
				# } #	
			</h5>		
		</div>
	</div>	
	<div class="blank-top-5" ></div>
	<div data-bind="html:body"></div>
	# if ("${action.view!}" == "personalized" && modifyAllowed ) {#  										
	<button  type="button" class="btn btn-primary pull-right custom-edit"><i class="fa fa-pencil-square-o"></i> 수정</button>
	# } #
</script>

<script type="text/x-kendo-tmpl" id="announcement-edit-template">		
	<div  class="form">
		<div class="form-group">
			<label class="control-label">제목</label>
			<input type="text" placeholder="제목을 입력하세요." data-bind="value: subject"  class="form-control" placeholder="제목" />
		</div>
		<div class="form-group">
			<label class="control-label">기간</label>
			<div class="col-sm-12" >
			<input data-role="datetimepicker" data-bind="value:startDate"> ~ <input data-role="datetimepicker" data-bind="value:endDate">
			<span class="help-block">지정된 기간 동안만 이벤트 및 공지가 보여집니다. </span>
			</div>
		</div>
		<div class="form-group">
			<textarea class="editor" data-bind='value:body'></textarea>		
		</div>
	</div>	  
	<div class="status"></div>	
	<div class="btn-group">
		<button type="button" class="btn btn-primary custom-update" ><i class="fa fa-check"></i> 저장</button>
		# if( announceId > 0 ){#
		<button type="button" class="btn btn-primary custom-cancle" >취소</button>
		<button type="button" class="btn btn-danger custom-delete" ><i class="fa fa-trash-o"></i> 삭제</button>			
		# } #
	</div>
</script>

<script type="text/x-kendo-tmpl" id="announcement-template">
	<tr class="announce-item" onclick="viewAnnounce(#: announceId#);">
		<th>#: announceId#</th>
		<td>#: subject#</td>
	</tr>
</script>

<script type="text/x-kendo-tmpl" id="social-view-panel-template">
	<div class="custom-panels-group" style="display:none;"> 
		<div id="#: serviceProviderName #-panel-#:socialAccountId#" class="panel panel-info">
			<div class="panel-heading">
				<i class="fa fa-#: serviceProviderName # fa-fw"></i>&nbsp;&nbsp;#: serviceProviderName # &nbsp; 소식
				<div class="k-window-actions panel-header-actions">
					<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-refresh">Refresh</span></a>
					<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-minimize">Minimize</span></a>
					<a role="button" href="\\#" class="k-window-action k-link hide"><span role="presentation" class="k-icon k-i-maximize">Maximize</span></a>
					<a role="button" href="\\#" class="k-window-action k-link"><span role="presentation" class="k-icon k-i-close">Close</span></a>
				</div>							
			</div>
			<div class="panel-body scrollable" style="max-height:500px;">
				<ul class="media-list">
					<div id="#:serviceProviderName#-streams-#:socialAccountId#">&nbsp;</div>
				</ul>
			</div>
		</div>	
	</div>				
</script>

<script type="text/x-kendo-tmpl" id="facebook-homefeed-template">
		#if (type != "STATUS") {#
		<li class="media">
		    <a class="pull-left" href="\\#">
		    	<img class="media-object img-circle" src="http://graph.facebook.com/#=from.id#/picture" alt="프로파일 이미지">
		    </a>
		    <div class="media-body">
		      <h5 class="media-heading">
		      <span class="label label-primary">#: type #</span><br><br>
		      #: from.name #  (#: ui.util.prettyDate(updatedTime) #) 
		      </h5>		     	
		     	#if ( typeof( message ) == 'string'  ) { #
		     	<br>
		     	#: message #
		     	# } #				     	     	
		     	#if ( name !=null ) { #
		     	<br>#: name  #
		     	# } #		     	     	
		     	#if ( type == 'LINK' ) { #
		     	<br>
		     	<span class="glyphicon glyphicon-link"></span>&nbsp;<a href="#: link #">#: link #</a>
		     	# } else if ( type == 'PHOTO' ) { #
		     		<br>
		     		<img src="#: picture.replace("_s.", "_n.")  #" alt="media" class="img-rounded img-responsive">
		     	# } else { #		     	
		     		#if ( picture !=null ) { #
		     		<br><img src="#: picture.replace("_s.", "_n.")  #" alt="media" class="img-rounded img-responsive">
		     		# } #		     		
		     		#if ( source !=null ) { #
		     		<br>source : <span class="glyphicon glyphicon-link"></span>&nbsp;<a href="#: source #">#: source #</a>
		     		# } #
		     	# } #
		     	
		     	#if ( typeof( caption ) == 'string'  ) { #
		     	<br><br>
		     	<blockquote>
		     	<p>#: caption #</p>
				</blockquote>
		     	# } #		     	
		     	#if ( typeof( description ) == 'string'  ) { #
		     	<blockquote><p class="text-muted"><small>
		     	#: description #
		     	</small></p>
		     	</blockquote>
		     	# } #				     							
				# for (var i = 0; i < comments.length ; i++) { #												
				# var comment = comments[i] ; #							
					<div class="media">
						<a class="pull-left" href="\\#">
							<img class="media-object img-circle" src="http://graph.facebook.com/#=comment.from.id#/picture" alt="프로파일 이미지" class="img-circle">
						</a>	
						<div class="media-body">
							 <h6 class="media-heading">#: comment.from.name # &nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-thumbs-up"></span>#:comment.likesCount#</h6>
							 <p class="text-muted">#:comment.message#</p>
						</div>				
					</div>				
				# } #
			</div>
		</li>					
		# } #  	
</script>		

<script type="text/x-kendo-tmpl" id="twitter-timeline-template">
		<li class="media">
		    <a class="pull-left" href="\\#">
		      <img src="#: user.profileImageUrl #" alt="#: user.name#" class="media-object img-circle">
		    </a>
		    <div class="media-body">
		      <h5 class="media-heading">#: user.name # (#: ui.util.prettyDate(createdAt) #)</h5>
		     	#: text #      	
							# for (var i = 0; i < entities.urls.length ; i++) { #
							# var url = entities.urls[i] ; #		
							<br><span class="glyphicon glyphicon-link"></span>&nbsp;<a href="#: url.expandedUrl  #">#: url.displayUrl #</a>
							 # } #	
							<p>
							# for (var i = 0; i < entities.media.length ; i++) { #	
							# var media = entities.media[i] ; #					
							<img src="#: media.mediaUrl #" width="100%" alt="media" class="img-rounded">
							# } #
							</p>
							#if (retweeted) {#					
						<div class="media">
							<a class="pull-left" href="\\#">
								<img src="#: retweetedStatus.user.profileImageUrl #" width="100%" alt="media" class="img-rounded">
							</a>
							<div class="media-body">
								<h4 class="media-heading">#: retweetedStatus.user.name #</h4>
							</div>
						</div>						
							# } #
		    </div>
		  </li>					
</script>

<!--  Top Munu Account Status Template -->
<script id="account-template" type="text/x-kendo-template">
<li class="dropdown navbar-btn">
	<div class="btn-group">		
		<a href="\\#" class="btn-img">
		#if (photoUrl != null && photoUrl != 'null' && photoUrl != '')  { #
		<img src="#:photoUrl#"  height="34"   alt="#:name#" class="btn-img"/>
		# } else { # 
		<img src="${request.contextPath}/images/common/anonymous.png" height="34" class="btn-img"/>	
		# } #
		</a>
		<a  href="/main.do?view=personalized" class="btn btn-info"># if ( !anonymous ) { # #:name## } else { # 익명 # } #	</a>
		<button type="button" class="btn btn-info dropdown-toggle" data-toggle="dropdown">
			<!-- <i class="fa fa-cogs"></i> -->			
			<span class="caret"></span>
			<span class="sr-only">Toggle Dropdown</span>
		</button>  
		<ul class="dropdown-menu">
			# if ( !anonymous ) { # 
			<li>
				<div class="blank-space-5">	
					<ul class="media-list">
						<li class="media">
							<a class="pull-left" href="\\#">
								#if (photoUrl != null && photoUrl != 'null' && photoUrl != '')  { #
								<img class="media-object img-thumbnail" src="#:photoUrl#" />
								# } else { # 
								<img class="media-object img-thumbnail" src="http://placehold.it/100x150&amp;text=[No Photo]" />
								# } #	
							</a>
							<div class="media-body" style="color:ccc;">
								<p class="text-muted"><strong> #:name#</strong></p>
								<p class="text-muted"> #:email #</p>	
								<p><a href="/community/view-myprofile.do?view=modal-dialog" class="btn btn-primary" data-toggle="modal" data-target="\\#myModal" ><i class="fa fa-user"></i> 프로필 보기</a></p>		
								<!--						
								<ul class="nav nav-pills nav-stacked">
									<li class="active">
										<a href="\\#">
										<span class="badge pull-right">3</span>
										Home
										</a>
									</li>
									<li>
										<a href="\\#">
										<span class="badge pull-right">1</span>
										알림
										</a>
									</li>
									<li>
										<a href="\\#">
										<span class="badge pull-right">2</span>
										메시지
										</a>
									</li>																			
								</ul>
								-->
							</div>
						</li>
					</ul>
				</div>
			</li>
			<li class="divider"></li>
			<!--<li><a href="/community/view-myprofile.do?view=modal-dialog" data-toggle="modal" data-target="\\#myModal" ><i class="fa fa-user"></i> 프로필 보기</a></li>-->			
			<li><a href="/main.do?view=personalized">마이 페이지</a></li>
			#if (isSystem ) {#
			<li><a href="/secure/main-site.do">시스템 관리</a></li>
			# } #
			<li class="divider"></li>
			<li><a href="/logout"><i class="fa fa-sign-out"></i> 로그아웃</a></li>
			# } else { # 						
			<li>
				<div class="container custom-external-login-groups" style="width:100%;">
					<div class="row blank-top-5 ">
						<div class="col-lg-12">
							<button class="btn btn-block btn-primary" data-target="facebook"><i class="fa fa-facebook"></i> | 페이스북으로 로그인</button>
						</div>
					</div>		
					<div class="row blank-top-5 ">
						<div class="col-lg-12">
							<button class="btn btn-block btn-info" data-target="twitter"><i class="fa fa-twitter"></i> | 트위터로 로그인</button>
						</div>
					</div>					
				</div>
			</li>
			<li class="divider"></li>
			<li>
				<div class="container bg-white" id="login-panel"style="width:100%;">													
					<div class="row blank-top-5 ">
						<div class="col-lg-12">
							<form role="form" name="login-form" method="POST" accept-charset="utf-8">
								<input type="hidden" id="output" name="output" value="json" />		
								<div class="form-group">
									<label for="login-username">아이디 또는 이메일</label>
									<input type="text" class="form-control col-lg-12" id="login-username" name="username" placeholder="아이디 또는 이메일" required validationMessage="아이디 또는 이메일을 입력하여 주세요.">
								</div>
								<div class="form-group">
									<label for="login-password">비밀번호</label>
										<input type="password" class="form-control " id="login-password" name="password"  placeholder="비밀번호"  required validationMessage="비밀번호를 입력하여 주세요." >
								</div>				 
								<button type="button" id="login-btn" class="btn btn-primary btn-block"><i class="fa fa-sign-in"></i> 로그인</button>
							</form>						
						</div>
					</div>
					<div class="row">
						<div class="col-lg-12">
							<div id="login-status" class="blank-top-5"/>
						</div>
					</div>	
				</div>
			</li>
			<li class="divider"></li>
			<li><a href="\\#">아이디/비밀번호찾기</a></li>
			<li><a href="${request.contextPath}/accounts/signup.do">회원가입</a></li>
			# } #
		</ul>
	</div>			
</li>				
</script>
		