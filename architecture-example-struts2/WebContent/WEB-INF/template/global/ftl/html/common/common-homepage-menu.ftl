		<!-- START MENU -->	
		<#if action.getMenuComponent("USER_MENU") ?? >
		<#assign menu = action.getMenuComponent("USER_MENU") />			
				<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
					<div class="container">
						<#if action.user.company ?? >
						<div class="navbar-header">					
							<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-ex1-collapse">
								<span class="sr-only">Toggle navigation</span>
								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
							</button>					
							<a class="navbar-brand" href="/main.do">&nbsp;&nbsp;${action.user.company.displayName }</a>
						</div>			
						</#if>												
						<div class="navbar-collapse collapse" id="navbar-ex1-collapse">
							<ul class="nav navbar-nav">
								<#list menu.components as item >
								<#if  item.components?has_content >
									<li class="dropdown">
										<a href="#" class="dropdown-toggle" data-toggle="dropdown">${item.title}<b class="caret"></b></a>
										<ul class="dropdown-menu">
										<#list item.components as sub_item >
											<#if sub_item.components?has_content >
												<li class="dropdown-submenu">
													<a href="#" class="dropdown-toggle" data-toggle="dropdown">${sub_item.title}</a>
													<ul class="dropdown-menu">
														<#list sub_item.components as sub_sub_item >
														<li><a href="${sub_item.page}">${ sub_sub_item.title }</a></li>
														</#list>
													</ul>
												</li>
											<#else>								
												<li><a href="${sub_item.page}">${sub_item.title}</a></li>
											</#if>								
										</#list>
										</ul>
									</li>
								<#else>
									<li>
										<a href="#">${item.title}</a>
									</li>
								</#if>
								</#list>
							</ul>				
							<ul id="account-navbar" class="nav navbar-nav navbar-right"></ul>						
						</div>						
					</div>
				</nav>
			</#if>		
			<!-- END MENU -->		
			<!-- START My profile Modal -->
			<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
			  <div class="modal-dialog">
			    <div class="modal-content">
			      <div class="modal-header">
			        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
			        <h4 class="modal-title" id="myModalLabel">내정보</h4>
			      </div><!--
			      <div class="modal-body">
					<div class="progress progress-striped active">
						<div class="progress-bar"  role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
							<span class="sr-only">100% Complete</span>
						</div>
					</div>
			      </div>-->
			      <div class="modal-footer">
			      </div>
			    </div><!-- /.modal-content -->
			  </div><!-- /.modal-dialog -->
			</div><!-- /.modal -->					