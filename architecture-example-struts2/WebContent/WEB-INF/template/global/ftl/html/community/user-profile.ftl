<#ftl encoding="UTF-8"/>
<html decorator="none">
	<body>
		<script type="text/javascript">
		<!--
		
		 	alert( 
		 		kendo.stringify( $("#account-panel").data("currentUser") ) 
		 	);
			$("#my-profile-dialog a").each(function( index ) {
				var dialog_action = $(this);		
				dialog_action.click(function (e) {
					e.preventDefault();		
					alert( $(this).html() );
				});
			});			
		-->
		</script>
			
		<div id="my-profile-dialog" class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title" id="myModalLabel">프로파일</h4>
				</div>
				<div class="modal-body">
					<div class="media">
						<a class="pull-left" href="#">
							<#if user.properties.imageId??>
							<img class="media-object img-thumbnail" src="PHOTO_URL = "/accounts/view-image.do?width=100&height=150&imageId=${user.properties.imageId}"," />
							<#else> 
							<img class="media-object img-thumbnail" src="http://placehold.it/100x150&amp;text=[No Photo]" />
							</#if>  
						</a>
						<div class="media-body">
							<h4 class="media-heading">${ user.username }</h4>							
							<form class="form-horizontal" role="form">
								<div class="form-group">
									<label class="col-sm-2 control-label">이름</label>
									<div class="col-sm-10">
										<input type="email" class="form-control" placeholder="이름" disabled data-bind="value:name" value="${ user.name }"/>
									</div>
								</div>
								<div class="form-group">
									<label class="col-sm-2 control-label">메일</label>
									<div class="col-sm-10">
										<input type="email" class="form-control" placeholder="메일" disabled data-bind="value:email" value="${ user.email }"/>
									</div>
								</div>
								<div class="form-group">
									<label for="inputPassword3" class="col-sm-2 control-label">Password</label>
									<div class="col-sm-10">
									<input type="password" class="form-control" id="inputPassword3" placeholder="Password">
								</div>
								</div>
								<div class="form-group">
									<div class="col-sm-offset-2 col-sm-10">
										<div class="checkbox">
											<label>
												<input type="checkbox"> Remember me
											</label>
										</div>
									</div>
								</div>
								<div class="form-group">
									<div class="col-sm-offset-2 col-sm-10">
										<button type="submit" class="btn btn-default">Sign in</button>
									</div>
								</div>
							</form>							
							<table class="table">
								<tbody>
									<tr>
										<th class="col-lg-3 col-sm-4">아이디</th>
										<td><input type="text" class="form-control" placeholder="아이디" disabled data-bind="value:username" value="${ user.username }"/></td>
									</tr> 								
									<tr>
										<th class="col-lg-3 col-sm-4">이름</th>
										<td><input type="text" class="form-control" placeholder="아이디" disabled data-bind="value:name" value="${ user.name }"/></td>
									</tr> 
									<tr>
										<th class="col-lg-3 col-sm-4">메일</th>
										<td><input type="text" class="form-control" placeholder="아이디" disabled data-bind="value:email" value="${ user.email }"/></td>
									</tr> 									
								</tbody>
							</table>		
						</div>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-primary" data-dismiss="modal">확인</button>
				</div>
			</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->				
	</body> 
</html>